module Paack.Auth.User exposing (User, decoder, getData, getRoles, getToken)

import Iso8601
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as JsonPipe
import Paack.Auth.Roles as Roles exposing (Roles)
import Time


type alias Data =
    { email : Maybe String
    , emailVerified : Maybe Bool
    , familyName : Maybe String
    , givenName : Maybe String
    , locale : Maybe String
    , name : String
    , nickname : String
    , pictureUrl : Maybe String
    , sub : String
    , updatedAt : Time.Posix
    }


type User
    = User { token : String, data : Data, roles : Roles }


decoder : Decoder User
decoder =
    Decode.succeed
        (\data token roles -> User { token = token, data = data, roles = roles })
        |> JsonPipe.required "userData" dataDecoder
        |> JsonPipe.required "token" Decode.string
        |> JsonPipe.required "userData" Roles.decoder


dataDecoder : Decoder Data
dataDecoder =
    Decode.succeed Data
        |> JsonPipe.optional "email" (Decode.nullable Decode.string) Nothing
        |> JsonPipe.optional "email_verified" (Decode.nullable Decode.bool) Nothing
        |> JsonPipe.optional "family_name" (Decode.nullable Decode.string) Nothing
        |> JsonPipe.optional "given_name" (Decode.nullable Decode.string) Nothing
        |> JsonPipe.optional "locale" (Decode.nullable Decode.string) Nothing
        |> JsonPipe.required "name" Decode.string
        |> JsonPipe.required "nickname" Decode.string
        |> JsonPipe.optional "picture" (Decode.nullable Decode.string) Nothing
        |> JsonPipe.required "sub" Decode.string
        |> JsonPipe.required "updated_at" Iso8601.decoder


getToken : User -> String
getToken (User { token }) =
    token


getData : User -> Data
getData (User { data }) =
    data


getRoles : User -> Roles
getRoles (User { roles }) =
    roles
