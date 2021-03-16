module Shared.Interface exposing (..)

import Dict
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)

type alias UUID = String

type alias Data = { dataType: String, uuid: UUID, data: String }

type alias User = { uuid: UUID, nickname: String }

type alias ChatMessage = { user: User, text: String }

type alias State = { users: Dict.Dict UUID User, messages: List ChatMessage }

initState = { users = Dict.empty, messages = [] }

dataDecoder : Decoder Data
dataDecoder =
  JD.map3 Data
    (JD.field "dataType" JD.string)
    (JD.field "uuid" JD.string)
    (JD.field "data" JD.string)

dataEncoder : Data -> Value
dataEncoder data =
  JE.object
    [ ( "dataType", JE.string data.dataType )
    , ( "uuid", JE.string data.uuid )
    , ( "data", JE.string data.data )
    ]

simpleDataEncoder : String -> String -> Value
simpleDataEncoder dataType containedData =
  let
    finalData = Data dataType "" containedData
  in
    dataEncoder finalData

userDecoder : Decoder User
userDecoder =
  JD.map2 User
    (JD.field "uuid" JD.string)
    (JD.field "nickname" JD.string)

userEncoder : User -> Value
userEncoder user =
  JE.object
    [ ( "uuid", JE.string user.uuid )
    , ( "nickname", JE.string user.nickname )
    ]

chatMessageDecoder : Decoder ChatMessage
chatMessageDecoder =
  JD.map2 ChatMessage
    (JD.field "user" userDecoder)
    (JD.field "text" JD.string)

chatMessageEncoder : ChatMessage -> Value
chatMessageEncoder chatMessage =
  JE.object
    [ ( "user", userEncoder chatMessage.user )
    , ( "text", JE.string chatMessage.text )
    ]

stateDecoder : Decoder State
stateDecoder =
  JD.map2 State
    (JD.field "users" (JD.dict userDecoder))
    (JD.field "messages" (JD.list chatMessageDecoder))

stateEncoder : State -> Value
stateEncoder state =
  JE.object
    [ ( "users", JE.dict identity userEncoder state.users )
    , ( "messages", JE.list chatMessageEncoder state.messages )
    ]

makeOutput : String -> String -> String
makeOutput dataType data = (JE.encode 0 (simpleDataEncoder dataType data))
