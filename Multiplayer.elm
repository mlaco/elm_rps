module Multiplayer exposing (..)

import Msg exposing (..)
import Model exposing (..)

import Phoenix.Channel as Channel
import Phoenix.Socket as Socket exposing (Socket)
import Json.Encode as JE
import Phoenix.Push as Push

socketInit : Socket Msg
socketInit =
  "ws://localhost:4000/socket/websocket"
  |> Socket.init
--|> Socket.on "new:msg" "rooms:lobby" ReceiveChatMessage
-- Something like this ^
-- I believe the arguments go:
-- message, channel, handler

-- Socket.on registers event handlers

sendThrowToServer : Socket.Socket Msg -> Player -> (Socket.Socket Msg, Cmd (Socket.Msg Msg))
sendThrowToServer socket player =
  let
    payload = Debug.log "payload" (toString player.throw)
    payloadJSON = (JE.object [("payload", JE.string payload)])
    cargo = Push.init "update" "game:lobby"
            |> Push.withPayload payloadJSON

  in
    Socket.push cargo socket

joinGameUpdate : Model -> ( Model , Cmd Msg )
joinGameUpdate model =
  let
    game = Debug.log "topic" "game:lobby"
    channel = Channel.init game
              |> Channel.onJoin JoinedGame
              |> Channel.onClose LeftGame
    ( socket, phxCmd ) = Socket.join channel model.socket
  in
    ( { model | socket = socket } , Cmd.map PhoenixMsg phxCmd )

phoenixUpdate : Socket.Msg Msg -> Model -> ( Model, Cmd Msg )
phoenixUpdate msg model =
  let
    ( socket, phxCmd ) = Socket.update msg model.socket
  in
    ( { model | socket = socket } , Cmd.map PhoenixMsg phxCmd )
