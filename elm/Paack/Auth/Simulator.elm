module Paack.Auth.Simulator exposing (simulator)

import Iso8601
import Json.Encode as Encode
import Paack.Auth.Main as Auth exposing (Config, Effect(..))
import Paack.Auth.Result as AuthResult
import ProgramTest exposing (SimulatedEffect)
import SimulatedEffect.Cmd as SimulatedCmd
import SimulatedEffect.Navigation as Nav
import SimulatedEffect.Task as SimulatedTask
import Time


simulator : Config msg -> Effect -> SimulatedEffect msg
simulator config effect =
    case effect of
        NoneEffect ->
            SimulatedCmd.none

        PortCheckSession ->
            authResult config mockLogin

        PortLogin ->
            portLogin config

        PortLogout ->
            portLogout config


loop : msg -> SimulatedEffect msg
loop msg =
    SimulatedTask.perform identity <| SimulatedTask.succeed msg


authResult : Config msg -> Encode.Value -> SimulatedEffect msg
authResult config value =
    SimulatedCmd.batch
        [ loop <| Auth.mockResult config value
        , case config.onLoginResult of
            Just msg ->
                loop <| msg <| AuthResult.decode value

            Nothing ->
                SimulatedCmd.none
        ]


portLogin : Config msg -> SimulatedEffect msg
portLogin config =
    SimulatedCmd.batch
        [ Nav.pushUrl "/?code=SOME_CODE&state=SOME_STATE"
        , authResult config mockLogin
        ]


portLogout : Config msg -> SimulatedEffect msg
portLogout config =
    SimulatedCmd.batch
        [ Nav.pushUrl "/"
        , authResult config mockLogout
        ]


mockLogout : Encode.Value
mockLogout =
    Encode.object
        [ ( "error", Encode.string "LOGOUT" )
        , ( "errorDescription", Encode.string "Mocked Logout" )
        ]


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
