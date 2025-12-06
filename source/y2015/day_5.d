module y2015.day_5;

import util.Basic : free;
import util.Files : read_entire_file;
import util.Strings : contains;
import util.file.FileReader;

import utils;

nothrow @nogc:

void day_5(string input_file, int expected_result_1, int expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);
    FileReader fr = FileReader(data);

    int nice_strings;
    int new_nice_strings;
    while (!fr.end_of_data()) {
        string line = fr.read_line();
        if (is_string_nice(line))
            nice_strings += 1;
        if (is_new_string_nice(line))
            new_nice_strings += 1;
    }
    

    bool result_1_matched = expected_result_1 == nice_strings;
    bool result_2_matched = expected_result_2 == new_nice_strings;
    log_result(2015, 5, input_file, "Number of nice strings: %#, Number of new nice strings: %#", result_1_matched, nice_strings, result_2_matched, new_nice_strings);
}

bool is_string_nice(string s) {
    int num_vowels;
    bool double_letter;
    foreach (i, char c; s) {
        if (num_vowels < 3 && contains("aeiou", c))
            num_vowels += 1;
        if (i > 0) {
            char previous = s[i-1];
            if (previous == c)
                double_letter = true;
            if (c == 'b' && previous == 'a')
                return false;
            if (c == 'd' && previous == 'c')
                return false;
            if (c == 'q' && previous == 'p')
                return false;
            if (c == 'y' && previous == 'x')
                return false;
        }
    }
    return double_letter && num_vowels >= 3;
}

bool is_new_string_nice(string s) {
    bool two_letter_repeat;
    bool double_letter_with_gap;
    foreach (i, char c; s) {
        if (!two_letter_repeat && i > 0)
            two_letter_repeat = contains(s[i+1..$], s[i-1..i+1]);
        if (!double_letter_with_gap && i > 1)
            double_letter_with_gap = c == s[i-2];
    }
    return two_letter_repeat && double_letter_with_gap;
}

/*
--- Day 5: Doesn't He Have Intern-Elves For This? ---

Santa needs help figuring out which strings in his text file are naughty or nice.

A nice string is one with all of the following properties:

    It contains at least three vowels (aeiou only), like aei, xazegov, or aeiouaeiouaeiou.
    It contains at least one letter that appears twice in a row, like xx, abcdde (dd), or aabbccdd (aa, bb, cc, or dd).
    It does not contain the strings ab, cd, pq, or xy, even if they are part of one of the other requirements.

For example:

    ugknbfddgicrmopn is nice because it has at least three vowels (u...i...o...), a double letter (...dd...), and none of the disallowed substrings.
    aaa is nice because it has at least three vowels and a double letter, even though the letters used by different rules overlap.
    jchzalrnumimnmhp is naughty because it has no double letter.
    haegwjzuvuyypxyu is naughty because it contains the string xy.
    dvszwmarrgswjxmb is naughty because it contains only one vowel.

How many strings are nice?

--- Part Two ---

Realizing the error of his ways, Santa has switched to a better model of determining whether a string is naughty or nice. None of the old rules apply, as they are all clearly ridiculous.

Now, a nice string is one with all of the following properties:

    It contains a pair of any two letters that appears at least twice in the string without overlapping, like xyxy (xy) or aabcdefgaa (aa), but not like aaa (aa, but it overlaps).
    It contains at least one letter which repeats with exactly one letter between them, like xyx, abcdefeghi (efe), or even aaa.

For example:

    qjhvhtzxzqqjkmpb is nice because is has a pair that appears twice (qj) and a letter that repeats with exactly one letter between them (zxz).
    xxyxx is nice because it has a pair that appears twice and a letter that repeats with one between, even though the letters used by each rule overlap.
    uurcxstgmygtbstg is naughty because it has a pair (tg) but no repeat with a single letter between them.
    ieodomkazucvgmuy is naughty because it has a repeating letter with one between (odo), but no pair that appears twice.

How many strings are nice under these new rules?
*/
