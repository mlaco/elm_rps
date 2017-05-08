import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Random exposing (int, Generator, map)
import Array exposing (..)
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Json.Encode as JE

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Throw = Int

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


-- Multiplayer

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

-- LOGIC

throwGenerator : Generator Throw
throwGenerator =
  int 0 2

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

translateThrow : Int -> String
translateThrow n  =
  case get n (fromList ["Rock","Paper","Scissors"]) of
    Just a -> a
    Nothing -> "Nothing"


-- UPDATE

-- "Throw" is both a verb and noun in RPS, so ThrowThrow means you Throw (v) a Throw (n), (e.g. "throw rock")
type Msg
  = ThrowThrow Throw
  | AiThrow Throw
  | JoinGame
  | JoinedGame JE.Value
  | LeftGame JE.Value
  | PhoenixMsg (Socket.Msg Msg)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ThrowThrow throw ->
      let
        p1 = model.player1
        newP1 = { p1 | throw = throw }
        
        -- Tell server our throw
        --
        -- (Note: This call doesn't affect the game at all currently I am doing
        -- this to learn how to perform socket operations Once successful, we'll
        -- replace the random AiThrow with the opponent's throw via the server)
        (a , b) = sendThrowToServer model.socket newP1
        
      in
        ( { model | player1 = newP1 } , Random.generate AiThrow throwGenerator )

    AiThrow throw ->
      let
        p1 = model.player1
        p2 = model.player2
        p2NewThrow = { p2 | throw = throw }
        tempModel =
          { model
          | player1 = p1
          , player2 = p2NewThrow
          }
        newModel = ( calculateScores tempModel )
      in
        ( newModel , Cmd.none )
    JoinGame -> joinGameUpdate model
    JoinedGame game -> ({ model | connected = True}, Cmd.none)
    LeftGame game -> ({ model | connected = False}, Cmd.none)
    PhoenixMsg msg -> phoenixUpdate msg model


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


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
--   if model.connected then
--     Sub.batch
--   else
--     Socket.listen model.socket PhoenixMsg


-- VIEW

view : Model -> Html Msg
view model =
  let
    myStyle = style
      [ ("background-color", "#333")
      , ("color" , "#eee")
      ]
    divStyle = style
      [ ("margin-left" ,  "auto")
      , ("margin-right" ,  "auto")
      , ("width" , "60%")
      , ("padding-top", "50px")
      ]
  in
    body
     [ myStyle ]
     [
       div
         [ divStyle ]
         [ div
             [ ]
             [ text
                 ( "Score: "
                 ++ ( toString model.player1.score )
                 ++ " | "
                 ++ ( toString model.player2.score )
                 )
             ]
         , div
             [ ]
             [ text
                 ( "Throws: "
                 ++ ( (translateThrow model.player1.throw) )
                 ++ " | "
                 ++ ( (translateThrow model.player2.throw) )
                 )
             ]
         , button
             [ onClick (ThrowThrow 0) ]
             [ text "Rock" ]
         , button
             [ onClick (ThrowThrow 1) ]
             [ text "Paper" ]
         , button
             [ onClick (ThrowThrow 2) ]
             [ text "Scissors" ]
         ]
       , div
         [ divStyle ]
         [
           button
             [ onClick JoinGame ]
             [ text "Join" ]
         ]
     ]
