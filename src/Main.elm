module Main exposing (main, update, view)

import Browser
import Html exposing (div, text)


main =
    Browser.sandbox { init = 0, update = update, view = view }


update msg model =
    model


view model =
    div []
        [ text "TicTacToe"
        ]
