module Effects.Simulator exposing (simulator)

import Effects.LocalSimulator as Local
import Main.Msg exposing (Msg)
import Paack.Effects as Effects exposing (Effect(..), Effects)
import Paack.Effects.CommonSimulator as Common
import ProgramTest exposing (SimulatedEffect)
import SimulatedEffect.Cmd as SimulatedCmd


simulator : Effects Msg -> SimulatedEffect Msg
simulator effects =
    effects
        |> Effects.apply effectsApplier
            ( 0, SimulatedCmd.none )
        |> Tuple.second


effectsApplier : Effects.Effect Msg -> ( Int, SimulatedEffect Msg ) -> ( Int, SimulatedEffect Msg )
effectsApplier effect ( i, accumulator ) =
    ( i + 1, SimulatedCmd.batch [ effectPerform i effect, accumulator ] )


effectPerform : Int -> Effect Msg -> SimulatedEffect Msg
effectPerform index effect =
    case effect of
        LocalEffect subEffect ->
            Local.effectPerform subEffect

        CommonEffect subEffect ->
            Common.effectPerform index subEffect
