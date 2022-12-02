#!/usr/bin/env python
import utils

# 2022-12-01

if __name__ == "__main__":
    # Elves' Calories, in string form because I'm lazy
    data = utils.read_input("2022-12-01")

    # There's probably a util in collections or itertools to do what I'm doing here
    # but I can't be bothered to look it up.

    # Split row data into a list
    values = data.split("\n")

    # Prepare destination data structure
    elves = []

    # Prepare inner data structure
    current_elf = []

    # Iterate over values
    for value in values:
        # Use "" sentinel to store current elft and iterate to next elf.
        if value == "":
            elves.append(current_elf)
            current_elf = []
            continue

        # Otherwise parse and store value on current elf.
        current_elf.append(int(value))

    # Print outputs relevant to challenge.
    print(f"Top Elf Calories: {sum(max(elves, key=sum))}")
    print(f"Top Three Elf Calories: {sum([sum(elf) for elf in sorted(elves, key=sum, reverse=True)][:3])}")

