module Main exposing (..)

import Browser
import Html exposing (Html, button, div, form, h3, li, nav, p, span, sup, text, ul)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onClick, onSubmit)
import Random



-- Model


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


type Movement
    = Movement Cell Player


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


movementForCell : Cell -> List Movement -> Maybe Movement
movementForCell cell movements =
    movements |> List.filter (\(Movement c _) -> c == cell) |> List.head


isWinner : List Movement -> Player -> Bool
isWinner movements player =
    let
        playerMovements =
            List.filter (\(Movement _ who) -> who == player) movements

        playerCells =
            playerMovements |> List.map (\(Movement cell _) -> cell)

        includedInPlayerCells cells =
            cells |> List.all (\cell -> List.member cell playerCells)
    in
    cellGroups |> List.any includedInPlayerCells


status : List Movement -> Player -> GameStatus
status movements initialPlayer =
    let
        cellUsed cell =
            movements |> List.filter (\(Movement c _) -> c == cell) |> List.isEmpty |> not

        allCellsUsed =
            allCells |> List.all cellUsed
    in
    if isWinner movements X then
        Wins X

    else if isWinner movements O then
        Wins O

    else if allCellsUsed then
        Tie

    else
        case lastMovement movements of
            Just (Movement _ player) ->
                Moves (otherPlayer player)

            Nothing ->
                Moves initialPlayer


requestRandomNumber : Cmd Msg
requestRandomNumber =
    Random.generate OnRandomNumber <| Random.int 0 Random.maxInt


type Msg
    = Move Cell
    | Reset
    | OnRandomNumber Int


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- Init


init : String -> ( Model, Cmd Msg )
init _ =
    initForPlayer X


initForPlayer : Player -> ( Model, Cmd Msg )
initForPlayer initial =
    ( { movements = []
      , initial = initial
      }
    , if initial == X then
        Cmd.none

      else
        requestRandomNumber
    )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        unusedCells =
            allCells |> List.filter (\cell -> model.movements |> List.filter (\(Movement c _) -> c == cell) |> List.isEmpty)

        unusedCellsAvailable =
            not <| List.isEmpty unusedCells

        gameStatus =
            status model.movements model.initial
    in
    case ( msg, gameStatus, unusedCellsAvailable ) of
        ( Reset, _, _ ) ->
            initForPlayer <| otherPlayer model.initial

        ( OnRandomNumber randomNumber, Moves O, True ) ->
            let
                maybeUnusedCell =
                    List.drop (modBy (List.length unusedCells) randomNumber) unusedCells |> List.head
            in
            case maybeUnusedCell of
                Just unusedCell ->
                    ( { model | movements = List.append model.movements [ Movement unusedCell O ] }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        ( Move cell, Moves X, _ ) ->
            if (model.movements |> movementForCell cell) == Nothing then
                ( { model | movements = List.append model.movements [ Movement cell X ] }, requestRandomNumber )

            else
                ( model, Cmd.none )

        ( _, _, _ ) ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    let
        gameStatus =
            status model.movements model.initial
    in
    div []
        [ viewNavigationBar (List.isEmpty model.movements)
        , div [ class "container" ]
            [ div [ class "row mb-2" ]
                [ div [ class "col-md-3 mt-4 text-center" ]
                    [ p [ class "h5 text-muted" ] [ text "Status" ]
                    , h3 [] [ text <| statusString <| gameStatus ]
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


viewNavigationBar : Bool -> Html Msg
viewNavigationBar emptyBoard =
    nav [ class "navbar sticky-top navbar-light bg-light" ]
        [ span [ class "navbar-brand mb-0 h1" ] [ text "TicTacToe ", sup [ class "badge badge-pill badge-dark" ] [ text "elm" ] ]
        , form [ class "form-inline my-2 my-lg-0", onSubmit Reset ]
            [ button [ class "btn btn-sm btn-primary my-2 my-sm-0", disabled emptyBoard ] [ text "Restart" ]
            ]
        ]


viewMovements : List Movement -> Html Msg
viewMovements movements =
    if List.isEmpty movements then
        span [] [ text "-" ]

    else
        ul [ class "list-group" ] (List.map viewMovement movements)


viewMovement : Movement -> Html Msg
viewMovement movement =
    let
        movementString (Movement cell player) =
            playerString player ++ "-" ++ cellString cell
    in
    li [ class "list-group-item" ] [ text <| movementString <| movement ]


statusString : GameStatus -> String
statusString gameStatus =
    case gameStatus of
        Tie ->
            "Tie"

        Moves player ->
            playerString player ++ " moves"

        Wins player ->
            playerString player ++ " wins \u{1F973}"


playerString : Player -> String
playerString player =
    case player of
        X ->
            "X"

        O ->
            "O"


viewCells : List Movement -> List (Html Msg)
viewCells movements =
    allCells |> List.map (viewCell movements)


viewCell : List Movement -> Cell -> Html Msg
viewCell movements cell =
    let
        maybeMovement =
            movements |> movementForCell cell

        maybePlayer =
            case maybeMovement of
                Just (Movement _ player) ->
                    Just player

                Nothing ->
                    Nothing

        isCellUsed =
            maybeMovement /= Nothing

        cellText =
            case maybePlayer of
                Just player ->
                    playerString player

                Nothing ->
                    ""
    in
    div [ class "board__cell", onClick (Move cell), disabled isCellUsed ] [ text cellText ]


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
