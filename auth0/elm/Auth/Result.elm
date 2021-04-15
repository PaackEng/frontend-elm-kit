module Auth.Result exposing (Error(..), Result, decode)

import Auth.User as User exposing (User)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JsonPipe


type alias Result =
    Result.Result Error User


type Error
    = AuthenticationError
        { error : String
        , errorDescription : String
        }
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
        (\error description ->
            AuthenticationError
                { error = error
                , errorDescription = description
                }
        )
        |> JsonPipe.required "error" Decode.string
        |> JsonPipe.required "errorDescription" Decode.string


merge : Result.Result a a -> a
merge result =
    case result of
        Result.Ok success ->
            success

        Result.Err error ->
            error
