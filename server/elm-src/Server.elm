port module Server exposing (..)

import Shared.Interface exposing (..)

import Platform
import Dict
import Json.Decode as JD
import Json.Encode as JE

type alias Flags = ()

type Msg
  = Noop
  | IncomingRawData String

type alias Model = { state: State }

initModel = { state = initState }

main : Program Flags Model Msg
main =
  Platform.worker
    { init = init
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
            "connection" -> connection data model
            "disconnection" -> disconnection data model
            "nickname" -> nickname data model
            "message" -> message data model
            _ -> (model, Cmd.none)
        Err e -> (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ inputPort IncomingRawData
    ]

connection : Data -> Model -> (Model, Cmd Msg)
connection data model =
  let
    newUser = User data.uuid ""
    oldState = model.state
    newState = { oldState | users = Dict.insert newUser.uuid newUser oldState.users }
  in
    ({ model | state = newState }, sendState newState)

disconnection : Data -> Model -> (Model, Cmd Msg)
disconnection data model =
  let
    oldState = model.state
    newState = { oldState | users = Dict.remove data.uuid oldState.users }
  in
    ({ model | state = newState }, sendState newState)

updateNickname : String -> Maybe User -> Maybe User
updateNickname nick maybeUser =
  case maybeUser of
    Just u -> Just { u | nickname = nick}
    Nothing -> Nothing

nickname : Data -> Model -> (Model, Cmd Msg)
nickname data model =
  let
    oldState = model.state
    newState = { oldState | users = Dict.update data.uuid (updateNickname data.data) oldState.users }
  in
    ({ model | state = newState }, Cmd.none)

message : Data -> Model -> (Model, Cmd Msg)
message data model =
  if data.data == "" then (model, Cmd.none)
  else
    case Dict.get data.uuid model.state.users of
      Just user ->
        let
          oldState = model.state
          msg = ChatMessage user data.data
          newState = { oldState | messages = List.take 20 (msg :: oldState.messages) }
        in
          ({ model | state = newState }, sendState newState)
      Nothing -> (model, Cmd.none)

sendState : State -> Cmd msg
sendState s =
  let
    stateData = JE.encode 0 (stateEncoder s)
  in
    outputPort (makeOutput "state" "" stateData)

port inputPort : (String -> msg) -> Sub msg
port outputPort : String -> Cmd msg
