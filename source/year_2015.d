module year_2015;

import utils;
import y2015.day_1;
import y2015.day_2;
import y2015.day_3;

nothrow @nogc:

void year_2015() {

    day_1("resources/year_2015/day_1/example.txt", -2, 35);
    day_1("resources/year_2015/day_1/input.txt", 138, 1771);
    print_time(1);
    
    day_2("resources/year_2015/day_2/example.txt", 101, 48);
    day_2("resources/year_2015/day_2/input.txt", 1588178, 3783758);
    print_time(2);
    
    day_3("resources/year_2015/day_3/example.txt", 7, 15);
    day_3("resources/year_2015/day_3/input.txt", 2081, 2341);
    print_time(3);
}