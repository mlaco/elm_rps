module Msg exposing (..)

import Throw exposing (..)

import Json.Encode as JE
import Phoenix.Socket as Socket exposing (Socket)

-- "Throw" is both a verb and noun in RPS, so ThrowThrow means you Throw (v) a Throw (n), (e.g. "throw rock")
type Msg
  = ThrowThrow Throw
  | JoinGame
  | JoinedGame JE.Value
  | LeftGame JE.Value
  | PhoenixMsg (Socket.Msg Msg)
