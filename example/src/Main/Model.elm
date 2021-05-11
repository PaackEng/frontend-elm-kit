module Main.Model exposing (Flags, Model, authConfig, init)

import Effects.Local exposing (LocalEffect(..))
import Main.Msg as Msg exposing (Msg)
import Paack.Auth.Main as Auth
import Paack.Auth.User exposing (User)
import Paack.Effects as Effects exposing (Effects, fromLocal)
import Url exposing (Url)


type alias Model =
    { auth : Auth.Model
    , user : Maybe User
    }


type alias Flags =
    { randomSeed1 : Int
    , randomSeed2 : Int
    , randomSeed3 : Int
    , randomSeed4 : Int
    }


authConfig : Auth.Config Msg
authConfig =
    { toExternalMsg = Msg.ForAuth }


init : Flags -> Url -> () -> ( Model, Effects Msg )
init _ _ _ =
    let
        ( auth, authEffects ) =
            Auth.init authConfig
    in
    ( { auth = auth
      , user = Nothing
      }
    , fromLocal <| AuthEffect authEffects
    )
