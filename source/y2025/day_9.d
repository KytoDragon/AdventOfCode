module y2025.day_9;

import util.Basic : free, u64;
import util.Files : read_entire_file;
import util.Strings : parse_integer, index_of;
import util.Math : abs, min, max;
import util.file.FileReader;
import util.List;

import utils;

nothrow @nogc:

void day_9(string input_file, u64 expected_result_1, int expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);

    Tile[] tiles = parse_tiles(data);
    if (!tiles)
        return log_error(2025, 9, "Could not parse line in file ", input_file);
    scope(exit) free(tiles);
    
    u64 largest_area;
    u64 largest_contained_area;
    foreach (i, tile; tiles) {
        
        // The polygon drawn by our points are always to the left of the line.
        // Thus we can skip all tiles in certain directions depending on which direction the line is going.
        // (e.g. a corner on a line going down cannot connect to another corner to the right)
        Tile previous = tiles[i == 0 ? cast(int)tiles.length - 1 : cast(int)i - 1];
        Tile next = tiles[i == tiles.length - 1 ? 0 : cast(int)i + 1];
        bool skip_points_right = next.x <= tile.x && next.y >= tile.y && previous.x <= tile.x && previous.y <= tile.y;
        bool skip_points_left = next.x >= tile.x && next.y <= tile.y && previous.x >= tile.x && previous.y >= tile.y;
        bool skip_points_up = next.x <= tile.x && next.y <= tile.y && previous.x >= tile.x && previous.y <= tile.y;
        bool skip_points_down = next.x >= tile.x && next.y >= tile.y && previous.x <= tile.x && previous.y >= tile.y;
        
        F: for (int j = cast(int)i + 1; j < tiles.length; j++) {
            Tile other = tiles[j];
            int min_x = min(tile.x, other.x);
            int max_x = max(tile.x, other.x);
            int min_y = min(tile.y, other.y);
            int max_y = max(tile.y, other.y);
            u64 area = (max_x - min_x + 1) * cast(u64)(max_y - min_y + 1);
            if (area > largest_area)
                largest_area = area;

            if (skip_points_right && other.x > tile.x)
                continue;
            if (skip_points_left && other.x < tile.x)
                continue;
            if (skip_points_up && other.y > tile.y)
                continue;
            if (skip_points_down && other.y < tile.y)
                continue;
            
            // I assume the result is has a width and heigth larger 1.
            // (otherwise we would also have to deal with lines that are fully inside the resulting 1-wide "rectangle"
            //  and may or may not be in the right orientation to mark part of the rectangle as outside)
            if (min_x < max_x && min_y < max_y) {
                foreach (k, third; tiles) {
                    // no other point is inside the rectangle
                    if (third.x > min_x && third.x < max_x && third.y > min_y && third.y < max_y) {
                        continue F;
                    }
                    // no edge cuts though the rectangle
                    Tile previous2 = tiles[k == 0 ? cast(int)tiles.length - 1 : cast(int)k - 1];
                    if (third.x > min_x && third.x < max_x) { // top-down
                        if (third.y <= min_y && previous2.y > min_y)
                            continue F;
                        if (third.y >= max_y && previous2.y < max_y)
                            continue F;

                    }
                    if (third.y > min_y && third.y < max_y) { // left-right
                        if (third.x <= min_x && previous2.x > min_x)
                            continue F;
                        if (third.x >= max_x && previous2.x < max_x)
                            continue F;
                    }
                }
            }

            if (area > largest_contained_area)
                largest_contained_area = area;
        }
    }

    bool result_1_matched = expected_result_1 == largest_area;
    bool result_2_matched = expected_result_2 == largest_contained_area;
    log_result(2025, 9, input_file, "Area of largest rectangle: %#, Area of largest contained rectangle: %#", result_1_matched, largest_area, result_2_matched, largest_contained_area);
}

private:

struct Tile {
    int x, y;
}

