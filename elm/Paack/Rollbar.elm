module Paack.Rollbar exposing
    ( RollbarErrorPayload
    , RollbarPayload(..)
    , codedErrorPayload
    , errorPayload
    , notToRoll
    , prependDescription
    , withEntry
    , withPagination
    )

{-| Composes the error payload
-}

import Dict exposing (Dict)
import Graphql.Http as GraphqlHttp
import Graphql.Http.GraphqlError as GraphqlError
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Rollbar
import Task exposing (Task)


type alias RollbarErrorPayload =
    { description : String
    , details : Dict String Value
    }


type RollbarPayload
    = RollError RollbarErrorPayload
    | NotToRoll


notToRoll : RollbarPayload
notToRoll =
    NotToRoll


errorPayload : String -> RollbarPayload
errorPayload description =
    RollError
        { description = description
        , details = Dict.empty
        }


{-| A shortcut for InternalServerError and any GraphqlError error with { code : String }
-}
codedErrorPayload : { description : String, code : String } -> RollbarPayload
codedErrorPayload { description, code } =
    RollError
        { description = description
        , details =
            Dict.insert "code"
                (Encode.string code)
                Dict.empty
        }


withEntry : String -> Value -> RollbarPayload -> RollbarPayload
withEntry key value payload =
    case payload of
        RollError ({ details } as error) ->
            RollError { error | details = Dict.insert key value details }

        NotToRoll ->
            payload


withPagination : { pageSize : Int, offset : Int } -> RollbarPayload -> RollbarPayload
withPagination { pageSize, offset } =
    Encode.object
        [ ( "page", Encode.int pageSize )
        , ( "offset", Encode.int offset )
        ]
        |> withEntry "pagination"


prependDescription : String -> RollbarPayload -> RollbarPayload
prependDescription parent payload =
    -- If ever needed, feel free to expose this function
    case payload of
        RollError ({ description } as error) ->
            RollError { error | description = parent ++ "/" ++ description }

        NotToRoll ->
            payload
