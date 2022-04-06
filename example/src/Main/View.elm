module Main.View exposing (view)

import Element exposing (text)
import Main.Model exposing (Model)
import Main.Msg as Msg exposing (Msg)
import Main.Pages exposing (PageModel)
import Paack.Auth.User as User
import UI.Document as UI


view : Model -> UI.Document PageModel Msg
view model =
    UI.document
        Msg.ForUI
        model.ui
        (pageContainer model)


pageContainer : Model -> PageModel -> UI.Page Msg
pageContainer model _ =
    let
        title =
            "frontend-elm-kit example"

        body =
            case model.user of
                Just user ->
                    [ text "User name: ", User.getData user |> .name |> text ]

                Nothing ->
                    [ text "Authenticating..." ]
    in
    body
        |> Element.column []
        |> UI.bodySingle
        |> UI.page title
