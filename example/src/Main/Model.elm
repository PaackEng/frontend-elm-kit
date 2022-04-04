module Main.Model exposing (Flags, Model, authConfig, init)

import Data.Environment as Environment exposing (Environment)
import Effects.Local exposing (LocalEffect(..))
import Main.Msg as Msg exposing (Msg)
import Main.Pages as Pages exposing (PageModel)
import Paack.Auth.Main as Auth
import Paack.Auth.User exposing (User)
import Paack.Effects as Effects exposing (Effects, fromLocal)
import Paack.Mixpanel as Mixpanel exposing (Mixpanel)
import Paack.Rollbar as Rollbar
import Paack.Rollbar.Dispatch as Rollbar
import Random
import UI.Document as UI
import UI.RenderConfig as RenderConfig exposing (RenderConfig)
import UUID exposing (Seeds)
import Url exposing (Url)


type alias Model =
    { appConfig : { environment : Environment, version : String, renderConfig : RenderConfig }
    , auth : Auth.Model
    , ui : UI.Model
    , url : Url
    , user : Maybe User
    , rollbarToken : Rollbar.MaybeToken
    , mixpanel : Mixpanel
    , page : PageModel
    }


type alias Flags =
    { innerWidth : Int
    , innerHeight : Int
    , randomSeed1 : Int
    , randomSeed2 : Int
    , randomSeed3 : Int
    , randomSeed4 : Int
    , rollbarToken : String
    , mixpanelToken : String
    , mixpanelAnonId : Maybe String
    }


authConfig : Auth.Config Msg
authConfig =
    { toExternalMsg = Msg.ForAuth
    , onLoginResult = Nothing
    }


init : Flags -> Url -> () -> ( Model, Effects Msg )
init flags url _ =
    let
        ( auth, authEffects ) =
            Auth.init authConfig

        seeds =
            Seeds
                (Random.initialSeed flags.randomSeed1)
                (Random.initialSeed flags.randomSeed2)
                (Random.initialSeed flags.randomSeed3)
                (Random.initialSeed flags.randomSeed4)

        ( mixpanel, mixpanelEffects ) =
            Mixpanel.init
                { flags = flags
                , seeds = seeds
                , saveAnonIdEffect = always Effects.none
                , identifyEffect = \_ _ -> Effects.none
                , session = Nothing
                }

        renderConfig =
            RenderConfig.init
                { width = flags.innerWidth, height = flags.innerHeight }
                RenderConfig.localeEnglish
    in
    ( { appConfig =
            { environment = Environment.Development
            , version = " v0.0.0-1-g99c0ff3"
            , renderConfig = renderConfig
            }
      , auth = auth
      , ui = UI.modelInit renderConfig
      , url = url
      , user = Nothing
      , rollbarToken = Rollbar.initToken flags.rollbarToken
      , mixpanel = mixpanel
      , page = Pages.Home
      }
    , Effects.batch
        [ fromLocal <| AuthEffect authEffects
        , Rollbar.errorPayload "example"
            |> Rollbar.sendError "Main.Model.init"
        , mixpanelEffects
        ]
    )
