port module Paack.Auth.Internals.Ports exposing (authResult, checkSession, login, logout)

import Json.Decode as Decode


port checkSession : () -> Cmd msg


port login : () -> Cmd msg


port logout : () -> Cmd msg


port authResult : (Decode.Value -> msg) -> Sub msg
