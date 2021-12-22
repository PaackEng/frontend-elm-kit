module Paack.Time exposing (hoursToMillis, oneDayLater)

import Time exposing (Posix)


oneDayLater : Posix -> Posix
oneDayLater baseTime =
    baseTime
        |> Time.posixToMillis
        |> (+) (hoursToMillis 24 0)
        |> Time.millisToPosix


hoursToMillis : Int -> Int -> Int
hoursToMillis hours minutes =
    (hours * 60 + minutes) * 60 * 1000
