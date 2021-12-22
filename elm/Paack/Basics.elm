module Paack.Basics.Extra exposing (flip, ifThenElse, maybePrepend)


flip : (a -> b -> c) -> b -> a -> c
flip applier b a =
    applier a b


ifThenElse : Bool -> a -> a -> a
ifThenElse condition ifThen ifElse =
    if condition then
        ifThen

    else
        ifElse
