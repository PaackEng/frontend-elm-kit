module Auth.Roles exposing (Roles, decoder, hasAccess, hasWriteAdmin, isWarehouseAdmin, isWarehouseOperator)

{-|

    @docs Roles, decoder

    @docs isWarehouseOperator, isWarehouseAdmin

    @decoder hasAccess, hasWriteAdmin

-}

import Json.Decode as Decode exposing (Decoder)


type Role
    = WarehouseOperator
    | WarehouseManager
    | Unrecognized String -- Why would an extra/new role be considered a failure?


type Roles
    = Roles (List Role)


decoder : Decoder Roles
decoder =
    roleDecoder
        |> Decode.list
        |> Decode.field "https://paack.app/roles"
        |> Decode.maybe
        |> Decode.map (Maybe.withDefault [] >> Roles)


roleDecoder : Decoder Role
roleDecoder =
    let
        match string =
            case string of
                "Warehouse operator" ->
                    WarehouseOperator

                "Warehouse manager" ->
                    WarehouseManager

                unrecognized ->
                    Unrecognized unrecognized
    in
    Decode.map match Decode.string


is : Role -> Roles -> Bool
is role (Roles roles) =
    List.member role roles


isWarehouseOperator : Roles -> Bool
isWarehouseOperator =
    is WarehouseOperator


isWarehouseAdmin : Roles -> Bool
isWarehouseAdmin =
    is WarehouseManager


isAny : List Role -> Roles -> Bool
isAny candidates (Roles roles) =
    List.any
        (\role -> List.any ((==) role) candidates)
        roles


hasAccess : Roles -> Bool
hasAccess =
    isAny [ WarehouseOperator, WarehouseManager ]


hasWriteAdmin : Roles -> Bool
hasWriteAdmin =
    isWarehouseAdmin
