{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}

module Converter
    ( bboxToDarknet
    ) where

import System.IO
import System.Directory
import Control.Monad
import Data.List

import qualified Data.Char      as C
import qualified Data.Text      as T
import qualified Data.Text.IO   as T
import qualified Graphics.Image as I 

type DarknetCoords = [T.Text]
type BBoxCoords    = [T.Text]
type ImageSize     = (Int, Int)

imageSuffix :: T.Text
imageSuffix = ".JPG"


bboxToDarknet :: Int -> FilePath -> FilePath -> IO () 
bboxToDarknet sigDigs classesPath labelPath = do
  content  <- T.readFile labelPath
  classTxt <- T.readFile classesPath
  let lines   = fmap (T.split (== ' ')) $ (drop 1) (T.lines content)
      imgNr   = (!! 0) . T.split (== '.') . last . T.split (== '/') $ T.pack labelPath
      string  = init . T.split (== '/') $ T.pack labelPath
      relPath = T.replace "Labels" "Images" $ T.intercalate (T.pack "/") string
     -- suffix  = T.pack ".JPG"
      imgPath = T.concat [relPath, "/", imgNr, imageSuffix]
      classes = T.lines classTxt
  image <- I.readImageRGB I.VU (T.unpack imgPath)
  let imgDims = I.dims image
      write   = fmap (\list -> (classString2Index classes (last list)) : (d2bCoords sigDigs imgDims (init list))) lines
  
  let writeDir  = T.replace "Images" "Darknet" relPath
      writePath = T.replace "Labels" "Darknet" (T.pack labelPath)
  createDirectoryIfMissing True (T.unpack writeDir)
  T.writeFile (T.unpack writePath) (T.unlines . fmap (T.intercalate " " ) $  write)
  return ()

{--TODO 

  1.Read Classes from *.txt File
  |
  --> Convert string labels to Int Indices

--}

{-- Done

  1.Truncate float results to needed precision?
  | 
  --> Ask number of significant digits
  --> Truncate Coords after conversion accordingly

  2.Generalize to Folder Path as Input

--}
classString2Index :: [T.Text] -> T.Text -> T.Text
classString2Index classes value = case elemIndex True classOverlap of
                                    Just index -> T.pack $ show index
                                    Nothing    -> "-1"
                                  where classOverlap = (==) <$> classes <*> [value] 

--d2bCoords :: ImageSize -> DarknetCoords -> BBoxCoords
d2bCoords sigDigs imgDims coords =
    let trunc' = Converter.truncate sigDigs 
        dw     = 1.0/(fromIntegral(snd imgDims))
        dh     = 1.0/(fromIntegral(fst imgDims))
        xmin   = read $ T.unpack (coords !! 0)
        xmax   = read $ T.unpack (coords !! 2)
        ymin   = read $ T.unpack (coords !! 1)
        ymax   = read $ T.unpack (coords !! 3)
        xtmp   = (xmin + xmax)/2.0
        ytmp   = (ymin + ymax)/2.0
        wtmp   = xmax - xmin
        htmp   = ymax - ymin
        x      = xtmp * dw
        w      = wtmp * dw
        y      = ytmp * dh
        h      = htmp * dh
    in map T.pack $ map show (map trunc' [x,y,w,h])
    
truncate :: Int -> Double -> Double
truncate n x = (fromIntegral (floor (x * 10^n))) / 10^n
--b2dCoords :: FilePath -> ImageSize -> BBoxCoords -> DarknetCoords
