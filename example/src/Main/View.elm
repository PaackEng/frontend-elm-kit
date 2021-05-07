module Main.View exposing (view)

import Browser
import Html exposing (..)
import Main.Model exposing (Model)
import Paack.Auth.User as User


view : Model -> Browser.Document msg
view model =
    { title = "frontend-elm-kit example"
    , body =
        case model.user of
            Just user ->
                [ text "User name: ", User.getData user |> .name |> text ]

            Nothing ->
                [ text "Authenticating..." ]
    }
