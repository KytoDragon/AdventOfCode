module year_2025;

import y2025.day_1;
import y2025.day_2;

nothrow @nogc:

void year_2025() {
    day_1("resources/year_2025/day_1/example.txt"); // 3, 6
    day_1("resources/year_2025/day_1/input.txt"); // 1064, 6122
    
    day_2("resources/year_2025/day_2/example.txt"); // 1227775554, 4174379265
    day_2("resources/year_2025/day_2/input.txt"); // 13108371860, 22471660255
}