module Main.Update exposing (update)

import Effects.Local exposing (LocalEffect(..))
import Main.Model exposing (Model, authConfig)
import Main.Msg exposing (Msg(..))
import Paack.Auth.Main as Auth
import Paack.Effects as Effects exposing (Effects, fromLocal)


update : Msg -> Model -> ( Model, Effects Msg )
update msg model =
    case msg of
        ForAuth subMsg ->
            forAuth subMsg model

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
    in
    ( { model | auth = subModel, user = Auth.getUser model.auth }
    , mappedEffects
    )
