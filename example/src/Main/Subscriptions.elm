module Main.Subscriptions exposing (subscriptions)

import Main.Model exposing (Model, authConfig)
import Main.Msg exposing (Msg)
import Paack.Auth.Main as Auth


subscriptions : Model -> Sub Msg
subscriptions _ =
    Auth.subscriptions authConfig
