module utils;

import util.Basic : print, u64;
import util.Strings : concat, index_of, starts_with;
import util.Varargs;
import util.Files : get_filename_from_path;
import util.Time : start_time_diff, time_diff_nanoseconds;

nothrow @nogc:

__gshared bool print_performance = false;
__gshared u64 last_timestamp;

void log_error(A...)(int year, int day, A a) {
    mixin varargs!a;
    return log_error(year, day, concat(va_args));
}

void log_error(int year, int day, string message) {
    print("Year ", year, " day ", day, " encountered an error: ", message, "\n");
}

void log_result(A...)(int year, int day, string file, string format, A a) {
    mixin varargs!a;
    string[6] colors = ["\x1b[31m", "\x1b[32m", "\x1b[33m", "\x1b[34m", "\x1b[35m", "\x1b[36m"];
    print("Result for year ", colors[year % 6], year, "\x1b[0m day ", colors[day % 6], day, "\x1b[0m file ");

    string filename = get_filename_from_path(file);
    // example files are set to dim/faint
    if (starts_with(filename, "example")) {
        print("\x1b[2m", filename, "\x1b[0m");
    } else {
        print("\x1b[1m", filename, "\x1b[0m");
    }
    print(": ");

    long last_format_index = 0;
    long format_index = index_of(format, '%');
    if (format_index < 0)
        format_index = format.length;

    int argument_index = 0;
    while (format_index < format.length) {
        print(format[last_format_index..format_index]);
        last_format_index = format_index + 1;

        if (format_index + 1 < format.length && format[format_index + 1] == '#') {
            // red or green, depending on whether the result matched the expected value
            bool result_matched = va_get_elem!bool(va_args, argument_index);
            if (result_matched)
                print("\x1b[32m");
            else
                print("\x1b[31m");
            print(va_args.values[argument_index + 1]);
            print("\x1b[0m");
            argument_index += 2;
            last_format_index += 1;

        } else if (format_index + 1 < format.length && format[format_index + 1] == '%') {
            print('%');
            last_format_index += 1;

        } else {
            print(va_args.values[argument_index]);
            argument_index += 1;
        } 

        format_index = index_of(format, last_format_index, '%');
        if (format_index < 0)
            format_index = format.length;
    }
    print(format[last_format_index..$]);
    print("\n");
}

void print_time(int day) {
    if (day > 0 && print_performance)
        print("Day ", day, " time: ", time_diff_nanoseconds(last_timestamp) / 1000, " µs\n");

    last_timestamp = start_time_diff();
}