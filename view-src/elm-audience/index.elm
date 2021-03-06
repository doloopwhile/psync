module Audience where

import Color
import Dict
import Http
import Json
import List
import Mouse
import Signal
import Time
import Window
import Text

port polling : Signal Int

main : Signal Element
main =
  let s = scene
          <~ (Http.sendGet (Signal.constant "/files/index.json"))
          ~ Window.width
          ~ Window.height
          ~ scroll
      p = (\x y ->
            let
              t = "(" ++ (show x) ++ ", " ++ (show y) ++ ")"
              c = Color.hsl (atan2 (toFloat -y) (toFloat x)) 1 0.5
            in
              rightAligned (Text.color c (toText t))
          ) <~ Mouse.x ~ Mouse.y
  in
    above <~ p ~ s

scroll =
  let
    prevNext = foldp (\next (_, prev) -> (prev, next)) (0,0) polling
    delta    = 50 * Time.millisecond
    duration = 500 * Time.millisecond
  in
    (\now (period, (prev, curr)) ->
      let r = (now - period) / duration
      in
        if | 1 < r     -> toFloat curr
           | r < 0     -> toFloat prev
           | otherwise -> (toFloat curr) * r + (toFloat prev) * (1 - r)
    ) <~ every delta ~ Time.timestamp prevNext

scene : Http.Response String -> Int -> Int -> Float -> Element
scene resp width height pageIndex = case resp of
  Http.Success a ->
    case Json.fromString a of
      Nothing -> plainText "not json"
      Just j ->
        case getPageUrls j of
          Just urls -> previews urls width height pageIndex
          Nothing -> plainText "json in unexpected type"
  Http.Failure code msg ->
    plainText ((show code) ++ ":" ++ msg)
  _ ->  plainText "waiting"

getPageUrls : Json.Value -> Maybe [String]
getPageUrls j =
  case j of
    Json.Object d -> case Dict.get "page_urls" d of
      Just p -> case p of
        Json.Array listOfJson -> getStringArray listOfJson
        _ -> Nothing
      _ -> Nothing
    _ -> Nothing

getStringArray : [Json.Value] -> Maybe [String]
getStringArray vals = realizeAll (List.map getString vals)

getString : Json.Value -> Maybe String
getString j =
  case j of
    Json.String s -> Just s
    _ -> Nothing

realizeAll : [Maybe a] -> Maybe [a]
realizeAll arr = List.foldl maybeAppend (Just []) arr

maybeAppend : Maybe a -> Maybe [a] -> Maybe [a]
maybeAppend mx marr =
  case (mx, marr) of
    (Nothing, _) -> Nothing
    (_, Nothing) -> Nothing
    ((Just x), (Just arr)) -> Just (arr ++ [x])

previews : [String] -> Int -> Int -> Float -> Element
previews urls w h pageScroll =
  let
    margin = 100
    pages = map (\url ->
              container w h middle <|
                keepAspectScaledImage url (w - margin) (h - margin) 4 3
            ) urls
  in
    layers [
      container w h middle
        (image 250 300 "/files/bg.jpg")
    , collage w h (
        indexedMap (\i e ->
          moveX ((toFloat w) * ((toFloat i) - pageScroll)) (toForm e)
        ) pages
      )
    ]

keepAspectScaledImage url w h rw rh =
  let (nw, nh) = newSize w h rw rh
  in
    image nw nh url

newSize w h rw rh =
  let h1 = w * rh // rw
      w1 = h * rw // rh
  in
    if | h1 < h -> (w, h1)
       | otherwise -> (w1, h)
