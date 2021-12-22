module Paack.Dict exposing (toggle)

import Dict exposing (Dict)


toggle : comparable -> object -> Dict comparable object -> Dict comparable object
toggle key value dict =
    Dict.update key
        (\past ->
            case past of
                Just _ ->
                    Nothing

                Nothing ->
                    Just value
        )
        dict
