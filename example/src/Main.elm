module Main exposing (main)

import Main.Msg as Msg
import Main.Subscriptions as Subscriptions
import Main.View as View
import Paack.Program as Paack


main : Paack.Program
main =
    Paack.browserApplication
        { view = View.view
        , onUrlRequest = Msg.LinkClicked
        , onUrlChange = Msg.UrlChanged
        , subscriptions = Subscriptions.subscriptions
        , getRenderConfig = .appConfig >> .renderConfig
        , getPage = .page
        }
