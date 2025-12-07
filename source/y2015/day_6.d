module y2015.day_6;

import util.Basic : free, new_array, u16;
import util.Files : read_entire_file;
import util.Strings : starts_with, index_of, parse_integer;
import util.Math : max;
import util.file.FileReader;

import utils;

nothrow @nogc:

void day_6(string input_file, int expected_result_1, int expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);
    FileReader fr = FileReader(data);

    bool[1000][1000]* lights = cast(bool[1000][1000]*)new_array!bool(1000*1000).ptr;
    ubyte[1000][1000]* brightness = cast(ubyte[1000][1000]*)new_array!ubyte(1000*1000).ptr;
    scope(exit) free(lights);
    scope(exit) free(brightness);

    while (!fr.end_of_data()) {
        string line = fr.read_line();
        Instruction instruction = parse_instruction(line);
        if (instruction.operation == Operation.None || instruction.start_x > 1000 || instruction.start_y > 1000 || instruction.end_x > 1000 || instruction.end_y > 1000)
            return log_error(2015, 6, "Failed to parse instruction in file ", input_file);
        
        if (instruction.operation == Operation.TurnOn) {
            for (int y = instruction.start_y; y <= instruction.end_y; y++) {
                for (int x = instruction.start_x; x <= instruction.end_x; x++) {
                    lights.ptr[y].ptr[x] = true;
                    brightness.ptr[y].ptr[x] += 1;
                }
            }
        } else if (instruction.operation == Operation.TurnOff) {
            for (int y = instruction.start_y; y <= instruction.end_y; y++) {
                for (int x = instruction.start_x; x <= instruction.end_x; x++) {
                    lights.ptr[y].ptr[x] = false;
                    brightness.ptr[y].ptr[x] = cast(ubyte)max(brightness.ptr[y].ptr[x] - 1, 0);
                }
            }
        } else if (instruction.operation == Operation.Toggle) {
            for (int y = instruction.start_y; y <= instruction.end_y; y++) {
                for (int x = instruction.start_x; x <= instruction.end_x; x++) {
                    lights.ptr[y].ptr[x] = !lights.ptr[y].ptr[x];
                    brightness.ptr[y].ptr[x] += 2;
                }
            }
        }
    }
    
    int num_lights_still_lit;
    int sum_brightness;
    for (int y = 0; y < 1000; y++) {
        for (int x = 0; x < 1000; x++) {
            if (lights.ptr[y].ptr[x])
                num_lights_still_lit += 1;
            sum_brightness += brightness.ptr[y].ptr[x];
        }   
    }

    bool result_1_matched = expected_result_1 == num_lights_still_lit;
    bool result_2_matched = expected_result_2 == sum_brightness;
    log_result(2015, 6, input_file, "Number of lights still lit: %#, Sum of brightness: %#", result_1_matched, num_lights_still_lit, result_2_matched, sum_brightness);
}

private:

struct Instruction {
    Operation operation;
    u16 start_x;
    u16 start_y;
    u16 end_x;
    u16 end_y;
}

enum Operation {
    None,
    TurnOn,
    TurnOff,
    Toggle,
}

Instruction parse_instruction(string line) {
    Instruction result;
    int index;
    if (starts_with(line, "turn on ")) {
        result.operation = Operation.TurnOn;
        index = "turn on ".length;
    } else if (starts_with(line, "turn off ")) {
        result.operation = Operation.TurnOff;
        index = "turn off ".length;
    } else if (starts_with(line, "toggle ")) {
        result.operation = Operation.Toggle;
        index = "toggle ".length;
    }

    int next_index = cast(int)index_of(line, index, ',');
    bool success = parse_integer(line[index..next_index], &result.start_x);
    index = next_index + 1;
    
    next_index = cast(int)index_of(line, index, ' ');
    success |= parse_integer(line[index..next_index], &result.start_y);
    index = next_index + cast(int)" through ".length;

    next_index = cast(int)index_of(line, index, ',');
    success |= parse_integer(line[index..next_index], &result.end_x);
    index = next_index + 1;
    
    success |= parse_integer(line[index..$], &result.end_y);
    if (!success)
        result.operation = Operation.None;
    return result;
}

/*
--- Day 6: Probably a Fire Hazard ---

Because your neighbors keep defeating you in the holiday house decorating contest year after year, you've decided to deploy one million lights in a 1000x1000 grid.

Furthermore, because you've been especially nice this year, Santa has mailed you instructions on how to display the ideal lighting configuration.

Lights in your grid are numbered from 0 to 999 in each direction; the lights at each corner are at 0,0, 0,999, 999,999, and 999,0. The instructions include whether to turn on, turn off, or toggle various inclusive ranges given as coordinate pairs. Each coordinate pair represents opposite corners of a rectangle, inclusive; a coordinate pair like 0,0 through 2,2 therefore refers to 9 lights in a 3x3 square. The lights all start turned off.

To defeat your neighbors this year, all you have to do is set up your lights by doing the instructions Santa sent you in order.

For example:

    turn on 0,0 through 999,999 would turn on (or leave on) every light.
    toggle 0,0 through 999,0 would toggle the first line of 1000 lights, turning off the ones that were on, and turning on the ones that were off.
    turn off 499,499 through 500,500 would turn off (or leave off) the middle four lights.

After following the instructions, how many lights are lit?

--- Part Two ---

You just finish implementing your winning light pattern when you realize you mistranslated Santa's message from Ancient Nordic Elvish.

The light grid you bought actually has individual brightness controls; each light can have a brightness of zero or more. The lights all start at zero.

The phrase turn on actually means that you should increase the brightness of those lights by 1.

The phrase turn off actually means that you should decrease the brightness of those lights by 1, to a minimum of zero.

The phrase toggle actually means that you should increase the brightness of those lights by 2.

What is the total brightness of all lights combined after following Santa's instructions?

For example:

    turn on 0,0 through 0,0 would increase the total brightness by 1.
    toggle 0,0 through 999,999 would increase the total brightness by 2000000.
*/
