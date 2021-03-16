port module Server exposing (..)

import Interface exposing (..)

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
        )

import WebSocketFramework exposing (decodePlist, unknownMessage)

type alias ServerModel =
    ()

serverModel : ServerModel
serverModel =
    ()

encodeDecode : EncodeDecode Message
encodeDecode =
    { encoder = messageEncoder
    , decoder = messageDecoder
    , errorWrapper = Nothing
    }

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

main = program serverModel userFunctions (Just True)

port inputPort : InputPort msg

port outputPort : OutputPort msg
