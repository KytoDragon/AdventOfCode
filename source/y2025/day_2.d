module y2025.day_2;

import util.Basic : free, u64;
import util.Strings : parse_integer, split, print_integer_fixed;
import util.Files : read_entire_file, get_filename_from_path;
import util.Math : log10, pow;
import util.file.FileReader;

import utils;

nothrow @nogc:

void day_2(string input_file) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);
    FileReader fr = FileReader(data);
    
    u64 sum_invalid_ids;
    u64 sum_invalid_ids_b;
    string[] ranges = split(fr.read_line(), ',');
    char[20] buffer = null;
    foreach (string range; ranges) {
        string[] parts = split(range, '-');
        u64 first_id, last_id;
        if (parts.length != 2 || !parse_integer(parts[0], &first_id) || !parse_integer(parts[1], &last_id))
            return log_error("2025", "2", "Could not parse ranges");
        
        for (u64 i = first_id; i <= last_id; i++) {
            string value = print_integer_fixed(buffer[], i);
            if (is_invalid_id(value))
                sum_invalid_ids += i;
            if (is_invalid_id_b(value))
                sum_invalid_ids_b += i;
        }
    }

    log_result("2025", "1", get_filename_from_path(input_file), ": Sum of invalid IDs (repeated twice): ", HIGHLIGHT_START, sum_invalid_ids, HIGHLIGHT_END,
                                                                ", Sum of invalid IDs (any repeat): ", HIGHLIGHT_START, sum_invalid_ids_b, HIGHLIGHT_END);
}

private:

bool is_invalid_id(string id) {
    if (id.length % 2 == 1)
        return false;
    
    return id[0..id.length / 2] == id[id.length / 2..$];
}

bool is_invalid_id_b(string id) {
    F: for (int i = 1; i < id.length; i++) {
        if (id.length % i != 0)
            continue;

        for (int j = 0; j < id.length / i - 1; j++) {
            if (id[i*j..i*(j+1)] != id[i*(j+1)..i*(j+2)])
                continue F;
        }
        return true;
    }
    return false;
}