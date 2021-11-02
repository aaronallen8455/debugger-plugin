--{-# OPTIONS_GHC -fplugin=Debug -fplugin-opt Debug:debug-all #-}
{-# OPTIONS_GHC -fplugin=Debug #-}
--{-# OPTIONS_GHC -ddump-rn-ast #-}

{-# LANGUAGE DataKinds #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE ImplicitParams #-}
{-# LANGUAGE MultiParamTypeClasses #-}

import           Control.Monad
import           Control.Concurrent
import Debug
import Class

main :: Debug => IO ()
main = do
  replicateM_ 2 $ forkIO test
  andAnother
  test

test :: Debug => IO ()
test = do
  andAnother
  trace "test" pure ()
  putStrLn $ deff (I 3)
  x <- readLn
  case x of
    3 -> putStrLn $ classy (I x)
    _ -> pure ()
  putStrLn $ classier (I 5)
  inWhere
  let inLet :: Debug => IO ()
      inLet = do
        letWhere
        another
          where letWhere = trace "hello" pure ()
  inLet
  another
  let letBound = letBoundThing
  trace letBound pure ()
  trace "leaving" pure ()
    where
      inWhere :: Debug => IO ()
      inWhere = do
        innerWhere
          where
            innerWhere :: Debug => IO ()
            innerWhere = trace "innerWhere" pure ()

another :: Debug => IO ()
another
  | trace "another" True = pure ()
  | otherwise = pure ()

andAnother :: Debug => IO ()
andAnother = trace "hello!" pure ()

letBoundThing :: Debug => String
letBoundThing = "bound by let"

newtype I = I Int deriving Show

instance Classy I where
  classy :: Debug => I -> String
  classy = boo
    where
      boo :: Debug => I -> String
      boo i = trace (show i) "..."

instance Classier I where
  classier = show

-- test :: (?x :: String) => IO ()
-- test = print ?x

