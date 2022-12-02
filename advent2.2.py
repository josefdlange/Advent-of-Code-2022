#!/usr/bin/env python
from enum import StrEnum
from typing import Tuple

import utils

# 2022-12-01
# Rock Paper Scissors!

# strategy_guide_data = ("""A Y
# B X
# C Z""")

strategy_guide_data = utils.read_input("2022-12-02")


class Play(StrEnum):
    ROCK = "A"
    PAPER = "B"
    SCISSORS = "C"

    @property
    def innate_score(self) -> int:
        if self == self.ROCK:
            return 1
        elif self == self.PAPER:
            return 2
        elif self == self.SCISSORS:
            return 3

        return 0

    @property
    def defeated_by(self):
        if self == self.ROCK:
            return self.PAPER
        elif self == self.PAPER:
            return self.SCISSORS
        elif self == self.SCISSORS:
            return self.ROCK

    @property
    def defeats(self):
        if self == self.ROCK:
            return self.SCISSORS
        elif self == self.PAPER:
            return self.ROCK
        elif self == self.SCISSORS:
            return self.PAPER
    

class Outcome(StrEnum):
    DEFEAT = "X"
    DRAW = "Y"
    VICTORY ="Z"


PLAYER_VICTORIES = [
    (Play.ROCK, Play.SCISSORS),
    (Play.PAPER, Play.ROCK),
    (Play.SCISSORS, Play.PAPER)
]

DRAWS = [
    (Play.ROCK, Play.ROCK),
    (Play.PAPER, Play.PAPER),
    (Play.SCISSORS, Play.SCISSORS)
]


def score_match(opponent_play: Play, player_play: Play) -> int:
    game = (player_play, opponent_play)
    

    if game in PLAYER_VICTORIES:
        game_score = 6
    elif game in DRAWS:
        game_score = 3
    else:
        game_score = 0

    play_score = player_play.innate_score

    return play_score + game_score

def parse_match(match_line: str) -> Tuple[Play|None, Outcome|None]:
    try:
        opponent_play, player_play = match_line.split(" ")
        return (Play(opponent_play), Outcome(player_play))
    except:
        return None, None

if __name__ == "__main__":
    scores = []

    for line in strategy_guide_data.split("\n"):
        opponent_play, desired_outcome = parse_match(line)
        if opponent_play and desired_outcome:
            if desired_outcome == Outcome.VICTORY:
                player_play = opponent_play.defeated_by
            elif desired_outcome == Outcome.DRAW:
                player_play = opponent_play
            elif desired_outcome == Outcome.DEFEAT:
                player_play = opponent_play.defeats

            scores.append(score_match(opponent_play, player_play))

    print(sum(scores))