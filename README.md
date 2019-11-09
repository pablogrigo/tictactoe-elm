[![Netlify Status](https://api.netlify.com/api/v1/badges/fd80bf21-abf3-44ed-8a49-d73a6700e3a2/deploy-status)](https://app.netlify.com/sites/tictactoe-elm/deploys)

```
 _____ _        _____             _____               __ _
/__   (_) ___  /__   \__ _  ___  /__   \___   ___    /__\ |_ __ ___
  / /\/ |/ __|   / /\/ _` |/ __|   / /\/ _ \ / _ \  /_\ | | '_ ` _ \
 / /  | | (__   / / | (_| | (__   / / | (_) |  __/ //__ | | | | | | |
 \/   |_|\___|  \/   \__,_|\___|  \/   \___/ \___| \__/ |_|_| |_| |_|

```

# tictactoe-elm
The classic TicTacToe, written in Elm.

## Try it online

[https://tictactoe-elm.netlify.com](https://tictactoe-elm.netlify.com)

# Build process

## Development

* `npm install`
* `npm run watch`
* `open public/index.html`

## Test

* `npm test`

## Distribution

* `npm run build`
* `open build/`

# Architecture

A single page application with no external dependencies.

## Underlying data structure

The application is built on top of a list of `Movement` nodes, which consists of pairs `Cell, Player`.

The list provides a single source of truth for deriving all other necessary state without room for inconsistencies.

```
   +---+   +---+   +---+
-->|A,X|-->|H,O|-->|F,X|
   +---+   +---+   +---+
```

## Game state machine

The game state is computed based on the list of `Movement`.

The state machine is used to validate transitions and ignore invalid actions. e.g. If `X Wins`, new marks won't be placed until the game is reset.

```
+-------+      +-------+
|X Wins |      |O Wins |
+-------+      +-------+
    ^              ^
    |              |
+-------+      +-------+
|X Moves|<---->|O Moves|
+-------+      +-------+
     \           /
      \         /
       v       v
       +-------+
       |  Tie  |
       +-------+
```

## Representations

The list of `Movement` is represented as an interactive `Board` and a `Table` displaying the sequence of actions.

### Board view
```
 X |   |
---|---|---
   |   | X
---|---|---
   | O |
```

### Table view
```
 Player |  Cell
--------|--------
   X    |   A
--------|--------
   O    |   H
--------|--------
   X    |   F
--------|--------
        |
```

## AI strategy

A `Random` strategy is implemented for player `O` as a proof of concept.
