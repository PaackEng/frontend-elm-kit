module Paack.Basics exposing (flip)


flip : (a -> b -> c) -> b -> a -> c
flip applier b a =
    applier a b
