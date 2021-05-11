module Effects.LocalSimulator exposing (effectPerform)

import Effects.Local exposing (LocalEffect(..))
import Main.Model as Model
import Main.Msg exposing (Msg)
import Paack.Auth.Simulator as Auth
import ProgramTest exposing (SimulatedEffect)


effectPerform : LocalEffect Msg -> SimulatedEffect Msg
effectPerform effect =
    case effect of
        AuthEffect subEffect ->
            Auth.simulator Model.authConfig subEffect
