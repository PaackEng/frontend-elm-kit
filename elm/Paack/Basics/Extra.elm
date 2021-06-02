module Paack.Basics.Extra exposing (flip, maybePrepend)


flip : (a -> b -> c) -> b -> a -> c
flip applier b a =
    applier a b


maybePrepend : Maybe a -> List a -> List a
maybePrepend maybeSomething items =
    case maybeSomething of
        Just something ->
            something :: items

        Nothing ->
            items
