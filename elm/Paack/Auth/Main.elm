module Paack.Auth.Main exposing
    ( Config
    , Effect(..)
    , Model(..)
    , Msg
    , checkSession
    , getSession
    , getUser
    , init
    , isFirstLogin
    , isLogged
    , login
    , logout
    , mockResult
    , performEffect
    , subscriptions
    , update
    )

import Json.Decode as Decode
import Paack.Auth.Internals.Ports as Ports
import Paack.Auth.Result as AuthResult
import Paack.Auth.Session as Session exposing (Session)
import Paack.Auth.User exposing (User)


type Model
    = Loading
    | Failed AuthResult.Error
    | Ready Session


type alias Config msg =
    { toExternalMsg : Msg -> msg
    , onLoginResult : Maybe (AuthResult.Result -> msg)
    }


type Msg
    = SessionCheckSession
    | SessionLogin
    | SessionLogout
    | SessionAuthResult Decode.Value


type Effect
    = NoneEffect
    | PortCheckSession
    | PortLogin
    | PortLogout


init : Config msg -> ( Model, Effect )
init _ =
    ( Loading
    , NoneEffect
    )


getSession : Model -> Session
getSession model =
    case model of
        Loading ->
            Session.NotLogged

        Failed _ ->
            Session.NotLogged

        Ready session ->
            session


getUser : Model -> Maybe User
getUser model =
    case model of
        Loading ->
            Nothing

        Failed _ ->
            Nothing

        Ready session ->
            Session.getUser session


isLogged : Model -> Bool
isLogged model =
    case model of
        Loading ->
            False

        Failed _ ->
            False

        Ready session ->
            Session.isLogged session


update : Config msg -> Msg -> Model -> ( Model, Effect )
update _ msg model =
    case msg of
        SessionCheckSession ->
            onCheckSession model

        SessionLogin ->
            onLogin model

        SessionLogout ->
            onLogout model

        SessionAuthResult value ->
            onAuthResult model value


subscriptions : Config msg -> Sub msg
subscriptions { toExternalMsg, onLoginResult } =
    Sub.batch
        [ Ports.authResult (SessionAuthResult >> toExternalMsg)
        , case onLoginResult of
            Just msg ->
                Ports.authResult (AuthResult.decode >> msg)

            Nothing ->
                Sub.none
        ]


checkSession : Config msg -> msg
checkSession { toExternalMsg } =
    toExternalMsg SessionCheckSession


login : Config msg -> msg
login { toExternalMsg } =
    toExternalMsg SessionLogin


logout : Config msg -> msg
logout { toExternalMsg } =
    toExternalMsg SessionLogout


onCheckSession : Model -> ( Model, Effect )
onCheckSession model =
    ( model
    , PortCheckSession
    )


onLogin : Model -> ( Model, Effect )
onLogin model =
    ( model
    , PortLogin
    )


onLogout : Model -> ( Model, Effect )
onLogout model =
    ( model
    , PortLogout
    )


onAuthResult : Model -> Decode.Value -> ( Model, Effect )
onAuthResult _ value =
    case AuthResult.decode value of
        Result.Ok user ->
            ( Ready <| Session.Logged user
            , NoneEffect
            )

        Result.Err error ->
            ( Failed error
            , NoneEffect
            )


performEffect : Effect -> Cmd msg
performEffect effect =
    case effect of
        NoneEffect ->
            Cmd.none

        PortCheckSession ->
            Ports.checkSession ()

        PortLogin ->
            Ports.login ()

        PortLogout ->
            Ports.logout ()


mockResult : Config msg -> Decode.Value -> msg
mockResult { toExternalMsg } value =
    toExternalMsg <| SessionAuthResult value


isFirstLogin : Model -> { a | auth : Model } -> Maybe User
isFirstLogin newAuthModel oldModel =
    case getUser newAuthModel of
        Just user ->
            if not <| isLogged oldModel.auth then
                Just user

            else
                Nothing

        Nothing ->
            Nothing
