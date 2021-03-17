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
  | MessageChange String
  | NicknameChange String
  | SendClick

type alias Model = { messageContent: String, nicknameContent: String, state: State }

initModel = { messageContent = "", nicknameContent = "", state = initState }

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
    MessageChange s ->
      ({ model | messageContent = s }, Cmd.none)
    NicknameChange s ->
      ({ model | nicknameContent = s }, outputPort (makeOutput "nickname" "" s))
    SendClick ->
      ({ model | messageContent = "" }, outputPort (makeOutput "message" "" model.messageContent))

view : Model -> Html Msg
view model =
    let
      styles = []
        -- [ ("position", "fixed")
        -- , ("top", "50%")
        -- , ("left", "50%")
        -- , ("transform", "translate(-50%, -50%)")
        -- ]
      
      nickBox = input [ placeholder "Set nickname", value model.nicknameContent, onInput NicknameChange ] []
      msgBox = input [ placeholder "Say hello...", value model.messageContent, onInput MessageChange ] []
      btn = button [ onClick SendClick ] [ text "Send" ]
      users = div [] [ text (Debug.toString model.state.users) ]
      messages = div [] [ text (Debug.toString model.state.messages) ]
    in
      
      div (List.map (\(k, v) -> style k v) styles)
        [ div [] [nickBox]
        , div [] [msgBox, btn]
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