Tile[] parse_tiles(ubyte[] data) {
    
    List!Tile tiles;

    FileReader fr = FileReader(data);
    while (!fr.end_of_data()) {
        string line = fr.read_line();

        long comma = index_of(line, ',');
        Tile tile;
        if (comma < 0 || !parse_integer(line[0..comma], &tile.x) || !parse_integer(line[comma + 1..$], &tile.y))
            return null;
        
        tiles.add(tile);
    }
    return tiles.as_array();
}


/*
--- Day 9: Movie Theater ---

You slide down the firepole in the corner of the playground and land in the North Pole base movie theater!

The movie theater has a big tile floor with an interesting pattern. Elves here are redecorating the theater by switching out some of the square tiles in the big grid they form. Some of the tiles are red; the Elves would like to find the largest rectangle that uses red tiles for two of its opposite corners. They even have a list of where the red tiles are located in the grid (your puzzle input).

For example:

7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3

Showing red tiles as # and other tiles as ., the above arrangement of red tiles would look like this:

..............
.......#...#..
..............
..#....#......
..............
..#......#....
..............
.........#.#..
..............

You can choose any two red tiles as the opposite corners of your rectangle; your goal is to find the largest rectangle possible.

For example, you could make a rectangle (shown as O) with an area of 24 between 2,5 and 9,7:

..............
.......#...#..
..............
..#....#......
..............
..OOOOOOOO....
..OOOOOOOO....
..OOOOOOOO.#..
..............

Or, you could make a rectangle with area 35 between 7,1 and 11,7:

..............
.......OOOOO..
.......OOOOO..
..#....OOOOO..
.......OOOOO..
..#....OOOOO..
.......OOOOO..
.......OOOOO..
..............

You could even make a thin rectangle with an area of only 6 between 7,3 and 2,3:

..............
.......#...#..
..............
..OOOOOO......
..............
..#......#....
..............
.........#.#..
..............

Ultimately, the largest rectangle you can make in this example has area 50. One way to do this is between 2,5 and 11,1:

..............
..OOOOOOOOOO..
..OOOOOOOOOO..
..OOOOOOOOOO..
..OOOOOOOOOO..
..OOOOOOOOOO..
..............
.........#.#..
..............

Using two red tiles as opposite corners, what is the largest area of any rectangle you can make?

--- Part Two ---

The Elves just remembered: they can only switch out tiles that are red or green. So, your rectangle can only include red or green tiles.

In your list, every red tile is connected to the red tile before and after it by a straight line of green tiles. The list wraps, so the first red tile is also connected to the last red tile. Tiles that are adjacent in your list will always be on either the same row or the same column.

Using the same example as before, the tiles marked X would be green:

..............
.......#XXX#..
.......X...X..
..#XXXX#...X..
..X........X..
..#XXXXXX#.X..
.........X.X..
.........#X#..
..............

In addition, all of the tiles inside this loop of red and green tiles are also green. So, in this example, these are the green tiles:

..............
.......#XXX#..
.......XXXXX..
..#XXXX#XXXX..
..XXXXXXXXXX..
..#XXXXXX#XX..
.........XXX..
.........#X#..
..............

The remaining tiles are never red nor green.

The rectangle you choose still must have red tiles in opposite corners, but any other tiles it includes must now be red or green. This significantly limits your options.

For example, you could make a rectangle out of red and green tiles with an area of 15 between 7,3 and 11,1:

..............
.......OOOOO..
.......OOOOO..
..#XXXXOOOOO..
..XXXXXXXXXX..
..#XXXXXX#XX..
.........XXX..
.........#X#..
..............

Or, you could make a thin rectangle with an area of 3 between 9,7 and 9,5:

..............
.......#XXX#..
.......XXXXX..
..#XXXX#XXXX..
..XXXXXXXXXX..
..#XXXXXXOXX..
.........OXX..
.........OX#..
..............

The largest rectangle you can make in this example using only red and green tiles has area 24. One way to do this is between 9,5 and 2,3:

..............
.......#XXX#..
.......XXXXX..
..OOOOOOOOXX..
..OOOOOOOOXX..
..OOOOOOOOXX..
.........XXX..
.........#X#..
..............

Using two red tiles as opposite corners, what is the largest area of any rectangle you can make using only red and green tiles?
*/
