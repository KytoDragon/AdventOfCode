module year_2025;

import utils;
import y2025.day_1;
import y2025.day_2;
import y2025.day_3;
import y2025.day_4;
import y2025.day_5;
import y2025.day_6;
import y2025.day_7;

nothrow @nogc:

void year_2025() {
    day_1("resources/year_2025/day_1_example.txt", 3, 6);
    day_1("resources/year_2025/day_1_input.txt", 1064, 6122);
    print_time(1);

    day_2("resources/year_2025/day_2_example.txt", 1227775554, 4174379265);
    day_2("resources/year_2025/day_2_input.txt", 13108371860, 22471660255);
    print_time(2);

    day_3("resources/year_2025/day_3_example.txt", 357, 3121910778619);
    day_3("resources/year_2025/day_3_input.txt", 17311, 171419245422055);
    print_time(3);

    day_4("resources/year_2025/day_4_example.txt", 13, 43);
    day_4("resources/year_2025/day_4_input.txt", 1393, 8643);
    print_time(4);

    day_5("resources/year_2025/day_5_example.txt", 3, 14);
    day_5("resources/year_2025/day_5_input.txt", 529, 344260049617193);
    print_time(5);

    day_6("resources/year_2025/day_6_example.txt", 4277556, 3263827);
    day_6("resources/year_2025/day_6_input.txt", 5784380717354, 7996218225744);
    print_time(6);

    day_7("resources/year_2025/day_7_example.txt", 21, 40);
    day_7("resources/year_2025/day_7_input.txt", 1507, 1537373473728);
    print_time(7);
}