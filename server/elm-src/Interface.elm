module Interface exposing (..)

import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)

import WebSocketFramework exposing (decodePlist, unknownMessage)
import WebSocketFramework.Types exposing (Plist, ReqRsp(..), ServerState)

type alias GameState =
    ()

type alias Player =
    String

type Message
    = SentMessage String
    | ResultMessage String

messageEncoder : Message -> ( ReqRsp, Plist )
messageEncoder message =
    case message of
        SentMessage result ->
            ( Req "sent"
            , [ ( "sent", JE.string result )
              ]
            )
        ResultMessage result ->
            ( Rsp "result"
            , [ ( "result", JE.string result )
              ]
            )

sentDecoder : Decoder Message
sentDecoder =
    JD.map SentMessage
        (JD.field "sent" JD.string)

resultDecoder : Decoder Message
resultDecoder =
    JD.map ResultMessage
        (JD.field "result" JD.string)

messageDecoder : ( ReqRsp, Plist ) -> Result String Message
messageDecoder ( reqrsp, plist ) =
    case reqrsp of
        Req msg ->
            case msg of
                "sent" ->
                    decodePlist sentDecoder plist
                _ ->
                    unknownMessage reqrsp

        Rsp msg ->
            case msg of
                "result" ->
                    decodePlist resultDecoder plist
                _ ->
                    unknownMessage reqrsp

messageProcessor : ServerState GameState Player -> Message -> ( ServerState GameState Player, Maybe Message )
messageProcessor state message =
    case message of
        SentMessage str ->
            ( state
            , Just (ResultMessage "hello world")
            )
        _ -> (state, Nothing)
