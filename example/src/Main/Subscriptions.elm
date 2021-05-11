module Main.Subscriptions exposing (subscriptions)

import Browser.Events as Browser
import Main.Model exposing (Model, authConfig)
import Main.Msg as Msg exposing (Msg)
import Paack.Auth.Main as Auth


subscriptions : Model -> Sub Msg
subscriptions _ =
    Auth.subscriptions authConfig
