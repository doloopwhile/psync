import Http
import List
import Dict
import Json
import Signal

main : Signal Element
main = lift scene (Http.sendGet (Signal.constant "/files/index.json"))

scene : Http.Response String -> Element
scene resp = case resp of
    Http.Success a ->
      case Json.fromString a of
        Nothing -> plainText "not json"
        Just j ->
          case getPageUrls j of
            Just urls -> previews urls
            Nothing -> plainText "json in unexpected type"
    Http.Failure code msg ->
      plainText ((show code) ++ ":" ++ msg)
    _ -> plainText "waiting"

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

previews urls =
  flow down (map (\url -> plainText url) urls)


