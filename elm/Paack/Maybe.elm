module Paack.Maybe exposing (flip, maybePrepend)


fallback : Maybe a -> Maybe a -> Maybe a
fallback replacement primary =
    case primary of
        Just _ ->
            primary

        Nothing ->
            replacement



