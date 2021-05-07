module Main exposing (main)

import Browser
import Main.Model exposing (Flags)
import Main.Msg as Msg exposing (Msg)
import Main.Subscriptions as Subscriptions
import Main.View as View
import Paack.Effects.MainHelper exposing (PerformerModel, performedInit, performedUpdate)


main : Platform.Program Flags PerformerModel Msg
main =
    Browser.application
        { init = performedInit
        , view = .appModel >> View.view
        , update = performedUpdate
        , onUrlRequest = Msg.LinkClicked
        , onUrlChange = Msg.UrlChanged
        , subscriptions = .appModel >> Subscriptions.subscriptions
        }
