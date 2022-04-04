module Paack.Program exposing (Program, browserApplication)

import Browser exposing (UrlRequest)
import Main.Model exposing (Flags, Model)
import Main.Msg exposing (Msg)
import Main.Pages exposing (PageModel)
import Paack.Effects.MainHelper exposing (PerformerModel, performedInit, performedUpdate)
import UI.Document as UI exposing (Document)
import UI.RenderConfig exposing (RenderConfig)
import Url exposing (Url)


type alias Program =
    Platform.Program Flags PerformerModel Msg


type alias ProgramData =
    { view : Model -> Document PageModel Msg
    , subscriptions : Model -> Sub Msg
    , onUrlRequest : UrlRequest -> Msg
    , onUrlChange : Url -> Msg
    , getRenderConfig : Model -> RenderConfig
    , getPage : Model -> PageModel
    }


browserApplication : ProgramData -> Program
browserApplication data =
    Browser.application
        { init = performedInit
        , view =
            \{ appModel } ->
                data.view appModel
                    |> UI.toBrowserDocument
                        (data.getRenderConfig appModel)
                        (data.getPage appModel)
        , update = performedUpdate
        , onUrlRequest = data.onUrlRequest
        , onUrlChange = data.onUrlChange
        , subscriptions = .appModel >> data.subscriptions
        }
