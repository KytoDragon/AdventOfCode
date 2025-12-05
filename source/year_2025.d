module year_2025;

import utils;
import y2025.day_1;
import y2025.day_2;
import y2025.day_3;
import y2025.day_4;
import y2025.day_5;

nothrow @nogc:

void year_2025() {
    day_1("resources/year_2025/day_1/example.txt", 3, 6);
    day_1("resources/year_2025/day_1/input.txt", 1064, 6122);
    print_time(1);

    day_2("resources/year_2025/day_2/example.txt", 1227775554, 4174379265);
    day_2("resources/year_2025/day_2/input.txt", 13108371860, 22471660255);
    print_time(2);

    day_3("resources/year_2025/day_3/example.txt", 357, 3121910778619);
    day_3("resources/year_2025/day_3/input.txt", 17311, 171419245422055);
    print_time(3);

    day_4("resources/year_2025/day_4/example.txt", 13, 43);
    day_4("resources/year_2025/day_4/input.txt", 1393, 8643);
    print_time(4);

    day_5("resources/year_2025/day_5/example.txt", 3, 14);
    day_5("resources/year_2025/day_5/input.txt", 529, 344260049617193);
    print_time(5);
}