module Effects.LocalPerformer exposing (effectPerform)

import Browser.Navigation as Nav
import Effects.Local exposing (LocalEffect(..))
import Paack.Auth.Main as Auth
import UUID exposing (Seeds)


effectPerform : Nav.Key -> Seeds -> LocalEffect msg -> ( Seeds, Cmd msg )
effectPerform _ seeds effect =
    case effect of
        AuthEffect subEffect ->
            ( seeds, Auth.performEffect subEffect )
