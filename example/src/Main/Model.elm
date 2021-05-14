module Main.Model exposing (Flags, Model, authConfig, init)

import Data.Environment as Environment exposing (Environment)
import Effects.Local exposing (LocalEffect(..))
import Main.Msg as Msg exposing (Msg)
import Paack.Auth.Main as Auth
import Paack.Auth.User exposing (User)
import Paack.Effects as Effects exposing (Effects, fromLocal)
import Paack.Rollbar as Rollbar
import Paack.Rollbar.Dispatch as Rollbar
import Url exposing (Url)


type alias Model =
    { appConfig : { environment : Environment, version : String }
    , auth : Auth.Model
    , url : Url
    , user : Maybe User
    , rollbarToken : Rollbar.MaybeToken
    }


type alias Flags =
    { randomSeed1 : Int
    , randomSeed2 : Int
    , randomSeed3 : Int
    , randomSeed4 : Int
    , rollbarToken : String
    }


authConfig : Auth.Config Msg
authConfig =
    { toExternalMsg = Msg.ForAuth }


init : Flags -> Url -> () -> ( Model, Effects Msg )
init flags url _ =
    let
        ( auth, authEffects ) =
            Auth.init authConfig
    in
    ( { appConfig =
            { environment = Environment.Development
            , version = " v0.0.0-1-g99c0ff3"
            }
      , auth = auth
      , url = url
      , user = Nothing
      , rollbarToken = Rollbar.initToken flags.rollbarToken
      }
    , Effects.batch
        [ fromLocal <| AuthEffect authEffects
        , Rollbar.errorPayload "example"
            |> Rollbar.sendError "Main.Model.init"
        ]
    )
