module main;

import util.Runtime;

import utils;
import year_2025 : year_2025;
import year_2015 : year_2015;

nothrow @nogc:

void main() {
    init_runtime();

    print_time(0);

    year_2015();

    year_2025();

    destroy_runtime();
}
