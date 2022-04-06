module Main exposing (main)

import Main.Msg as Msg
import Paack.Program as Paack


main : Paack.Program
main =
    Paack.browserApplication
        { onUrlRequest = Msg.LinkClicked
        , onUrlChange = Msg.UrlChanged
        , getRenderConfig = .appConfig >> .renderConfig
        , getPage = .page
        }
