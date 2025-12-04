module y2025.day_4;

import util.Basic : free;
import util.Files : read_entire_file;
import util.file.FileReader;

import utils;

nothrow @nogc:

void day_4(string input_file, int expected_result_1, int expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);

    int num_accessible_rolls = count_accessible_rolls(data);
    int num_accessible_rolls_first = num_accessible_rolls;
    int num_rolls_removed = 0;
    while (num_accessible_rolls > 0) {
        num_rolls_removed += num_accessible_rolls;

        remove_accessible_rolls(data);

        num_accessible_rolls = count_accessible_rolls(data);
    }
    
    bool result_1_matched = expected_result_1 == num_accessible_rolls_first;
    bool result_2_matched = expected_result_2 == num_rolls_removed;
    log_result(2025, 4, input_file, "Number of accessible paper rolls: %#, Number of rolls removed %#", result_1_matched, num_accessible_rolls_first, result_2_matched, num_rolls_removed);
}

private:

int count_accessible_rolls(ubyte[] data) {
    
    FileReader fr = FileReader(data);

    char[] first_line = cast(char[])fr.read_line();
    char[] second_line = cast(char[])fr.read_line();
    
    int num_accessible_rolls = count_accessible_rolls_in_line(null, first_line, second_line);

    while (!fr.end_of_data()) {
        char[] line = cast(char[])fr.read_line();
        num_accessible_rolls += count_accessible_rolls_in_line(first_line, second_line, line);
        first_line = second_line;
        second_line = line;
    }
    num_accessible_rolls += count_accessible_rolls_in_line(first_line, second_line, null);
    return num_accessible_rolls;
}

int count_accessible_rolls_in_line(char[] first_line, char[] second_line, char[] third_line) {
    int num_accessible_rolls;
    for (int i = 0; i < second_line.length; i++) {
        if (second_line.ptr[i] != '@')
            continue;

        int num_neighbors = -1; // -1 because we count the roll itself
        if (first_line != null)
            num_neighbors += get_neighbours_in_line(first_line, i);
        num_neighbors += get_neighbours_in_line(second_line, i);
        if (third_line != null)
            num_neighbors += get_neighbours_in_line(third_line, i);

        if (num_neighbors < 4) {
            num_accessible_rolls += 1;
            second_line[i] = 'x'; // mark roll for deletion
        }
    }
    return num_accessible_rolls;
}

int get_neighbours_in_line(char[] line, int i) {
    int num_neighbours;
    if (i > 0 && line.ptr[i - 1] != '.')
        num_neighbours += 1;
    if (line.ptr[i] != '.')
        num_neighbours += 1;
    if (i < line.length - 1 && line.ptr[i + 1] != '.')
        num_neighbours += 1;
    return num_neighbours;
}

void remove_accessible_rolls(ubyte[] data) {
    
    for (int i = 0; i < data.length; i++) {
        if (data.ptr[i] == 'x')
            data.ptr[i] = '.';
    }
}

/*
--- Day 4: Printing Department ---

You ride the escalator down to the printing department. They're clearly getting ready for Christmas; they have lots of large rolls of paper everywhere, and there's even a massive printer in the corner (to handle the really big print jobs).

Decorating here will be easy: they can make their own decorations. What you really need is a way to get further into the North Pole base while the elevators are offline.

"Actually, maybe we can help with that," one of the Elves replies when you ask for help. "We're pretty sure there's a cafeteria on the other side of the back wall. If we could break through the wall, you'd be able to keep moving. It's too bad all of our forklifts are so busy moving those big rolls of paper around."

If you can optimize the work the forklifts are doing, maybe they would have time to spare to break through the wall.

The rolls of paper (@) are arranged on a large grid; the Elves even have a helpful diagram (your puzzle input) indicating where everything is located.

For example:

..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.

The forklifts can only access a roll of paper if there are fewer than four rolls of paper in the eight adjacent positions. If you can figure out which rolls of paper the forklifts can access, they'll spend less time looking and more time breaking down the wall to the cafeteria.

In this example, there are 13 rolls of paper that can be accessed by a forklift (marked with x):

..xx.xx@x.
x@@.@.@.@@
@@@@@.x.@@
@.@@@@..@.
x@.@@@@.@x
.@@@@@@@.@
.@.@.@.@@@
x.@@@.@@@@
.@@@@@@@@.
x.x.@@@.x.

Consider your complete diagram of the paper roll locations. How many rolls of paper can be accessed by a forklift?

--- Part Two ---

Now, the Elves just need help accessing as much of the paper as they can.

Once a roll of paper can be accessed by a forklift, it can be removed. Once a roll of paper is removed, the forklifts might be able to access more rolls of paper, which they might also be able to remove. How many total rolls of paper could the Elves remove if they keep repeating this process?

Starting with the same example as above, here is one way you could remove as many rolls of paper as possible, using highlighted @ to indicate that a roll of paper is about to be removed, and using x to indicate that a roll of paper was just removed:

Initial state:
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.

Remove 13 rolls of paper:
..xx.xx@x.
x@@.@.@.@@
@@@@@.x.@@
@.@@@@..@.
x@.@@@@.@x
.@@@@@@@.@
.@.@.@.@@@
x.@@@.@@@@
.@@@@@@@@.
x.x.@@@.x.

Remove 12 rolls of paper:
.......x..
.@@.x.x.@x
x@@@@...@@
x.@@@@..x.
.@.@@@@.x.
.x@@@@@@.x
.x.@.@.@@@
..@@@.@@@@
.x@@@@@@@.
....@@@...

Remove 7 rolls of paper:
..........
.x@.....x.
.@@@@...xx
..@@@@....
.x.@@@@...
..@@@@@@..
...@.@.@@x
..@@@.@@@@
..x@@@@@@.
....@@@...

Remove 5 rolls of paper:
..........
..x.......
.x@@@.....
..@@@@....
...@@@@...
..x@@@@@..
...@.@.@@.
..x@@.@@@x
...@@@@@@.
....@@@...

Remove 2 rolls of paper:
..........
..........
..x@@.....
..@@@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@x.
....@@@...

Remove 1 roll of paper:
..........
..........
...@@.....
..x@@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@..
....@@@...

Remove 1 roll of paper:
..........
..........
...x@.....
...@@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@..
....@@@...

Remove 1 roll of paper:
..........
..........
....x.....
...@@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@..
....@@@...

Remove 1 roll of paper:
..........
..........
..........
...x@@....
...@@@@...
...@@@@@..
...@.@.@@.
...@@.@@@.
...@@@@@..
....@@@...

Stop once no more rolls of paper are accessible by a forklift. In this example, a total of 43 rolls of paper can be removed.

Start with your original diagram. How many rolls of paper in total can be removed by the Elves and their forklifts?
*/
