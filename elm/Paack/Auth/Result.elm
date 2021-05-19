module Paack.Auth.Result exposing (Error(..), Result, decode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JsonPipe
import Paack.Auth.User as User exposing (User)


type alias Result =
    Result.Result Error User


type Error
    = AuthenticationFailed { description : String }
    | NoSession
    | DecodeError Decode.Error


decode : Decode.Value -> Result
decode value =
    Decode.decodeValue
        (Decode.oneOf
            [ User.decoder |> Decode.map Result.Ok
            , errorDecoder |> Decode.map Result.Err
            ]
        )
        value
        |> Result.mapError (DecodeError >> Result.Err)
        |> merge


errorDecoder : Decoder Error
errorDecoder =
    Decode.succeed
        Tuple.pair
        |> JsonPipe.required "error" Decode.string
        |> JsonPipe.required "errorDescription" Decode.string
        |> Decode.andThen
            (\( error, errorDescription ) ->
                case error of
                    "AUTH_FAILED" ->
                        Decode.succeed <| AuthenticationFailed { description = errorDescription }

                    "NO_SESSION" ->
                        Decode.succeed NoSession

                    _ ->
                        Decode.fail errorDescription
            )


merge : Result.Result a a -> a
merge result =
    case result of
        Result.Ok success ->
            success

        Result.Err error ->
            error
