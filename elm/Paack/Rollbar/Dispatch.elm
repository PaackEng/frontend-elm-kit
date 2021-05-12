module Paack.Rollbar.Dispatch exposing (sendError, sendResponseError)

{-| Composes the error effect
-}

import Dict
import Effects.Local as LocalEffects
import Json.Encode as Encode
import Paack.Effects as Effects exposing (Effects)
import Paack.Rollbar exposing (RollbarPayload(..))
import Paack.Rollbar.Effect as RollbarEffect
import Remote.Errors exposing (RemoteError)
import Remote.Response as Response exposing (Response)
import Rollbar


{-|

  - parent: The (Elm) message where did it occurred.
    In rollbar as "body"."message"."parent"
    E.g.: `"Pages.FleetAssignment.DriversFetched"`
  - payload.description: The error union identification.
    In rollbar as "body"."message"."description"
    E.g.: `"Api.Drivers.List.InternalServerError"`
  - payload.details: Custom additions to "body"."message"
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


sendResponseError :
    String
    -> (RemoteError transportError customError -> RollbarPayload)
    -> Response transportError customError object
    -> Effects msg
sendResponseError parent errorToPayload response =
    Response.toError response
        |> Maybe.map
            (errorToPayload >> sendError parent)
        |> Maybe.withDefault Effects.none
