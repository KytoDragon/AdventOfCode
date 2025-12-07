module year_2015;

import utils;
import y2015.day_1;
import y2015.day_2;
import y2015.day_3;
//import y2015.day_4;
import y2015.day_5;
import y2015.day_6;

nothrow @nogc:

void year_2015() {

    day_1("resources/year_2015/day_1_example.txt", -2, 35);
    day_1("resources/year_2015/day_1_input.txt", 138, 1771);
    print_time(1);
    
    day_2("resources/year_2015/day_2_example.txt", 101, 48);
    day_2("resources/year_2015/day_2_input.txt", 1588178, 3783758);
    print_time(2);
    
    day_3("resources/year_2015/day_3_example.txt", 7, 15);
    day_3("resources/year_2015/day_3_input.txt", 2081, 2341);
    print_time(3);

    /*
    day_4("pqrstuv", 1048970, -1);
    day_4("ckczppom", -1, -1);
    print_time(4);
    */
    
    day_5("resources/year_2015/day_5_example.txt", 2, 2);
    day_5("resources/year_2015/day_5_input.txt", 238, 69);
    print_time(5);
    
    day_6("resources/year_2015/day_6_example.txt", 998996, 1001996);
    day_6("resources/year_2015/day_6_input.txt", 543903, 14687245);
    print_time(6);
}
