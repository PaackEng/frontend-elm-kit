module Main.Msg exposing (Msg(..))

import Browser
import Paack.Auth.Main as Auth
import Paack.Rollbar.Effect exposing (RollbarResult)
import UI.Document as UI
import Url


type Msg
    = ForAuth Auth.Msg
    | ForUI UI.Msg
    | LinkClicked Browser.UrlRequest
    | RollbarFeedback RollbarResult
    | UrlChanged Url.Url
