module Paack.Rollbar.Simulator exposing (simulator)

import Paack.Rollbar.Effect exposing (Effect, RollbarResult)
import ProgramTest exposing (SimulatedEffect)
import SimulatedEffect.Task as SimulatedTask


simulator : (RollbarResult -> msg) -> Effect -> SimulatedEffect msg
simulator toMsg _ =
    Ok ()
        |> toMsg
        |> SimulatedTask.succeed
        |> SimulatedTask.perform identity
