module Paack.Either exposing (..)


type Either a b
    = Left a
    | Right b


fromResult : Result error value -> Either error value
fromResult result =
    case result of
        Ok value ->
            Right value

        Err error ->
            Left error


toResult : Either error value -> Result error value
toResult either =
    case either of
        Right value ->
            Ok value

        Left error ->
            Err error
