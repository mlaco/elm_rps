import Html exposing (..)
-- import Html.Events exposing (..)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
    
    
-- MODEL

type Throw
  = Rock
  | Paper
  | Scissors
  | None

type alias Player =
  { score : Int
  , throw : Throw
  }

type alias Model =
  { player1 : Player
  , player2 : Player
  }
  
  
init : (Model, Cmd Msg)
init =
  let
    player1 = Player 0 None
    player2 = Player 0 None
    newModel =
      Model player1 player2
  in
    ( newModel , Cmd.none )
    
    
-- UPDATE

type Msg = Submit
  
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Submit ->
      ( model , Cmd.none )
        
        
-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
  
  
-- VIEW

view : Model -> Html Msg
view model =
  div
    [ ]
    [ text ( toString model.player1.score ) ]
