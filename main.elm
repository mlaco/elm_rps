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


-- LOGIC

throwArray : Array Throw
throwArray =
  fromList [ Rock
  , Paper
  , Scissors
  , None
  ]

getFromThrowArray : Int -> Throw
getFromThrowArray n =
  let
    elem =
      case ( get n throwArray ) of
        Just a ->
          a
        Nothing ->
          None
  in
    elem


throwGenerator : Generator Throw
throwGenerator =
  Random.map getFromThrowArray ( int 0 2 )


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
        p2 = model.player2
        newP2 = { p2 | throw = throw }
      in
        ( { model | player2 = newP2 } , Cmd.none )


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
            [ onClick (ThrowThrow Rock) ]
            [ text "Rock" ]
        , button
            [ onClick (ThrowThrow Paper) ]
            [ text "Paper" ]
        , button
            [ onClick (ThrowThrow Scissors) ]
            [ text "Scissors" ]
        ]
     ]
