import Throw exposing (Throw)
import Model exposing (Player, Model)
import Msg exposing (..)
import Multiplayer exposing (..)
import GameView exposing (..)

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
  Sub.none
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
        
        -- Tell server our throw
        (socket, phxMsg) = sendThrowToServer model.socket newP1
        
      in
        ( model, Cmd.map PhoenixMsg phxMsg)

    JoinGame -> joinGameUpdate model
    JoinedGame game -> ({model | connected = True}, Cmd.none)
    LeftGame game -> ({ model | connected = False}, Cmd.none)
    PhoenixMsg msg -> phoenixUpdate msg model
