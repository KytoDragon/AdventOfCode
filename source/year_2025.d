module year_2025;

import util.Basic : print;
import util.Time : start_time_diff, time_diff_nanoseconds;

import y2025.day_1;
import y2025.day_2;
import y2025.day_3;

nothrow @nogc:

void year_2025() {
    bool print_performance = true;
    
    long start = start_time_diff();
    day_1("resources/year_2025/day_1/example.txt", 3, 6);
    day_1("resources/year_2025/day_1/input.txt", 1064, 6122);
    if (print_performance)
        print("Day 1 time: ", time_diff_nanoseconds(start) / 1000, " µs\n");
    
    start = start_time_diff();
    day_2("resources/year_2025/day_2/example.txt", 1227775554, 4174379265);
    day_2("resources/year_2025/day_2/input.txt", 13108371860, 22471660255);
    if (print_performance)
        print("Day 2 time: ", time_diff_nanoseconds(start) / 1000, " µs\n");
    
    start = start_time_diff();
    day_3("resources/year_2025/day_3/example.txt", 357, 3121910778619);
    day_3("resources/year_2025/day_3/input.txt", 17311, 171419245422055);
    if (print_performance)
        print("Day 3 time: ", time_diff_nanoseconds(start) / 1000, " µs\n");
}