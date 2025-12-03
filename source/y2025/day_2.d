module y2025.day_2;

import util.Basic : free, u64;
import util.Strings : parse_integer, split, print_integer_fixed, index_of;
import util.Files : read_entire_file, get_filename_from_path;
import util.Math : log10, pow;
import util.file.FileReader;

import utils;

nothrow @nogc:

void day_2(string input_file, u64 expected_result_1, u64 expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);
    FileReader fr = FileReader(data);
    
    u64 sum_invalid_ids;
    u64 sum_invalid_ids_b;
    string[] ranges = split(fr.read_line(), ',');
    foreach (string range; ranges) {
        string[] parts = split(range, '-');
        u64 first_id, last_id;
        if (parts.length != 2 || !parse_integer(parts[0], &first_id) || !parse_integer(parts[1], &last_id))
            return log_error(2025, 2, "Could not parse ranges");
        
        /*
        char[20] buffer = null;
        for (u64 i = first_id; i <= last_id; i++) {
            string value = print_integer_fixed(buffer[], i);
            if (is_invalid_id_basic(value))
                sum_invalid_ids += i;
            if (is_invalid_id_b_basic(value))
                sum_invalid_ids_b += i;
        }
        */

        sum_invalid_ids += sum_invalid_id_fast(first_id, last_id);
        sum_invalid_ids_b += sum_invalid_id_b_fast(first_id, last_id);
    }

    bool result_1_matched = expected_result_1 == sum_invalid_ids;
    bool result_2_matched = expected_result_2 == sum_invalid_ids_b;
    log_result(2025, 2, input_file, "Sum of invalid IDs (repeated twice): %#, Sum of invalid IDs (any repeat): %#", result_1_matched, sum_invalid_ids, result_2_matched, sum_invalid_ids_b);
}

private:

bool is_invalid_id_basic(string id) {
    if (id.length % 2 == 1)
        return false;
    
    return id[0..id.length / 2] == id[id.length / 2..$];
}

