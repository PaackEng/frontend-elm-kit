module Paack.Events exposing (onEscapeKey)

import Browser.Events as Events
import Json.Decode as Decode


onEscapeKey : msg -> Sub msg
onEscapeKey msg =
    Decode.string
        |> Decode.field "key"
        |> Decode.andThen
            (\key ->
                case key of
                    "Escape" ->
                        Decode.succeed msg

                    _ ->
                        Decode.fail "Irrelevant key"
            )
        |> Events.onKeyUp
