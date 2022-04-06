module Main.Update exposing (update)

import Effects.Local exposing (LocalEffect(..))
import Main.Model exposing (Model, authConfig)
import Main.Msg exposing (Msg(..))
import Paack.Auth.Main as Auth
import Paack.Effects as Effects
import Paack.Return as R exposing (Return)
import UI.Document as UI


update : Msg -> Model -> Return Msg Model
update msg model =
    case msg of
        ForAuth subMsg ->
            forAuth subMsg model

        ForUI subMsg ->
            forUI subMsg model

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
        |> R.withEffect (Effects.fromLocal <| AuthEffect effects)


forUI : UI.Msg -> Model -> Return Msg Model
forUI subMsg model =
    let
        ( newState, navEffects ) =
            UI.modelUpdateWithoutPerform subMsg model.ui
    in
    ( { model | ui = newState }
    , Effects.map ForUI <| Effects.paackUI (always Effects.none) navEffects
    )
