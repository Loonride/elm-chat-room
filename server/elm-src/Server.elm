port module Server exposing (..)

import Json.Encode as JE exposing (Value)

import WebSocketFramework.Server
    exposing
        ( ServerMessageSender
        , UserFunctions
        , program
        , sendToOne
        , verbose
        )

import WebSocketFramework.Types
    exposing
        ( EncodeDecode
        , Error
        , ErrorKind(..)
        , InputPort
        , OutputPort
        , ServerState
        , Plist
        , ReqRsp(..)
        )

import WebSocketFramework exposing (decodePlist, unknownMessage)

type alias Message =
    ()

type alias ServerModel =
    ()

serverModel : ServerModel
serverModel =
    ()

type alias GameState =
    ()

type alias Player =
    String

messageEncoder : Message -> ( ReqRsp, Plist )
messageEncoder message =
    ( Rsp "result"
    , [ ( "result", JE.string "result" )
        ]
    )

messageDecoder : ( ReqRsp, Plist ) -> Result String Message
messageDecoder ( reqrsp, plist ) =
    let
        _ = Debug.log "messageDecoder" ()
    in unknownMessage reqrsp

encodeDecode : EncodeDecode Message
encodeDecode =
    { encoder = messageEncoder
    , decoder = messageDecoder
    , errorWrapper = Nothing
    }

messageProcessor : ServerState GameState Player -> Message -> ( ServerState GameState Player, Maybe Message )
messageProcessor state message =
    let
        _ = Debug.log "messageProcessor" ()
    in (state, Nothing)

messageSender : ServerMessageSender ServerModel Message GameState Player
messageSender model socket state request response =
    ( model, sendToOne messageEncoder response outputPort socket )

userFunctions : UserFunctions ServerModel Message GameState Player
userFunctions =
    { encodeDecode = encodeDecode
    , messageProcessor = messageProcessor
    , messageSender = messageSender
    , messageToGameid = Nothing
    , messageToPlayerid = Nothing
    , autoDeleteGame = Nothing
    , gamesDeleter = Nothing
    , playersDeleter = Nothing
    , inputPort = inputPort
    , outputPort = outputPort
    }

main = program serverModel userFunctions Nothing

port inputPort : InputPort msg

port outputPort : OutputPort msg
