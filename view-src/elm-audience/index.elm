import Http
import Dict
import Json
import Signal

main : Signal Element
main = lift scene (Http.sendGet (Signal.constant "/files/index.json"))

scene : Http.Response String -> Element
scene resp = case resp of
    Http.Success a ->
      case Json.fromString a of
        Just j -> (
          case j of
            Json.Object d ->
              case (Dict.get "background_url" d) of
                Just bg ->
                  case bg of
                    Json.String url -> plainText url
                    _ -> plainText "wrong bg"
                _ -> plainText "wrong bg"
            _ -> plainText "wrong bg"
          )
        _ -> plainText "wrong JSON"
    Http.Failure code msg ->
      plainText ((show code) ++ ":" ++ msg)
    _ -> plainText "waiting"