bool is_invalid_id_b_basic(string id) {
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

u64 sum_invalid_id_fast(u64 first_id, u64 last_id) {
    int lengthStart = log10(first_id) + 1;
    int lengthEnd = log10(last_id) + 1;
    u64 sum_invalid_ids;

    // Split into ranges of the same order of magnitude
    for (int i = lengthStart; i <= lengthEnd; i++) {
        if (i % 2 == 1)
            continue;

        u64 range_start = pow(10L, i - 1);
        if (range_start < first_id)
            range_start = first_id;
            
        u64 range_end = pow(10L, i) - 1;
        if (range_end > last_id)
            range_end = last_id;
        
        // repeating patterns are always a multiple of 11, 101, 1001, 10001, etc.
        u64 match_pattern = pow(10L, i / 2) + 1;

        // clip range to multiples of the pattern
        if (range_start % match_pattern != 0)
            range_start += match_pattern - range_start % match_pattern;
        range_end -= range_end % match_pattern;
        if (range_end < range_start)
            continue;

        u64 num_multiples = (range_end - range_start) / match_pattern + 1;
        sum_invalid_ids += range_start * num_multiples + ((num_multiples - 1) * num_multiples / 2) * match_pattern;
    }
    
    return sum_invalid_ids;
}

u64 sum_invalid_id_b_fast(u64 first_id, u64 last_id) {
    int lengthStart = log10(first_id) + 1;
    int lengthEnd = log10(last_id) + 1;
    u64 sum_invalid_ids;
    
    int[8] primes = [2, 3, 5, 7, 11, 13, 17, 19];

    // Split into ranges of the same order of magnitude
    for (int i = lengthStart; i <= lengthEnd; i++) {

        u64 range_start = pow(10L, i - 1);
        if (range_start < first_id)
            range_start = first_id;
            
        u64 range_end = pow(10L, i) - 1;
        if (range_end > last_id)
            range_end = last_id;
        
        // repeating patterns are always a multiple of 11, 111, 0101, 1111, 11111, 001001, 010101, 111111, etc.
        // numbers which are a multiple of more than one pattern-number would get counted mutiple times (e.g. 222222 is a multiple of 111111, 010101 and 001001)
        // solution: get the prime factors of i excluding 1.
        //              if there is only one, we don't need to worry about double counting
        //              if there are two prime factors (can only have two for numbers < 20), use these for the mask and subtract the mask of their product
        int first_prime;
        int second_prime;

        for (int j = 2; j <= i; j++) { // j contains the number of times a part of a number is repeated. e.q. 2 is 001001, 3 is 010101 and 6 is 111111
            if (i % j != 0)
                continue;
            bool negate = j == first_prime * second_prime;
            if (index_of(primes, j) < 0 && !negate)
                continue;

            u64 match_pattern = 0;
            for (int k = 0; k < j; k++) {
                match_pattern = match_pattern * pow(10L, i / j) + 1;
            }

            // clip range to multiples of the pattern
            u64 sub_range_start = range_start;
            if (sub_range_start % match_pattern != 0)
                sub_range_start += match_pattern - sub_range_start % match_pattern;
            u64 sub_range_end = range_end - range_end % match_pattern;
            if (sub_range_end < sub_range_start)
                continue;

            u64 num_multiples = (sub_range_end - sub_range_start) / match_pattern + 1;
            u64 sub_sum_invalid_ids = sub_range_start * num_multiples + ((num_multiples - 1) * num_multiples / 2) * match_pattern;

            if (negate)
                sum_invalid_ids -= sub_sum_invalid_ids;
            else {
                sum_invalid_ids += sub_sum_invalid_ids;
                if (first_prime == 0)
                    first_prime = j;
                else
                    second_prime = j;
            }
        }
    }
    
    return sum_invalid_ids;
}

/*
--- Day 2: Gift Shop ---

You get inside and take the elevator to its only other stop: the gift shop. "Thank you for visiting the North Pole!" gleefully exclaims a nearby sign. You aren't sure who is even allowed to visit the North Pole, but you know you can access the lobby through here, and from there you can access the rest of the North Pole base.

As you make your way through the surprisingly extensive selection, one of the clerks recognizes you and asks for your help.

As it turns out, one of the younger Elves was playing on a gift shop computer and managed to add a whole bunch of invalid product IDs to their gift shop database! Surely, it would be no trouble for you to identify the invalid product IDs for them, right?

They've even checked most of the product ID ranges already; they only have a few product ID ranges (your puzzle input) that you'll need to check. For example:

11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124

(The ID ranges are wrapped here for legibility; in your input, they appear on a single long line.)

The ranges are separated by commas (,); each range gives its first ID and last ID separated by a dash (-).

Since the young Elf was just doing silly patterns, you can find the invalid IDs by looking for any ID which is made only of some sequence of digits repeated twice. So, 55 (5 twice), 6464 (64 twice), and 123123 (123 twice) would all be invalid IDs.

None of the numbers have leading zeroes; 0101 isn't an ID at all. (101 is a valid ID that you would ignore.)

Your job is to find all of the invalid IDs that appear in the given ranges. In the above example:

    11-22 has two invalid IDs, 11 and 22.
    95-115 has one invalid ID, 99.
    998-1012 has one invalid ID, 1010.
    1188511880-1188511890 has one invalid ID, 1188511885.
    222220-222224 has one invalid ID, 222222.
    1698522-1698528 contains no invalid IDs.
    446443-446449 has one invalid ID, 446446.
    38593856-38593862 has one invalid ID, 38593859.
    The rest of the ranges contain no invalid IDs.

Adding up all the invalid IDs in this example produces 1227775554.

What do you get if you add up all of the invalid IDs?

--- Part Two ---

The clerk quickly discovers that there are still invalid IDs in the ranges in your list. Maybe the young Elf was doing other silly patterns as well?

Now, an ID is invalid if it is made only of some sequence of digits repeated at least twice. So, 12341234 (1234 two times), 123123123 (123 three times), 1212121212 (12 five times), and 1111111 (1 seven times) are all invalid IDs.

From the same example as before:

    11-22 still has two invalid IDs, 11 and 22.
    95-115 now has two invalid IDs, 99 and 111.
    998-1012 now has two invalid IDs, 999 and 1010.
    1188511880-1188511890 still has one invalid ID, 1188511885.
    222220-222224 still has one invalid ID, 222222.
    1698522-1698528 still contains no invalid IDs.
    446443-446449 still has one invalid ID, 446446.
    38593856-38593862 still has one invalid ID, 38593859.
    565653-565659 now has one invalid ID, 565656.
    824824821-824824827 now has one invalid ID, 824824824.
    2121212118-2121212124 now has one invalid ID, 2121212121.

Adding up all the invalid IDs in this example produces 4174379265.

What do you get if you add up all of the invalid IDs using these new rules?
*/
