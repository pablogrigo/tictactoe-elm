module MainTests exposing (..)

import Expect exposing (Expectation)
import Main exposing (..)
import Test exposing (..)


initTests : Test
initTests =
    describe "init function"
        [ test "should start with no movements" <|
            \() ->
                init "" |> expectMovements []
        , test "should start with X moving" <|
            \() ->
                init "" |> expectInitial X
        ]


updateTests : Test
updateTests =
    describe "update function"
        [ test "should accept movement when cell when empty" <|
            \() ->
                update (Move C) (Tuple.first (init ""))
                    |> expectMovements (moves [ ( C, X ) ])
        , test "should ignore movement when cell is used" <|
            \() ->
                let
                    xSingleMovementOnC =
                        moves [ ( C, X ) ]
                in
                update (Move C) (createModel xSingleMovementOnC X)
                    |> expectMovements xSingleMovementOnC
        , test "should ignore movement when game finished (tie)" <|
            \() ->
                update (Move C) (createModel tieBoard X)
                    |> expectMovements tieBoard
        , test "should ignore movement when game finished (winner X)" <|
            \() ->
                update (Move C) (createModel xWinsBoard X)
                    |> expectMovements xWinsBoard
        , test "should ignore movement when game finished (winner O)" <|
            \() ->
                update (Move C) (createModel oWinsBoard X)
                    |> expectMovements oWinsBoard
        , test "should clear movements when resetting" <|
            \() ->
                update Reset (createModel oWinsBoard X)
                    |> expectMovements []
        , test "should swap initial player when resetting game" <|
            \() ->
                update Reset (createModel oWinsBoard X)
                    |> expectInitial O
        ]


gameStatusTests : Test
gameStatusTests =
    describe "game status"
        [ test "should return X moves first when no movements and X is the initial player" <|
            \() ->
                status [] X
                    |> Expect.equal (Moves X)
        , test "should return O moves first when no movements and O is the initial player" <|
            \() ->
                status [] O
                    |> Expect.equal (Moves O)
        , test "should return X wins" <|
            \() ->
                status xWinsBoard X
                    |> Expect.equal (Wins X)
        , test "should return O wins" <|
            \() ->
                status oWinsBoard X
                    |> Expect.equal (Wins O)
        , test "should return tie when board is full" <|
            \() ->
                status tieBoard X
                    |> Expect.equal Tie
        ]


movementForCellTests : Test
movementForCellTests =
    describe "movementForCell"
        [ test "should filter for X" <|
            \() ->
                movementForCell A tieBoard
                    |> Expect.equal (Just (Movement A X))
        , test "should filter for O" <|
            \() ->
                movementForCell I tieBoard
                    |> Expect.equal (Just (Movement I O))
        , test "should return Nothing when not found" <|
            \() ->
                movementForCell I []
                    |> Expect.equal Nothing
        ]


expectMovements : List Movement -> ( Model, Cmd Msg ) -> Expectation
expectMovements movements ( model, _ ) =
    model |> .movements |> Expect.equal movements


expectInitial : Player -> ( Model, Cmd Msg ) -> Expectation
expectInitial player ( model, _ ) =
    model |> .initial |> Expect.equal player


xWinsBoard : List Movement
xWinsBoard =
    moves [ ( A, X ), ( G, O ), ( B, X ), ( H, O ), ( C, X ) ]


oWinsBoard : List Movement
oWinsBoard =
    moves [ ( A, O ), ( G, X ), ( B, O ), ( H, X ), ( C, O ) ]


tieBoard : List Movement
tieBoard =
    moves [ ( A, X ), ( B, O ), ( C, X ), ( E, O ), ( D, X ), ( G, O ), ( F, X ), ( I, O ), ( H, X ) ]


moves : List ( Cell, Player ) -> List Movement
moves pairs =
    pairs |> List.map (\( cell, player ) -> Movement cell player)


createModel : List Movement -> Player -> Model
createModel movements initial =
    { movements = movements
    , initial = initial
    }
