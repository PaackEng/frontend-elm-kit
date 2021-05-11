module Example exposing (authFlow)

import Iso8601
import Json.Encode as Encode
import Main.Model as Model exposing (Flags, Model, authConfig)
import Main.Msg as Msg exposing (Msg)
import Main.Update exposing (update)
import Main.View exposing (view)
import Paack.Auth.Main as Auth
import Paack.Auth.User as User
import Paack.Effects exposing (Effects)
import Paack.Effects.Simulator exposing (simulator)
import ProgramTest exposing (ProgramDefinition, ProgramTest, clickButton, expectViewHas)
import SimulatedEffect.Ports
import Test exposing (..)
import Test.Html.Selector exposing (class, text)
import Time


start : ProgramTest Model Msg (Effects Msg)
start =
    programDefinition
        |> ProgramTest.withBaseUrl "http://localhost:1234/"
        |> ProgramTest.withSimulatedEffects simulator
        |> ProgramTest.withSimulatedSubscriptions simulateSubscriptions
        |> ProgramTest.start mockFlags


mockFlags : Flags
mockFlags =
    { randomSeed1 = -1
    , randomSeed2 = -1
    , randomSeed3 = -1
    , randomSeed4 = -1
    }


programDefinition : ProgramDefinition Flags Model Msg (Effects Msg)
programDefinition =
    ProgramTest.createApplication
        { init = Model.init
        , view = view
        , update = update
        , onUrlRequest = Msg.LinkClicked
        , onUrlChange = Msg.UrlChanged
        }


simulateSubscriptions : Model -> ProgramTest.SimulatedSub Msg
simulateSubscriptions _ =
    SimulatedEffect.Ports.subscribe "authResult"
        User.decoder
        (always <| Auth.mockResult authConfig mockLogin)


mockLogin : Encode.Value
mockLogin =
    Encode.object
        [ ( "userData"
          , Encode.object
                [ ( "name", Encode.string "Dummy" )
                , ( "nickname", Encode.string "Dummy" )
                , ( "sub", Encode.string "dummy" )
                , ( "updated_at", Iso8601.encode <| Time.millisToPosix 0 )
                ]
          )
        , ( "token", Encode.string "SiM_0L{vErI0" )
        ]


authFlow : Test
authFlow =
    describe "Auth flow"
        [ test "Shows loading indicator" <|
            \() ->
                start
                    |> expectViewHas
                        [ text "Authenticating"
                        ]
        , test "Shows user name" <|
            \() ->
                start
                    |> ProgramTest.simulateIncomingPort "authResult" mockLogin
                    |> expectViewHas
                        [ text "Dummy"
                        ]
        ]
