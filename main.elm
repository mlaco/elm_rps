import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Random exposing (int, Generator, map)
import Array exposing (..)


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
  }


init : (Model, Cmd Msg)
init =
  let
    player1 = Player 0 0
    player2 = Player 0 0
    newModel =
      Model player1 player2
  in
    ( newModel , Cmd.none )


-- LOGIC

throwGenerator : Generator Throw
throwGenerator =
  int 0 2

calculateScores : Player -> Player -> Model
calculateScores p1 p2 =
  let
    throw1 = p1.throw
    throw2 = p2.throw
  in
    { player1 = p1
    , player2 = p2
    }



-- UPDATE

-- "Throw" is both a verb and noun in RPS, so ThrowThrow means you Throw (v) a Throw (n), (e.g. "throw rock")
type Msg
  = ThrowThrow Throw
  | AiThrow Throw

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ThrowThrow throw ->
      let
        p1 = model.player1
        newP1 = { p1 | throw = throw }
      in
        ( { model | player1 = newP1 } , Random.generate AiThrow throwGenerator )

    AiThrow throw ->
      let
        p1 = model.player1
        p2 = model.player2
        p2NewThrow = { p2 | throw = throw }
        newModel = ( calculateScores p1 p2NewThrow )
      in
        ( newModel , Cmd.none )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


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
                ++ ( toString model.player1.throw )
                ++ " | "
                ++ ( toString model.player2.throw )
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
     ]
