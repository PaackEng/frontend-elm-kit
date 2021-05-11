module Paack.Auth.Session exposing (Session(..), getUser, hasAccess, hasRole, hasWriteAdmin, isLogged)

import Paack.Auth.Roles as Roles exposing (Roles)
import Paack.Auth.User as User exposing (User)


type Session
    = Logged User
    | NotLogged


getUser : Session -> Maybe User
getUser session =
    case session of
        Logged user ->
            Just user

        NotLogged ->
            Nothing


isLogged : Session -> Bool
isLogged session =
    case session of
        Logged _ ->
            True

        NotLogged ->
            False


hasRole : (Roles -> Bool) -> Session -> Bool
hasRole check session =
    case session of
        Logged user ->
            check (User.getRoles user)

        NotLogged ->
            False


hasAccess : Session -> Bool
hasAccess =
    hasRole Roles.hasAccess


hasWriteAdmin : Session -> Bool
hasWriteAdmin =
    hasRole Roles.hasWriteAdmin
