import Throw exposing (Throw)
import Model exposing (Player, Model)
import Msg exposing (..)
import Multiplayer exposing (..)
import GameView exposing (..)

import Phoenix.Socket as Socket exposing (Socket)
import Html exposing (..)
import Json.Encode as JE
import Array exposing (..)

main =
  Html.program
    { init = init
    , view = gameView
    , update = update
    , subscriptions = subscriptions
    }


init : (Model, Cmd Msg)
init =
  let
    player1 = Player 0 0
    player2 = Player 0 0
  in
    ( { player1 = player1
      , player2 = player2
      , socket = socketInit
      , connected = False
      }
    , Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
  Socket.listen model.socket PhoenixMsg
  --   if model.connected then
  --     Sub.batch
  --   else
  --     Socket.listen model.socket PhoenixMsg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ThrowThrow throw ->
      let
        p1 = model.player1
        newP1 = { p1 | throw = throw }
        newModel = { model | player1 = newP1 }
      in
        sendThrowToServer newModel.socket newModel

    JoinGame -> joinGameUpdate model
    JoinedGame game -> ({model | connected = True}, Cmd.none)
    LeftGame game -> ({ model | connected = False}, Cmd.none)
    PhoenixMsg msg -> phoenixUpdate msg model
