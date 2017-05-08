module Model exposing (..)

import Phoenix.Socket as Socket exposing (Socket)
import Throw exposing (..)
import Msg exposing (Msg)
-- import Phoenix.Channel as Channel

type alias Player =
  { score : Int
  , throw : Throw
  }

type alias Model =
  { player1 : Player
  , player2 : Player
  , socket : Socket.Socket Msg
  , connected : Bool
  }
  
calculateScores : Model -> Model
calculateScores model =
  let
    p1 = model.player1
    p2 = model.player2
    (score1 , score2) =
      case ( 3 + p1.throw - p2.throw ) % 3 of
        1 ->
          (p1.score + 1 , p2.score)
        2 ->
          (p1.score , p2.score + 1)
        _ ->
          (p1.score , p2.score)

    newP1 = { p1 | score = score1 }
    newP2 = { p2 | score = score2 }
  in
    { model
    | player1 = newP1
    , player2 = newP2
    }
