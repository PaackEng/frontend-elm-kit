module Paack.Effects.Simulator exposing (simulateHardcodedUUIDs, simulator)

import Effects.LocalSimulator as Local
import Fifo exposing (Fifo)
import Main.Msg exposing (Msg)
import Paack.Effects as Effects exposing (Effect(..), Effects)
import Paack.Effects.Common as Common
import Paack.Effects.CommonSimulator as Common
import ProgramTest exposing (ProgramTest, SimulatedEffect)
import SimulatedEffect.Cmd as SimulatedCmd
import UUID exposing (UUID)


simulator : Effects Msg -> SimulatedEffect Msg
simulator effects =
    effects
        |> Effects.apply effectsApplier
            ( 0, SimulatedCmd.none )
        |> Tuple.second


effectsApplier : Effects.Effect Msg -> ( Int, SimulatedEffect Msg ) -> ( Int, SimulatedEffect Msg )
effectsApplier effect ( i, accumulator ) =
    ( i + 1, SimulatedCmd.batch [ accumulator, effectPerform i effect ] )


effectPerform : Int -> Effect Msg -> SimulatedEffect Msg
effectPerform index effect =
    case effect of
        LocalEffect subEffect ->
            Local.effectPerform subEffect

        CommonEffect subEffect ->
            Common.effectPerform index subEffect


{-| Helps when your test needs "randomly" generated UUIDs
-}
simulateHardcodedUUIDs : Fifo UUID -> ProgramTest model msg (Effects msg) -> ProgramTest model msg (Effects msg)
simulateHardcodedUUIDs hardcodedUUIDs =
    ProgramTest.simulateLastEffect
        (\effects ->
            case effectsFoldHardcodedUUIDs hardcodedUUIDs effects of
                Ok [] ->
                    Err "No UUID generation effects found"

                result ->
                    result
        )


hardcodedUUIDsApplier :
    Effect msg
    -> ( Fifo UUID, Result String (List msg) )
    -> ( Fifo UUID, Result String (List msg) )
hardcodedUUIDsApplier effect ( leftUUIDs, accu ) =
    case ( accu, Fifo.remove leftUUIDs, effect ) of
        ( Ok goodAccu, ( Just hardcodedUUID, tail ), CommonEffect (Common.UUIDGenerator callback) ) ->
            ( tail, Ok <| callback hardcodedUUID :: goodAccu )

        ( Ok _, ( Nothing, _ ), CommonEffect (Common.UUIDGenerator _) ) ->
            ( leftUUIDs, Err <| "Not enougth UUIDs were provided" )

        _ ->
            ( leftUUIDs, accu )


effectsFoldHardcodedUUIDs : Fifo UUID -> Effects msg -> Result String (List msg)
effectsFoldHardcodedUUIDs hardcodedUUIDs =
    List.foldl
        hardcodedUUIDsApplier
        ( hardcodedUUIDs, Ok [] )
        >> Tuple.second
