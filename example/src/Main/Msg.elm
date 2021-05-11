module Main.Msg exposing (Msg(..))

import Browser
import Paack.Auth.Main as Auth
import Paack.Rollbar.Effect exposing (RollbarResult)
import Url


type Msg
    = ForAuth Auth.Msg
    | LinkClicked Browser.UrlRequest
    | RollbarFeedback RollbarResult
    | UrlChanged Url.Url
