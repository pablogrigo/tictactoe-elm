module Main exposing (main, update, view)

import Browser
import Html exposing (Html, br, button, div, form, h1, h2, h3, h4, li, nav, p, span, text, ul)
import Html.Attributes exposing (class, disabled, type_)
import Html.Events exposing (onClick, onSubmit)


type Player
    = X
    | O


type Cell
    = A
    | B
    | C
    | D
    | E
    | F
    | G
    | H
    | I


type GameStatus
    = Moves Player
    | Wins Player
    | Tie


type alias Movement =
    { cell : Cell
    , player : Player
    }


type alias Model =
    { movements : List Movement
    , initial : Player
    }


otherPlayer : Player -> Player
otherPlayer player =
    case player of
        X ->
            O

        O ->
            X


allCells : List Cell
allCells =
    [ A, B, C, D, E, F, G, H, I ]


cellGroups : List (List Cell)
cellGroups =
    [ [ A, B, C ]
    , [ D, E, F ]
    , [ G, H, I ]
    , [ A, D, G ]
    , [ B, E, H ]
    , [ C, F, I ]
    , [ A, E, I ]
    , [ C, E, G ]
    ]


lastMovement : List Movement -> Maybe Movement
lastMovement movements =
    movements |> List.reverse |> List.head


isWinner : List Movement -> Player -> Bool
isWinner movements player =
    let
        playerMovements =
            List.filter (\movement -> movement.player == player) movements

        playerCells =
            List.map (\movement -> movement.cell) playerMovements
    in
    cellGroups |> List.any (\group -> group |> List.all (\cell -> playerCells |> List.member cell))


status : List Movement -> Player -> GameStatus
status movements initialPlayer =
    let
        allCellsUsed =
            List.all (\cell -> not (List.isEmpty (List.filter (\movement -> movement.cell == cell) movements))) allCells
    in
    if isWinner movements X then
        Wins X

    else if isWinner movements O then
        Wins O

    else if allCellsUsed then
        Tie

    else
        case lastMovement movements of
            Just { cell, player } ->
                Moves (otherPlayer player)

            Nothing ->
                Moves initialPlayer


cellString : Cell -> String
cellString cell =
    case cell of
        A ->
            "A"

        B ->
            "B"

        C ->
            "C"

        D ->
            "D"

        E ->
            "E"

        F ->
            "F"

        G ->
            "G"

        H ->
            "H"

        I ->
            "I"


playerString : Player -> String
playerString player =
    case player of
        X ->
            "X"

        O ->
            "O"


maybePlayerString : Maybe Player -> String
maybePlayerString maybePlayer =
    case maybePlayer of
        Just player ->
            playerString player

        Nothing ->
            ""


type Msg
    = Move Cell
    | Reset


main =
    Browser.sandbox { init = init, update = update, view = view }


init : Model
init =
    { movements = []
    , initial = X
    }


movementForCell : Cell -> List Movement -> Maybe Movement
movementForCell cell movements =
    movements |> List.filter (\movement -> movement.cell == cell) |> List.head


update : Msg -> Model -> Model
update msg model =
    let
        gameStatus =
            status model.movements model.initial
    in
    case msg of
        Reset ->
            { init | initial = otherPlayer model.initial }

        Move cell ->
            case gameStatus of
                Tie ->
                    model

                Wins _ ->
                    model

                Moves player ->
                    if (model.movements |> movementForCell cell) == Nothing then
                        { model | movements = List.append model.movements [ { cell = cell, player = player } ] }

                    else
                        model


viewMovement : Movement -> Html msg
viewMovement movement =
    li [ class "list-group-item" ] [ text (playerString movement.player ++ "-" ++ cellString movement.cell) ]


viewMovements : List Movement -> Html Msg
viewMovements movements =
    if List.isEmpty movements then
        span [] [ text "-" ]

    else
        ul [ class "list-group" ] (List.map viewMovement movements)


viewStatus : GameStatus -> String
viewStatus gameStatus =
    case gameStatus of
        Tie ->
            "Tie"

        Moves player ->
            playerString player ++ " moves"

        Wins player ->
            playerString player ++ " wins \u{1F973}"


viewCell : List Movement -> Cell -> Html Msg
viewCell movements cell =
    let
        maybeMovement =
            movements |> movementForCell cell

        maybePlayer =
            case maybeMovement of
                Just movement ->
                    Just movement.player

                Nothing ->
                    Nothing

        isCellUsed =
            maybeMovement /= Nothing
    in
    div [ class "board__cell", onClick (Move cell), disabled isCellUsed ] [ text (maybePlayerString maybePlayer) ]


viewCells : List Movement -> List (Html Msg)
viewCells movements =
    allCells |> List.map (viewCell movements)


viewNavigationBar : Html Msg
viewNavigationBar =
    nav [ class "navbar sticky-top navbar-light bg-light" ]
        [ span [ class "navbar-brand mb-0 h1" ] [ text "TicTacToe ", span [ class "badge badge-pill badge-dark" ] [ text "elm" ] ]
        , form [ class "form-inline my-2 my-lg-0", onSubmit Reset ]
            [ button [ class "btn btn-sm btn-primary my-2 my-sm-0", onClick Reset ] [ text "Restart" ]
            ]
        ]


view model =
    let
        gameStatus =
            status model.movements model.initial
    in
    div []
        [ viewNavigationBar
        , div [ class "container" ]
            [ div [ class "row mb-2" ]
                [ div [ class "col-md-3 mt-4 text-center" ]
                    [ p [ class "h5 text-muted" ] [ text "Status" ]
                    , h3 [] [ gameStatus |> viewStatus |> text ]
                    ]
                , div [ class "col-md-6 mt-4 text-center d-flex justify-content-center" ]
                    [ div [ class "board" ] (viewCells model.movements)
                    ]
                , div [ class "col-md-3 mt-4 text-center info__container" ]
                    [ p [ class "h5 text-muted" ] [ text "Movements" ]
                    , viewMovements model.movements
                    ]
                ]
            ]
        ]
