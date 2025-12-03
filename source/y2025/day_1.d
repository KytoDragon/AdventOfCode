module y2025.day_1;

import util.Basic : free;
import util.Strings : parse_integer;
import util.Files : read_entire_file, get_filename_from_path;
import util.Math : ifloordiv, ifloormod;
import util.file.FileReader;

import utils;

nothrow @nogc:

void day_1(string input_file) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);
    FileReader fr = FileReader(data);
    
    int position = 50;
    int num_zero_position;
    int num_zero_hits;
    while (!fr.end_of_data()) {
        string line = fr.read_line();
        if (line.length < 2)
            return log_error("2025", "1", "Line in file ", input_file, " is to short");
        
        char direction = line[0];
        uint distance;
        if (!parse_integer(line[1..$], &distance))
            return log_error("2025", "1", "Distance in file ", input_file, " is not an integer");
        
        if (direction == 'R') {
            num_zero_hits += (position + distance) / 100;
            position = (position + distance) % 100;
        } else if (direction == 'L') {
            if (position == 0) // don't count zero twice if we started at zero
                num_zero_hits -= 1;
            num_zero_hits += -ifloordiv(position - distance - 1, 100); // -1 to count a hit when landing on zero
            position = ifloormod(position - distance, 100);
        } else
            return log_error("2025", "1", "Direction in file ", input_file, " is not L or R");
        
        if (position == 0) {
            num_zero_position += 1;
        }
    }

    log_result("2025", "1", get_filename_from_path(input_file), ": Number of times the dial is left pointing at 0: ", HIGHLIGHT_START, num_zero_position, HIGHLIGHT_END,
                                                                ", Number of times the dial hit 0: ", HIGHLIGHT_START, num_zero_hits, HIGHLIGHT_END);
}
