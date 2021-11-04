{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE ImplicitParams #-}
module Debug.Internal.Types
  ( DebugTag(..)
  , DebugIPTy
  , Debug
  , DebugKey
  , Event(..)
  , eventToLogStr
  , FunName
  , UserKey
  ) where

import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString.Lazy.Char8 as BSL8
import           GHC.TypeLits

type DebugIPTy = (Maybe DebugTag, DebugTag)
type Debug = (?_debug_ip :: Maybe DebugIPTy) -- (DebugKey key, ?_debug_ip :: String)
type DebugKey (key :: Symbol) = (?_debug_ip :: Maybe DebugIPTy) -- (DebugKey key, ?_debug_ip :: String)
-- These are String because they need to be lifted into TH expressions
type FunName = String
type UserKey = String
type MessageContent = BSL.ByteString

data DebugTag =
  DT { invocationId :: {-# UNPACK #-} !Word -- a unique identifier for a particular invocation of a function
     , debugKey :: Either FunName UserKey
         -- The name of the function containing the current execution context
     }

data Event
  = EntryEvent
      DebugTag -- ^ Current context
      (Maybe DebugTag) -- ^ caller's context
  | TraceEvent
      DebugTag
      MessageContent

eventToLogStr :: Event -> BSL.ByteString
eventToLogStr (EntryEvent current mPrevious) =
  BSL8.intercalate "|"
    [ "entry"
    , keyStr current
    , BSL8.pack . show $ invocationId current
    , maybe "" keyStr mPrevious
    , maybe "" (BSL8.pack . show . invocationId) mPrevious
    ]
eventToLogStr (TraceEvent current message) =
  BSL8.intercalate "|"
    [ "trace"
    , keyStr current
    , BSL8.pack . show $ invocationId current
    , message
    ]

keyStr :: DebugTag -> BSL.ByteString
keyStr
  = either
      BSL8.pack
      BSL8.pack
  . debugKey
