port module Client.Client exposing (main)

import Shared.Interface exposing (..)

import Browser
import Browser.Events
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)
import Html exposing (Html, button, input, text, div)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)

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
      case JD.decodeString dataDecoder s of
        Ok data ->
          case data.dataType of
            "state" -> (updateState model data.data, Cmd.none)
            _ -> (model, Cmd.none)
        Err e -> (model, Cmd.none)
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
      users = div [] [ text (Debug.toString model.state.users) ]
      messages = div [] [ text (Debug.toString model.state.messages) ]
    in
      
      div (List.map (\(k, v) -> style k v) styles)
        [ box
        , btn
        , users
        , messages
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ inputPort IncomingRawData
    ]

updateState : Model -> String -> Model
updateState model rawStateData =
  case JD.decodeString stateDecoder rawStateData of
      Ok newState -> { model | state = newState }
      Err e -> model

port inputPort : (String -> msg) -> Sub msg
port outputPort : String -> Cmd msg
