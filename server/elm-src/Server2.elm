port module Server2 exposing (..)

import Platform
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE

type alias Flags = ()

type Msg
  = Noop
  | IncomingRawData String

type alias IncomingData = { dataType: String, uuid: String, data: String }

type alias User = { uuid: String, nickname: String }

type alias Model = { users: List User }

initModel = { users = [] }

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
            "disconnection" -> (model, Cmd.none)
            "nickname" -> (model, Cmd.none)
            "message" -> (model, Cmd.none)
            _ -> (model, Cmd.none)
        Err e -> (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ inputPort IncomingRawData
    ]

incomingDataDecoder : Decoder IncomingData
incomingDataDecoder =
  JD.map3 IncomingData
    (JD.field "dataType" JD.string)
    (JD.field "uuid" JD.string)
    (JD.field "data" JD.string)

connection : IncomingData -> Model -> (Model, Cmd Msg)
connection data model =
  let
    _ = Debug.log "connection" data.uuid
  in
    (model, Cmd.none)

port inputPort : (String -> msg) -> Sub msg
port outputPort : String -> Cmd msg
