module Main where

import System.Directory

import Converter

main :: IO ()
main = do 
  putStrLn "Hi, welcome to the label Converter"
  putStrLn "Default: BBox to Darknet"
  putStrLn "Please input the absolute path to the directory in which the Labels *.txt files are in with a trailing '/'.\ne.g. /home/david/Documents/Projects/MM/Training/BBox-Label-Tool/Labels/001/\n"
  labelsPath <- getLine
  labelsExist <- doesDirectoryExist labelsPath
  if (labelsExist)
    then do
      putStrLn "Please input the absolute path to the class.txt file from BBox\n"
      classesPath  <- getLine
      classesExist <- doesFileExist classesPath
      if (classesExist)
        then
          do contents <- getDirectoryContents labelsPath
             let files    = init . tail $ contents
                 imgPaths = fmap (labelsPath ++) files

             putStrLn "How many decimal Digits:"
             dig <- getLine
             if (any (== (read dig :: Int)) [0..9])
               then sequence_ $ fmap (bboxToDarknet (read dig) classesPath) imgPaths
               else putStrLn "Please input a number between 0-9\n" >> main
        else putStrLn "Please input a valid absolute path for the class.txt file\n" >> main
    else putStrLn "Please input a valid absolute path for the Labels directory\n" >> main 
