port module Server2 exposing (..)

import Platform

type alias Flags = ()

type Msg
  = Noop
  | OutgoingMessage String

type alias Model = { users: List String }

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
      (model, Cmd.none)
    OutgoingMessage s ->
      (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ inputPort OutgoingMessage
    ]

port inputPort : (String -> msg) -> Sub msg

port outputPort : String -> Cmd msg
