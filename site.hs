{-# LANGUAGE OverloadedStrings #-}
module Main where

import Hakyll

import Data.Monoid ((<>))
import System.FilePath.Posix

routePage :: FilePath -> FilePath
routePage "home" = "index.html"
routePage page   = page </> "index.html"

pageList :: Compiler [Item String]
pageList = fmap (flip Item "") <$> getMatches "pages/*"

pageContext :: Context String
pageContext = listField "pages" defaultContext pageList
           <> defaultContext

fixPageUrls :: Item String -> Compiler (Item String)
fixPageUrls item = maybe item ((<$> item) . fixup . toSiteRoot)
    <$> getRoute (itemIdentifier item)
  where
    fixup :: FilePath -> String -> String
    fixup root =
        withUrls (normalise . removeIndex . sanitize)
      where
        isIndex = (== "index.html") . takeFileName
        reduceIf p f x = if p x then f x else x
        removeIndex = reduceIf isIndex dropFileName
        sanitize = reduceIf isAbsolute ((</>) root . dropDrive)

main :: IO ()
main = hakyll $ do
    match "templates/*" $ compile templateCompiler

    match "images/*" $ do
        route idRoute
        compile copyFileCompiler

    match "css/*" $ compile compressCssCompiler

    create ["style.css"] $ do
        route idRoute
        compile $ makeItem =<< unlines . fmap itemBody <$> loadAll "css/*.css"

    match "pages/*" $ do
        route $ customRoute $
            routePage . dropExtension . takeFileName . toFilePath
        compile $ getResourceBody
            >>= loadAndApplyTemplate "templates/layout.html" pageContext
            >>= fixPageUrls
