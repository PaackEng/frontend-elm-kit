module Paack.String exposing (..)


fromPercentage : Float -> String
fromPercentage x =
    String.fromInt <| floor <| x * 100
