port module Client.Client exposing (main)

import Shared.Interface exposing (..)

import Browser
import Browser.Events
import Dict
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)
import Html exposing (Html, button, input, text, div, span)
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
          -- other message types could go here, but I chose to only send and handle a
          -- full state update message
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

userToHtml : User -> Html Msg
userToHtml user =
  div []
    [ span [] [text user.uuid]
    , span [] [text user.nickname]
    ]

messageToHtml : ChatMessage -> Html Msg
messageToHtml msg =
  let
    nick = if msg.user.nickname == "" then "Unnamed" else msg.user.nickname
  in
    div [class "msg"]
      [ span [class "nickname"] [text nick]
      , span [class "text"] [text msg.text]
      ]

view : Model -> Html Msg
view model =
    let
      nickBox = input [ placeholder "Set nickname", value model.nicknameContent, onInput NicknameChange ] []
      msgBox = input [ placeholder "Say hello...", value model.messageContent, onInput MessageChange ] []
      btn = button [ onClick SendClick ] [ text "Send" ]

      userList = List.map (\(_, v) -> v) (Dict.toList model.state.users)
      users = div [] (List.map userToHtml userList)
      onlineCount = div [] [ text ("Users online: " ++ (String.fromInt <| List.length userList)) ]
      messages = div [id "messages-cont"] [ div [id "messages"] (List.reverse <| List.map messageToHtml model.state.messages) ]
    in
      div [id "main-cont"]
        [ messages
        , div [] [nickBox]
        , div [] [msgBox, btn]
        , onlineCount
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ inputPort IncomingRawData
    ]

-- update the local state based on a state update sent from the server
updateState : Model -> String -> Model
updateState model rawStateData =
  case JD.decodeString stateDecoder rawStateData of
      Ok newState -> { model | state = newState }
      Err e -> model

port inputPort : (String -> msg) -> Sub msg
port outputPort : String -> Cmd msg
