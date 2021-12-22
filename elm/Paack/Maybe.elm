module Paack.Maybe exposing (fallback)


fallback : Maybe a -> Maybe a -> Maybe a
fallback replacement primary =
    case primary of
        Just _ ->
            primary

        Nothing ->
            replacement
