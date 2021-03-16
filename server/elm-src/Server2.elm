port module Server2 exposing (..)

import Shared.Interface exposing (..)

import Platform
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
      (model, outputPort "abc")
    IncomingRawData s ->
      case JD.decodeString incomingDataDecoder s of
        Ok data ->
          case data.dataType of
            "connection" -> connection data model
            "disconnection" -> disconnection data model
            "nickname" -> (model, Cmd.none)
            "message" -> (model, Cmd.none)
            _ -> (model, Cmd.none)
        Err e -> (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ inputPort IncomingRawData
    ]

connection : IncomingData -> Model -> (Model, Cmd Msg)
connection data model =
  let
    newUser = User data.uuid ""
    oldState = model.state
    newState = { oldState | users = newUser :: oldState.users }
  in
    ({ model | state = newState }, sendState newState)

disconnection : IncomingData -> Model -> (Model, Cmd Msg)
disconnection data model =
  let
    _ = Debug.log "connection" data.uuid
  in
    (model, Cmd.none)

sendState : State -> Cmd msg
sendState s = outputPort (JE.encode 0 (stateEncoder s))

port inputPort : (String -> msg) -> Sub msg
port outputPort : String -> Cmd msg
