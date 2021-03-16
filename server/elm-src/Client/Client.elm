port module Client.Client exposing (main)

import Shared.Interface exposing (..)

import Browser
import Browser.Events
import Json.Decode as Decode
import Html exposing (Html, button, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import WebSocketFramework.Types exposing (OutputPort)

type alias Flags = ()

type Msg
  = Noop
  | IncomingRawData String
  | InputChange String
  | SendClick

type alias Model = { inputContent: String, state: State }

initModel = { inputContent = "", state = initState }

main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : Flags -> (Model, Cmd Msg)
init () =
  (initModel, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Noop ->
      (model, Cmd.none)
    IncomingRawData s ->
      let
        _ = Debug.log s ()
      in
        (model, Cmd.none)
    InputChange s ->
      ({ model | inputContent = s }, Cmd.none)
    SendClick ->
      (model, outputPort model.inputContent)

view : Model -> Html Msg
view model =
    let
      styles = []
        -- [ ("position", "fixed")
        -- , ("top", "50%")
        -- , ("left", "50%")
        -- , ("transform", "translate(-50%, -50%)")
        -- ]
      
      box = input [ placeholder "Say hello...", value model.inputContent, onInput InputChange ] []
      btn = button [ onClick SendClick ] [ text "Send" ]
    in
      
      Html.div (List.map (\(k, v) -> style k v) styles) [box, btn]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ inputPort IncomingRawData
    ]

port inputPort : (String -> msg) -> Sub msg
port outputPort : String -> Cmd msg
