#!/usr/bin/env python
from enum import StrEnum
from typing import Tuple

import utils

# 2022-12-01
# Rock Paper Scissors!

strategy_guide_data = utils.read_input("2022-12-02")

class OpponentPlay(StrEnum):
    ROCK = "A"
    PAPER = "B"
    SCISSORS = "C"


class PlayerPlay(StrEnum):
    ROCK = "X"
    PAPER = "Y"
    SCISSORS ="Z"

    @property
    def innate_score(self) -> int:
        if self == self.ROCK:
            return 1
        elif self == self.PAPER:
            return 2
        elif self == self.SCISSORS:
            return 3

        return 0 

        

PLAYER_VICTORIES = [
    (PlayerPlay.ROCK, OpponentPlay.SCISSORS),
    (PlayerPlay.PAPER, OpponentPlay.ROCK),
    (PlayerPlay.SCISSORS, OpponentPlay.PAPER)
]

DRAWS = [
    (PlayerPlay.ROCK, OpponentPlay.ROCK),
    (PlayerPlay.PAPER, OpponentPlay.PAPER),
    (PlayerPlay.SCISSORS, OpponentPlay.SCISSORS)
]


def score_match(opponent_play: OpponentPlay, player_play: PlayerPlay) -> int:
    game = (player_play, opponent_play)
    

    if game in PLAYER_VICTORIES:
        game_score = 6
    elif game in DRAWS:
        game_score = 3
    else:
        game_score = 0

    play_score = player_play.innate_score

    return play_score + game_score

def parse_match(match_line: str) -> Tuple[OpponentPlay|None, PlayerPlay|None]:
    try:
        opponent_play, player_play = match_line.split(" ")
        return (OpponentPlay(opponent_play), PlayerPlay(player_play))
    except:
        return None, None

if __name__ == "__main__":
    scores = []

    for line in strategy_guide_data.split("\n"):
        opponent_play, player_play = parse_match(line)
        if opponent_play and player_play:
            scores.append(score_match(opponent_play, player_play))

    print(sum(scores))