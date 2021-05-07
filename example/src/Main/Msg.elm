module Main.Msg exposing (Msg(..))

import Browser
import Paack.Auth.Main as Auth
import Paack.Auth.User exposing (User)
import Url


type Msg
    = ForAuth Auth.Msg
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | OnLogin User