module y2015.day_2;

import util.Basic : free, swap;
import util.Strings : parse_integer, split_fixed;
import util.Files : read_entire_file;
import util.file.FileReader;

import utils;

nothrow @nogc:

void day_2(string input_file, int expected_result_1, int expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);
    FileReader fr = FileReader(data);
    
    int total_wrapping_paper = 0;
    int total_ribbon_length = 0;
    while (!fr.end_of_data()) {
        string line = fr.read_line();
        string[3] parts;
        int w, l, h;
        if (split_fixed(line, 'x', parts) != 3 || !parse_integer(parts[0], &w) || !parse_integer(parts[1], &l) || !parse_integer(parts[2], &h))
            return log_error(2015, 2, "Line in file ", input_file, " contains invalid input");
        // sort sides by length
        if (w > l)
            swap(w, l);
        if (l > h)
            swap(l, h);
        if (w > l)
            swap(w, l);

        int smalest_area = w*l;
        int total_area = 2 * (w*l + l*h + w*h);
        total_wrapping_paper += total_area + smalest_area;

        int smalest_perimeter = 2 * (w + l);
        int volume = w*l*h;
        total_ribbon_length += smalest_perimeter + volume;
    }

    bool result_1_matched = expected_result_1 == total_wrapping_paper;
    bool result_2_matched = expected_result_2 == total_ribbon_length;
    log_result(2015, 2, input_file, "Total wrapping paper: %# square feet, tolal ribbon length: %# feet", result_1_matched, total_wrapping_paper, result_2_matched, total_ribbon_length);
}

/*
--- Day 2: I Was Told There Would Be No Math ---

The elves are running low on wrapping paper, and so they need to submit an order for more. They have a list of the dimensions (length l, width w, and height h) of each present, and only want to order exactly as much as they need.

Fortunately, every present is a box (a perfect right rectangular prism), which makes calculating the required wrapping paper for each gift a little easier: find the surface area of the box, which is 2*l*w + 2*w*h + 2*h*l. The elves also need a little extra paper for each present: the area of the smallest side.

For example:

    A present with dimensions 2x3x4 requires 2*6 + 2*12 + 2*8 = 52 square feet of wrapping paper plus 6 square feet of slack, for a total of 58 square feet.
    A present with dimensions 1x1x10 requires 2*1 + 2*10 + 2*10 = 42 square feet of wrapping paper plus 1 square foot of slack, for a total of 43 square feet.

All numbers in the elves' list are in feet. How many total square feet of wrapping paper should they order?

--- Part Two ---

The elves are also running low on ribbon. Ribbon is all the same width, so they only have to worry about the length they need to order, which they would again like to be exact.

The ribbon required to wrap a present is the shortest distance around its sides, or the smallest perimeter of any one face. Each present also requires a bow made out of ribbon as well; the feet of ribbon required for the perfect bow is equal to the cubic feet of volume of the present. Don't ask how they tie the bow, though; they'll never tell.

For example:

    A present with dimensions 2x3x4 requires 2+2+3+3 = 10 feet of ribbon to wrap the present plus 2*3*4 = 24 feet of ribbon for the bow, for a total of 34 feet.
    A present with dimensions 1x1x10 requires 1+1+1+1 = 4 feet of ribbon to wrap the present plus 1*1*10 = 10 feet of ribbon for the bow, for a total of 14 feet.

How many total feet of ribbon should they order?
*/
