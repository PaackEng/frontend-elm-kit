module Paack.Basics exposing (..)


type Either a b
    = Left a
    | Right b


range : (Int -> a) -> Int -> Int -> Int -> List ( a, a )
range mapper interval start end =
    if interval <= 0 then
        []

    else if end > start + interval then
        let
            portionEnd =
                start + interval
        in
        ( mapper start, mapper <| portionEnd - 1 ) :: range mapper interval portionEnd end

    else
        [ ( mapper start, mapper end ) ]


flip : (a -> b -> c) -> b -> a -> c
flip applier b a =
    applier a b


ifThenElse : Bool -> a -> a -> a
ifThenElse condition ifThen ifElse =
    if condition then
        ifThen

    else
        ifElse
