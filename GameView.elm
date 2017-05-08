module GameView exposing (gameView)

import Msg exposing (..)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Array exposing (..)

translateThrow : Int -> String
translateThrow n  =
  case get n (fromList ["Rock","Paper","Scissors"]) of
    Just a -> a
    Nothing -> "Nothing"


gameView : Model -> Html Msg
gameView model =
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
