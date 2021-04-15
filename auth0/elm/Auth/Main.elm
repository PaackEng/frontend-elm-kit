module Auth.Main exposing
    ( Config
    , Model
    , Msg
    , checkSession
    , getSession
    , getUser
    , init
    , isLogged
    , login
    , logout
    , subscriptions
    , update
    )

import Auth.Internals.Ports as Ports
import Auth.Result as AuthResult
import Auth.Session as Session exposing (Session)
import Auth.User exposing (User)
import Json.Decode as Decode


type Model
    = Loading
    | Failed AuthResult.Error
    | Ready Session


type alias Config msg =
    { toExternalMsg : Msg -> msg
    }


type Msg
    = SessionCheckSession
    | SessionLogin
    | SessionLogout
    | SessionAuthResult Decode.Value


init : Config msg -> ( Model, Cmd msg )
init _ =
    ( Loading
    , Cmd.none
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


update : Config msg -> Msg -> Model -> ( Model, Cmd msg )
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
subscriptions { toExternalMsg } =
    Ports.authResult (SessionAuthResult >> toExternalMsg)


checkSession : Config msg -> msg
checkSession { toExternalMsg } =
    toExternalMsg SessionCheckSession


login : Config msg -> msg
login { toExternalMsg } =
    toExternalMsg SessionLogin


logout : Config msg -> msg
logout { toExternalMsg } =
    toExternalMsg SessionLogout


onCheckSession : Model -> ( Model, Cmd msg )
onCheckSession model =
    ( model
    , Ports.checkSession ()
    )


onLogin : Model -> ( Model, Cmd msg )
onLogin model =
    ( model
    , Ports.login ()
    )


onLogout : Model -> ( Model, Cmd msg )
onLogout model =
    ( model
    , Ports.logout ()
    )


onAuthResult : Model -> Decode.Value -> ( Model, Cmd msg )
onAuthResult _ value =
    case AuthResult.decode value of
        Result.Ok user ->
            ( Ready <| Session.Logged user
            , Cmd.none
            )

        Result.Err error ->
            ( Failed error
            , Cmd.none
            )
