module Paack.Effects.MainHelper exposing (PerformerModel, effectsApplier, performedInit, performedUpdate)

import Browser.Navigation as Nav
import Effects.LocalPerformer as LocalPerformer
import Main.Model as Model exposing (Flags, Model)
import Main.Msg exposing (Msg)
import Main.Update exposing (update)
import Paack.Effects
import Paack.Effects.CommonPerformer as CommonPerformer
import Random
import UUID exposing (Seeds)
import Url exposing (Url)


type alias PerformerModel =
    { appModel : Model
    , key : Nav.Key
    , seeds : Seeds
    }


performedInit : Flags -> Url -> Nav.Key -> ( PerformerModel, Cmd Msg )
performedInit flags url key =
    let
        firstSeeds =
            Seeds
                (Random.initialSeed flags.randomSeed1)
                (Random.initialSeed flags.randomSeed2)
                (Random.initialSeed flags.randomSeed3)
                (Random.initialSeed flags.randomSeed4)

        ( appModel, effects ) =
            Model.init flags url ()

        ( newSeeds, cmds ) =
            Effects.apply
                (effectsApplier key)
                ( firstSeeds, Cmd.none )
                effects
    in
    ( { appModel = appModel, key = key, seeds = newSeeds }
    , cmds
    )


performedUpdate : Msg -> PerformerModel -> ( PerformerModel, Cmd Msg )
performedUpdate msg performerModel =
    let
        ( appModel, effects ) =
            update msg performerModel.appModel

        ( newSeeds, cmds ) =
            Effects.apply
                (effectsApplier performerModel.key)
                ( performerModel.seeds, Cmd.none )
                effects
    in
    ( { performerModel | appModel = appModel, seeds = newSeeds }
    , cmds
    )


effectsApplier : Nav.Key -> Effects.Effect Msg -> ( Seeds, Cmd Msg ) -> ( Seeds, Cmd Msg )
effectsApplier key effect ( seeds, accumulator ) =
    let
        ( newSeeds, cmd ) =
            effectPerform key seeds effect
    in
    ( newSeeds
    , Cmd.batch [ cmd, accumulator ]
    )


effectPerform : Nav.Key -> Seeds -> Effects.Effect Msg -> ( Seeds, Cmd Msg )
effectPerform key seeds effect =
    case effect of
        Effects.LocalEffect localEffect ->
            LocalPerformer.effectPerform key seeds localEffect

        Effects.CommonEffect commonEffect ->
            CommonPerformer.effectPerform key seeds commonEffect
