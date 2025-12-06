module y2025.day_6;

import util.Basic : free, u64, s64, temporary_allocator, new_array;
import util.Files : read_entire_file;
import util.Strings : parse_integer, eat_spaces;
import util.file.FileReader;
import util.List;

import utils;

nothrow @nogc:

void day_6(string input_file, u64 expected_result_1, u64 expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);
    FileReader fr = FileReader(data);

    string[] numbers;
    string operators;

    {
        List!string lines;
        lines.allocator = &temporary_allocator;
        while (!fr.end_of_data()) {
            lines.add(fr.read_line());
        }
        operators = lines.pop();
        numbers = lines.as_array();
    }

    u64 sum_of_horizontal_results;
    u64 sum_of_vertical_results;
    int index;
    char[] buffer = new_array!char(numbers.length, &temporary_allocator);
    while (index < operators.length) {
        string operator = pop_operator(operators, index);
        int end_of_column = index + cast(int)operator.length;

        if (index + operator.length < operators.length) // there is at least on space between columns
            end_of_column -= 1;

        if (operator[0] == '*') {
            u64 horizontal_result = 1;
            foreach (string number; numbers) {
                horizontal_result *= get_number(number[index..end_of_column]);
            }
            sum_of_horizontal_results += horizontal_result;

            u64 vertical_result = 1;
            for (int i = index; i < end_of_column; i++) {
                foreach (j, string number; numbers) {
                    buffer[j] = number[i];
                }
                vertical_result *= get_number(cast(string)buffer);
            }
            sum_of_vertical_results += vertical_result;
            
        } else if (operator[0] == '+') {
            u64 horizontal_result = 0;
            foreach (string number; numbers) {
                horizontal_result += get_number(number[index..end_of_column]);
            }
            sum_of_horizontal_results += horizontal_result;
            

            u64 vertical_result = 0;
            for (int i = index; i < end_of_column; i++) {
                foreach (j, string number; numbers) {
                    buffer[j] = number[i];
                }
                vertical_result += get_number(cast(string)buffer);
            }
            sum_of_vertical_results += vertical_result;

        } else {
            return log_error(2025, 6, "Unknown operator in file ", input_file);
        }
        index += operator.length;
    }
    
    
    bool result_1_matched = expected_result_1 == sum_of_horizontal_results;
    bool result_2_matched = expected_result_2 == sum_of_vertical_results;
    log_result(2025, 6, input_file, "Sum of horizontal results: %#, Sum of vertical results %#", result_1_matched, sum_of_horizontal_results, result_2_matched, sum_of_vertical_results);
}

string pop_operator(string line, int index) {
    int end_of_column = index + 1;
    while (end_of_column < line.length && line[end_of_column] == ' ')
        end_of_column += 1;
    
    return line[index..end_of_column];
}

int get_number(string line) {
    eat_spaces(&line);
    int result;
    parse_integer(line, &result);
    return result;
}

/*
--- Day 6: Trash Compactor ---

After helping the Elves in the kitchen, you were taking a break and helping them re-enact a movie scene when you over-enthusiastically jumped into the garbage chute!

A brief fall later, you find yourself in a garbage smasher. Unfortunately, the door's been magnetically sealed.

As you try to find a way out, you are approached by a family of cephalopods! They're pretty sure they can get the door open, but it will take some time. While you wait, they're curious if you can help the youngest cephalopod with her math homework.

Cephalopod math doesn't look that different from normal math. The math worksheet (your puzzle input) consists of a list of problems; each problem has a group of numbers that need to be either added (+) or multiplied (*) together.

However, the problems are arranged a little strangely; they seem to be presented next to each other in a very long horizontal list. For example:

123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  

Each problem's numbers are arranged vertically; at the bottom of the problem is the symbol for the operation that needs to be performed. Problems are separated by a full column of only spaces. The left/right alignment of numbers within each problem can be ignored.

So, this worksheet contains four problems:

    123 * 45 * 6 = 33210
    328 + 64 + 98 = 490
    51 * 387 * 215 = 4243455
    64 + 23 + 314 = 401

To check their work, cephalopod students are given the grand total of adding together all of the answers to the individual problems. In this worksheet, the grand total is 33210 + 490 + 4243455 + 401 = 4277556.

Of course, the actual worksheet is much wider. You'll need to make sure to unroll it completely so that you can read the problems clearly.

Solve the problems on the math worksheet. What is the grand total found by adding together all of the answers to the individual problems?

--- Part Two ---

The big cephalopods come back to check on how things are going. When they see that your grand total doesn't match the one expected by the worksheet, they realize they forgot to explain how to read cephalopod math.

Cephalopod math is written right-to-left in columns. Each number is given in its own column, with the most significant digit at the top and the least significant digit at the bottom. (Problems are still separated with a column consisting only of spaces, and the symbol at the bottom of the problem is still the operator to use.)

Here's the example worksheet again:

123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  

Reading the problems right-to-left one column at a time, the problems are now quite different:

    The rightmost problem is 4 + 431 + 623 = 1058
    The second problem from the right is 175 * 581 * 32 = 3253600
    The third problem from the right is 8 + 248 + 369 = 625
    Finally, the leftmost problem is 356 * 24 * 1 = 8544

Now, the grand total is 1058 + 3253600 + 625 + 8544 = 3263827.

Solve the problems on the math worksheet again. What is the grand total found by adding together all of the answers to the individual problems?
*/
