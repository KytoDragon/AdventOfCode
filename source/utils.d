module utils;

import util.Basic;
import util.Strings : concat;
import util.Varargs;

nothrow @nogc:

enum HIGHLIGHT_START = "\x1b[32m";
enum HIGHLIGHT_END = "\x1b[0m";

void log_error(A...)(string year, string day, A a) {
    mixin varargs!a;
    return log_result(year, day, concat(va_args));
}

void log_error(string year, string day, string message) {
    print("Year ", year, " day ", day, " encountered an error: ", message, "\n");
}

void log_result(A...)(string year, string day, A a) {
    mixin varargs!a;
    return log_result(year, day, concat(va_args));
}

void log_result(string year, string day, string result) {
    print("Result for year ", year, " day ", day, ": ", result, "\n");
}
