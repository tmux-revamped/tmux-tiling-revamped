#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_PREVIEWS_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PREVIEWS_LOADED=1

TILING_PREVIEW_DWINDLE='Dwindle Layout (4 panes)
┌───────────────────┬───────────────────┐
│                   │                   │
│                   │         2         │
│         1         │                   │
│                   ├─────────┬─────────┤
│                   │         │         │
│                   │    3    │    4    │
└───────────────────┴─────────┴─────────┘
BSP cascade toward corner'
export TILING_PREVIEW_DWINDLE

TILING_PREVIEW_SPIRAL='Spiral Layout (4 panes)
┌───────────────────┬───────────────────┐
│                   │                   │
│                   │         2         │
│         1         │                   │
│                   ├─────────┬─────────┤
│                   │         │         │
│                   │    4    │    3    │
└───────────────────┴─────────┴─────────┘
BSP with spiral trajectory'
export TILING_PREVIEW_SPIRAL

TILING_PREVIEW_GRID='Grid Layout (4 panes)
┌───────────────────┬───────────────────┐
│                   │                   │
│         1         │         2         │
│                   │                   │
├───────────────────┼───────────────────┤
│                   │                   │
│         3         │         4         │
│                   │                   │
└───────────────────┴───────────────────┘
Even N x M grid distribution'
export TILING_PREVIEW_GRID

TILING_PREVIEW_MAIN_CENTER='Main-Center (6 panes)
┌─────────┬───────────────────┬─────────┐
│    2    │                   │    4    │
├─────────┤                   ├─────────┤
│    3    │         1         │    5    │
│         │                   ├─────────┤
│         │                   │    6    │
└─────────┴───────────────────┴─────────┘
Balanced sides, wide center pane'
export TILING_PREVIEW_MAIN_CENTER

TILING_PREVIEW_MAIN_VERTICAL='Main-Vertical (4 panes)
┌───────────────────┬───────────────────┐
│                   │         2         │
│                   ├───────────────────┤
│         1         │         3         │
│                   ├───────────────────┤
│                   │         4         │
│                   │                   │
└───────────────────┴───────────────────┘
Master left, stack right'
export TILING_PREVIEW_MAIN_VERTICAL

TILING_PREVIEW_MAIN_HORIZONTAL='Main-Horizontal (4 panes)
┌───────────────────────────────────────┐
│                                       │
│                  1                    │
│                                       │
├───────────┬───────────┬───────────────┤
│     2     │     3     │       4       │
└───────────┴───────────┴───────────────┘
Master top, stack bottom'
export TILING_PREVIEW_MAIN_HORIZONTAL

TILING_PREVIEW_MONOCLE='Monocle Layout
┌───────────────────────────────────────┐
│                                       │
│                                       │
│                  1                    │
│              [ZOOMED]                 │
│                                       │
│                                       │
└───────────────────────────────────────┘
Zoom focused pane to fullscreen
(other panes hidden behind)'
export TILING_PREVIEW_MONOCLE

TILING_PREVIEW_DECK='Deck Layout (4 panes)
┌─────────┬─────────┬─────────┬─────────┐
│         │         │         │         │
│         │         │         │         │
│    1    │    2    │    3    │    4    │
│         │         │         │         │
│         │         │         │         │
└─────────┴─────────┴─────────┴─────────┘
Full-height equal-width cards'
export TILING_PREVIEW_DECK

