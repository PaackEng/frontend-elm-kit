module Paack.ProgramTest exposing (ProgramDefinition, createApplication)

import Browser exposing (UrlRequest)
import Main.Model as Model exposing (Flags, Model)
import Main.Msg exposing (Msg)
import Main.Pages exposing (PageModel)
import Main.Update exposing (update)
import Main.View exposing (view)
import Paack.Effects exposing (Effects)
import ProgramTest
import UI.Document as UI
import UI.RenderConfig exposing (RenderConfig)
import Url exposing (Url)


type alias ProgramDefinition =
    ProgramTest.ProgramDefinition Flags Model Msg (Effects Msg)


type alias ProgramData =
    { onUrlRequest : UrlRequest -> Msg
    , onUrlChange : Url -> Msg
    , getRenderConfig : Model -> RenderConfig
    , getPage : Model -> PageModel
    }


createApplication : ProgramData -> ProgramDefinition
createApplication data =
    ProgramTest.createApplication
        { init = Model.init
        , view =
            \model ->
                view model
                    |> UI.toBrowserDocument
                        (data.getRenderConfig model)
                        (data.getPage model)
        , update = update
        , onUrlRequest = data.onUrlRequest
        , onUrlChange = data.onUrlChange
        }
