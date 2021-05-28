module Main.Update exposing (update)

import Effects.Local exposing (LocalEffect(..))
import Main.Model exposing (Model, authConfig)
import Main.Msg exposing (Msg(..))
import Paack.Auth.Main as Auth
import Paack.Effects as Effects exposing (Effects, fromLocal)
import Paack.Return as R exposing (Return)


update : Msg -> Model -> Return Msg Model
update msg model =
    case msg of
        ForAuth subMsg ->
            forAuth subMsg model

        LinkClicked _ ->
            R.singleton model

        RollbarFeedback _ ->
            R.singleton model

        UrlChanged newUrl ->
            R.singleton { model | url = newUrl }


forAuth : Auth.Msg -> Model -> Return Msg Model
forAuth subMsg model =
    let
        ( subModel, effects ) =
            Auth.update
                authConfig
                subMsg
                model.auth
    in
    R.singleton { model | auth = subModel, user = Auth.getUser subModel }
        |> R.withEffect (fromLocal <| AuthEffect effects)
