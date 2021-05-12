module Effects.LocalPerformer exposing (effectPerform)

import Browser.Navigation as Nav
import Effects.Local exposing (LocalEffect(..))
import Main.Model exposing (Model)
import Main.Msg as Msg exposing (Msg)
import Paack.Auth.Main as Auth
import Paack.Rollbar.Performer as Rollbar
import UUID exposing (Seeds)


effectPerform : Nav.Key -> Seeds -> Model -> LocalEffect Msg -> ( Seeds, Cmd Msg )
effectPerform _ seeds model effect =
    case effect of
        AuthEffect subEffect ->
            ( seeds, Auth.performEffect subEffect )

        RollbarEffect subEffect ->
            ( seeds, Rollbar.performEffectWithModel Msg.RollbarFeedback model subEffect )
