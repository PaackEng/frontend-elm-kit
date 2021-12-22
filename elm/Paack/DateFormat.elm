module Paack.DateFormat exposing (..)

import DateFormat exposing (..)
import Time


fullStamp : List Token
fullStamp =
    [ dayOfMonthFixed
    , DateFormat.text "/"
    , monthFixed
    , DateFormat.text "/"
    , yearNumberLastTwo
    , DateFormat.text " "
    , hourMilitaryFixed
    , DateFormat.text ":"
    , minuteFixed
    ]


dateOnly : List Token
dateOnly =
    [ dayOfMonthFixed
    , DateFormat.text "/"
    , monthFixed
    , DateFormat.text "/"
    , yearNumberLastTwo
    ]


timeOnly : List Token
timeOnly =
    [ hourMilitaryFixed
    , DateFormat.text ":"
    , minuteFixed
    ]


shortMonthDayYear : List Token
shortMonthDayYear =
    [ monthNameAbbreviated
    , text " "
    , DateFormat.dayOfMonthFixed
    , text ", "
    , yearNumber
    ]


sortableTime : Time.Posix -> String
sortableTime time =
    format
        [ yearNumber
        , DateFormat.text "-"
        , monthFixed
        , DateFormat.text "-"
        , dayOfMonthFixed
        , DateFormat.text "-"
        , hourMilitaryFixed
        , DateFormat.text "-"
        , minuteFixed
        ]
        Time.utc
        time


sortableDate : List Token
sortableDate =
    [ yearNumber
    , DateFormat.text "-"
    , monthFixed
    , DateFormat.text "-"
    , dayOfMonthFixed
    ]
