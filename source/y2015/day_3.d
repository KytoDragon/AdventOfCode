module y2015.day_3;

import util.Basic : free, u16, u32;
import util.Files : read_entire_file;
import util.file.FileReader;
import util.HashTable;

import utils;

nothrow @nogc:

void day_3(string input_file, int expected_result_1, int expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);
    FileReader fr = FileReader(data);
    string line = fr.read_line();

    HashTable!(u32, bool) houses;
    scope(exit) houses.destroy();

    {
        u16 x, y;
        houses.put((y << 16) | x, true);
        foreach (char c; line) {
            if (c == '^')
                y += 1;
            else if (c == 'v')
                y -= 1;
            else if (c == '<')
                x += 1;
            else if (c == '>')
                x -= 1;
            houses.put((y << 16) | x, true);
        }
    }
    int unique_houses_visited = cast(int)houses.size;

    {
        u16 sx, sy, rx, ry;
        houses.clear();
        houses.put((sy << 16) | sx, true);
        bool robo_santas_turn = false;
        foreach (char c; line) {
            if (robo_santas_turn) {
                if (c == '^')
                    ry += 1;
                else if (c == 'v')
                    ry -= 1;
                else if (c == '<')
                    rx += 1;
                else if (c == '>')
                    rx -= 1;
                houses.put((ry << 16) | rx, true);
            } else {
                if (c == '^')
                    sy += 1;
                else if (c == 'v')
                    sy -= 1;
                else if (c == '<')
                    sx += 1;
                else if (c == '>')
                    sx -= 1;
                houses.put((sy << 16) | sx, true);
            }
            robo_santas_turn = !robo_santas_turn;
        }
    }
    int robo_santa_houses_visited = cast(int)houses.size;

    bool result_1_matched = expected_result_1 == unique_houses_visited;
    bool result_2_matched = expected_result_2 == robo_santa_houses_visited;
    log_result(2015, 3, input_file, "Number of unique houses visited: %# Number of houses visited with Robo-Santa: %# feet", result_1_matched, unique_houses_visited, result_2_matched, robo_santa_houses_visited);
}

/*
--- Day 3: Perfectly Spherical Houses in a Vacuum ---

Santa is delivering presents to an infinite two-dimensional grid of houses.

He begins by delivering a present to the house at his starting location, and then an elf at the North Pole calls him via radio and tells him where to move next. Moves are always exactly one house to the north (^), south (v), east (>), or west (<). After each move, he delivers another present to the house at his new location.

However, the elf back at the north pole has had a little too much eggnog, and so his directions are a little off, and Santa ends up visiting some houses more than once. How many houses receive at least one present?

For example:

    > delivers presents to 2 houses: one at the starting location, and one to the east.
    ^>v< delivers presents to 4 houses in a square, including twice to the house at his starting/ending location.
    ^v^v^v^v^v delivers a bunch of presents to some very lucky children at only 2 houses.

--- Part Two ---

The next year, to speed up the process, Santa creates a robot version of himself, Robo-Santa, to deliver presents with him.

Santa and Robo-Santa start at the same location (delivering two presents to the same starting house), then take turns moving based on instructions from the elf, who is eggnoggedly reading from the same script as the previous year.

This year, how many houses receive at least one present?

For example:

    ^v delivers presents to 3 houses, because Santa goes north, and then Robo-Santa goes south.
    ^>v< now delivers presents to 3 houses, and Santa and Robo-Santa end up back where they started.
    ^v^v^v^v^v now delivers presents to 11 houses, with Santa going one direction and Robo-Santa going the other.
*/
