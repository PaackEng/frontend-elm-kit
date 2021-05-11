module Paack.Rollbar.Dispatch exposing (Channel(..), Effect(..), Payload, sendError)

{-| Composes the error effect
-}

import Effects.Local as LocalEffects
import Paack.Effects as Effects
import Paack.Rollbar exposing (RollbarPayload(..))
import Paack.Rollbar.Effect as RollbarEffect
import Rollbar


{-|

  - parent:
    The (Elm) message where did it occurred.
    In rollbar as "body"."message"."parent"
    E.g.: `"Pages.FleetAssignment.DriversFetched"`
  - payload.description:
    The error union identification.
    In rollbar as "body"."message"."description"
    E.g.: `"Api.Drivers.List.InternalServerError"`
  - payload.details:
    Custom additions to "body"."message"
    E.g.: `Dict.fromList [ "bad-status", (Encode.int 404) ]`

-}
sendError :
    String
    -> RollbarPayload
    -> Effects msg
sendError parent payload =
    case payload of
        NotToRoll ->
            Effects.none

        RollError { description, details } ->
            RollbarEffect.Send
                { body =
                    details
                        |> Dict.insert "description" (Encode.string description)
                        |> Dict.insert "parent" (Encode.string parent)
                , title =
                    parent ++ "/" ++ description
                , level =
                    Rollbar.Error
                }
                |> LocalEffects.RollbarEffect
                |> Effects.fromLocal
