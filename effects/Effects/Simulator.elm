module Effects.Simulator exposing (simulator)

import Effects exposing (Effect(..), Effects)
import Effects.CommonSimulator as Common
import Effects.LocalSimulator as Local
import Main.Msg exposing (Msg)
import ProgramTest exposing (SimulatedEffect)
import SimulatedEffect.Cmd as SimulatedCmd


simulator : Effects Msg -> SimulatedEffect Msg
simulator effects =
    Effects.apply effectsApplier SimulatedCmd.none effects


effectsApplier : Effects.Effect Msg -> SimulatedEffect Msg -> SimulatedEffect Msg
effectsApplier effect accumulator =
    SimulatedCmd.batch [ effectPerform effect, accumulator ]


effectPerform : Effect Msg -> SimulatedEffect Msg
effectPerform effect =
    case effect of
        LocalEffect subEffect ->
            Local.effectPerform subEffect

        CommonEffect subEffect ->
            Common.effectPerform subEffect
