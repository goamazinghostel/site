{-# LANGUAGE OverloadedStrings #-}
module Main where

import Hakyll

import Data.Monoid ((<>))
import System.FilePath (dropExtension, takeFileName, (</>))

routePage :: FilePath -> FilePath
routePage "home" = "index.html"
routePage page   = page </> "index.html"

pageList :: Compiler [Item String]
pageList = fmap (flip Item "") <$> getMatches "pages/*"

pageContext :: Context String
pageContext = listField "pages" defaultContext pageList
           <> defaultContext

main :: IO ()
main = hakyll $ do
    match "templates/*" $ compile templateCompiler

    match "images/*" $ do
        route idRoute
        compile copyFileCompiler

    match "pages/*" $ do
        route $ customRoute $
            routePage . dropExtension . takeFileName . toFilePath
        compile $ getResourceBody
            >>= loadAndApplyTemplate "templates/layout.html" pageContext
            >>= relativizeUrls
