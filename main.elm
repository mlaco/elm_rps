import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


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

type Msg
  = Start
  | ThrowThrow Throw

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Start ->
      ( model , Cmd.none )
    ThrowThrow throw ->
      let
        oldPlayer1 = model.player1
        player1 = { oldPlayer1 | throw = throw }
      in
        ( { model | player1 = player1 } , Cmd.none )
        

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
