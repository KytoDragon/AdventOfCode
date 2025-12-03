module main;

import util.Runtime;
//import util.ThreadPool;

import year_2025 : year_2025;

nothrow @nogc:

void main() {
    init_runtime();

    year_2025();

    destroy_runtime();
}
