module Paack.Json.Encode exposing (..)

import Json.Encode as Encode exposing (Value)


maybeWithNull : (data -> Value) -> Maybe data -> Value
maybeWithNull encoder maybeData =
    case maybeData of
        Just data ->
            encoder data

        Nothing ->
            Encode.null
