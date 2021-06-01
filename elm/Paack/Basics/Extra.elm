module Paack.Basics.Extra exposing (flip, prependMaybe)


flip : (a -> b -> c) -> b -> a -> c
flip applier b a =
    applier a b


prependMaybe : Maybe a -> List a -> List a
prependMaybe maybeSomething items =
    case maybeSomething of
        Just something ->
            something :: items

        Nothing ->
            items
