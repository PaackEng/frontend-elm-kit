module Main.Update exposing (update)

import Effects.Local exposing (LocalEffect(..))
import Main.Model exposing (Model, authConfig)
import Main.Msg exposing (Msg(..))
import Paack.Auth.Main as Auth
import Paack.Auth.User exposing (User)
import Paack.Effects as Effects exposing (Effects, fromLocal)


update : Msg -> Model -> ( Model, Effects Msg )
update msg model =
    case msg of
        ForAuth subMsg ->
            forAuth subMsg model

        OnLogin user ->
            ( { model | user = Just user }, Effects.none )

        LinkClicked _ ->
            ( model, Effects.none )

        UrlChanged _ ->
            ( model, Effects.none )


forAuth : Auth.Msg -> Model -> ( Model, Effects Msg )
forAuth subMsg model =
    let
        ( subModel, effects ) =
            Auth.update
                authConfig
                subMsg
                model.auth

        mappedEffects =
            fromLocal <| AuthEffect effects

        addAuthEffect subEffects =
            Effects.batch
                [ mappedEffects
                , subEffects
                ]
    in
    case isFirstLogin subModel model of
        Just user ->
            { model | auth = subModel }
                |> update (OnLogin user)
                |> Tuple.mapSecond addAuthEffect

        Nothing ->
            ( { model | auth = subModel }, mappedEffects )


onLogin : User -> Model -> ( Model, Effects Msg )
onLogin user model =
    ( model
    , Effects.none
    )


isFirstLogin : Auth.Model -> Model -> Maybe User
isFirstLogin newAuthModel oldModel =
    case Auth.getUser newAuthModel of
        Just user ->
            if not <| Auth.isLogged oldModel.auth then
                Just user

            else
                Nothing

        Nothing ->
            Nothing
