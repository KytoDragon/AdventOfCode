module y2025.day_8;

import util.Basic : free, new_array, u64;
import util.Files : read_entire_file;
import util.Strings : parse_integer, index_of, last_index_of;
import util.Algorithm : sort;
import util.file.FileReader;
import util.List;

import utils;

nothrow @nogc:

void day_8(string input_file, int num_connections, int expected_result_1, int expected_result_2) {
    ubyte[] data = read_entire_file(input_file);
    if (!data)
        return;
    scope(exit) free(data);

    JunctionBox[] junction_boxes = parse_junction_boxes(data);
    if (!junction_boxes)
        return log_error(2025, 8, "Could not parse line in file ", input_file);
    scope(exit) free(junction_boxes);

    int product_of_three_largest_circuits;
    int distance_to_edge_of_last_connection;

    // calculate all connections incl. distances and sort by distance. Memory is O(n^2), time is O(n^2 + n^2 * log(n^2) + n^2 + n + n * log(n))
    Connection[] connections = new_array!Connection(junction_boxes.length * (junction_boxes.length - 1) / 2);
    scope(exit) free(connections);
    int connection_index;
    for (int i = 0; i < junction_boxes.length - 1; i++) {
        JunctionBox a = junction_boxes[i];
        for (int j = i + 1; j < junction_boxes.length; j++) {
            JunctionBox b = junction_boxes[j];
            u64 distance_squared = (a.x - b.x) * cast(u64)(a.x - b.x) + (a.y - b.y) * cast(u64)(a.y - b.y) + (a.z - b.z) * cast(u64)(a.z - b.z);
            connections[connection_index].distance_squared = distance_squared;
            connections[connection_index].i = cast(ushort)i;
            connections[connection_index].j = cast(ushort)j;
            connection_index += 1;
        }
    }
    sort(connections, function(Connection a, Connection b) { return a.distance_squared > b.distance_squared; });

    int num_networks = cast(int)junction_boxes.length;
    for (int c = 0; c < connections.length; c++) {
        int network_to_merge_a = junction_boxes[connections[c].i].networkID;
        int network_to_merge_b = junction_boxes[connections[c].j].networkID;

        // Merge networks
        if (network_to_merge_a != network_to_merge_b) {
            num_networks -= 1;
            foreach (ref junction_box; junction_boxes) {
                if (junction_box.networkID == network_to_merge_b)
                    junction_box.networkID = network_to_merge_a;
            }
            // until we have one giant network
            if (num_networks == 1) {
                distance_to_edge_of_last_connection = cast(int)junction_boxes[connections[c].i].x * cast(int)junction_boxes[connections[c].j].x;
                break;
            }
        }
        
        // calculate result for part 1
        num_connections -= 1;
        if (num_connections == 0) {
            int[] network_sizes = new_array!int(junction_boxes.length);
            scope(exit) free(network_sizes);
            foreach (junction_box; junction_boxes) {
                network_sizes[junction_box.networkID] += 1;
            }
            sort(network_sizes, function(int a, int b) { return a < b; });

            product_of_three_largest_circuits = network_sizes[0] * network_sizes[1] * network_sizes[2];
        }
    }

    bool result_1_matched = expected_result_1 == product_of_three_largest_circuits;
    bool result_2_matched = expected_result_2 == distance_to_edge_of_last_connection;
    log_result(2025, 8, input_file, "Product of three largest circuits: %#, Product of x coordinates of last connection: %#", result_1_matched, product_of_three_largest_circuits, result_2_matched, distance_to_edge_of_last_connection);
}

private:

struct JunctionBox {
    int x=0, y=0, z=0;
    int networkID;
}

JunctionBox[] parse_junction_boxes(ubyte[] data) {
    
    List!JunctionBox junction_boxes;

    FileReader fr = FileReader(data);
    while (!fr.end_of_data()) {
        string line = fr.read_line();

        long first_comma = index_of(line, ',');
        long second_comma = last_index_of(line, ',');
        JunctionBox box;
        box.networkID = junction_boxes.length;
        if (first_comma < 0 || second_comma == first_comma || !parse_integer(line[0..first_comma], &box.x)
                || !parse_integer(line[first_comma + 1..second_comma], &box.y) || !parse_integer(line[second_comma + 1..$], &box.z))
            return null;
        
        junction_boxes.add(box);
    }
    return junction_boxes.as_array();
}

struct Connection {
    float distance_squared;
    ushort i;
    ushort j;
}

// simple version that find the smallest distance one at a time. Memory is O(n), time is O(n^3 + n^3 + n + n * log(n))
void solution_brute_force(int num_connections, JunctionBox[] junction_boxes) {
    int product_of_three_largest_circuits;
    int distance_to_edge_of_last_connection;
    
    int last_closest_distance_squared = 0;
    int last_closest_distance_index = 0;
    int num_networks = cast(int)junction_boxes.length;
    while (num_networks > 1) {
        int network_to_merge_a = -1;
        int network_to_merge_b = -1;
        int closest_distance_squared = int.max;
        int closest_distance_index = last_closest_distance_index;

        // find the two closest junctions boxes that we have not already connected
        if (num_connections > 0) {
            for (int i = 0; i < junction_boxes.length - 1; i++) {
                JunctionBox a = junction_boxes[i];
                for (int j = i + 1; j < junction_boxes.length; j++) {
                    JunctionBox b = junction_boxes[j];
                    int distance_squared = (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y) + (a.z - b.z) * (a.z - b.z);
                    int index = (i << 16) | j;
                    // We need the smallest distance that is larger than the smallest distance found last time.
                    // The index makes shure we visit all connections that have the same distance in order
                    if (distance_squared > last_closest_distance_squared || (distance_squared == last_closest_distance_squared && index > last_closest_distance_index)) {
                        if (distance_squared < closest_distance_squared || (distance_squared == closest_distance_squared && index < closest_distance_index)) {
                            closest_distance_index = index;
                            closest_distance_squared = distance_squared;
                            network_to_merge_a = a.networkID;
                            network_to_merge_b = b.networkID;
                        }
                    }
                }
            }

            // After we have found the solution for part one, we only care about connections that connect two different circuits
        } else {
            for (int i = 0; i < junction_boxes.length - 1; i++) {
                JunctionBox a = junction_boxes[i];
                for (int j = i + 1; j < junction_boxes.length; j++) {
                    JunctionBox b = junction_boxes[j];
                    if (a.networkID != b.networkID) {
                        int distance_squared = (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y) + (a.z - b.z) * (a.z - b.z);
                        if (distance_squared < closest_distance_squared) {
                            int index = (i << 16) | j;
                            closest_distance_index = index;
                            closest_distance_squared = distance_squared;
                            network_to_merge_a = a.networkID;
                            network_to_merge_b = b.networkID;
                        }
                    }
                }
            }
        }

        // Merge networks
        if (network_to_merge_a != network_to_merge_b) {
            num_networks -= 1;
            foreach (ref junction_box; junction_boxes) {
                if (junction_box.networkID == network_to_merge_b)
                    junction_box.networkID = network_to_merge_a;
            }
            if (num_networks == 1) {
                int j = closest_distance_index & 0xFFFF;
                int i = closest_distance_index >> 16;
                distance_to_edge_of_last_connection = cast(int)junction_boxes[i].x * cast(int)junction_boxes[j].x;
                break;
            }
        }

        // calculate result for part 1
        num_connections -= 1;
        if (num_connections == 0) {
            int[] network_sizes = new_array!int(junction_boxes.length);
            scope(exit) free(network_sizes);
            foreach (junction_box; junction_boxes) {
                network_sizes[junction_box.networkID] += 1;
            }
            sort(network_sizes, function(int a, int b) { return a < b; });

            product_of_three_largest_circuits = network_sizes[0] * network_sizes[1] * network_sizes[2];
        }

        last_closest_distance_squared = closest_distance_squared;
        last_closest_distance_index = closest_distance_index;
    }
}

/*
--- Day 8: Playground ---

Equipped with a new understanding of teleporter maintenance, you confidently step onto the repaired teleporter pad.

You rematerialize on an unfamiliar teleporter pad and find yourself in a vast underground space which contains a giant playground!

Across the playground, a group of Elves are working on setting up an ambitious Christmas decoration project. Through careful rigging, they have suspended a large number of small electrical junction boxes.

Their plan is to connect the junction boxes with long strings of lights. Most of the junction boxes don't provide electricity; however, when two junction boxes are connected by a string of lights, electricity can pass between those two junction boxes.

The Elves are trying to figure out which junction boxes to connect so that electricity can reach every junction box. They even have a list of all of the junction boxes' positions in 3D space (your puzzle input).

For example:

162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689

This list describes the position of 20 junction boxes, one per line. Each position is given as X,Y,Z coordinates. So, the first junction box in the list is at X=162, Y=817, Z=812.

To save on string lights, the Elves would like to focus on connecting pairs of junction boxes that are as close together as possible according to straight-line distance. In this example, the two junction boxes which are closest together are 162,817,812 and 425,690,689.

By connecting these two junction boxes together, because electricity can flow between them, they become part of the same circuit. After connecting them, there is a single circuit which contains two junction boxes, and the remaining 18 junction boxes remain in their own individual circuits.

Now, the two junction boxes which are closest together but aren't already directly connected are 162,817,812 and 431,825,988. After connecting them, since 162,817,812 is already connected to another junction box, there is now a single circuit which contains three junction boxes and an additional 17 circuits which contain one junction box each.

The next two junction boxes to connect are 906,360,560 and 805,96,715. After connecting them, there is a circuit containing 3 junction boxes, a circuit containing 2 junction boxes, and 15 circuits which contain one junction box each.

The next two junction boxes are 431,825,988 and 425,690,689. Because these two junction boxes were already in the same circuit, nothing happens!

This process continues for a while, and the Elves are concerned that they don't have enough extension cables for all these circuits. They would like to know how big the circuits will be.

After making the ten shortest connections, there are 11 circuits: one circuit which contains 5 junction boxes, one circuit which contains 4 junction boxes, two circuits which contain 2 junction boxes each, and seven circuits which each contain a single junction box. Multiplying together the sizes of the three largest circuits (5, 4, and one of the circuits of size 2) produces 40.

Your list contains many junction boxes; connect together the 1000 pairs of junction boxes which are closest together. Afterward, what do you get if you multiply together the sizes of the three largest circuits?

--- Part Two ---

The Elves were right; they definitely don't have enough extension cables. You'll need to keep connecting junction boxes together until they're all in one large circuit.

Continuing the above example, the first connection which causes all of the junction boxes to form a single circuit is between the junction boxes at 216,146,977 and 117,168,530. The Elves need to know how far those junction boxes are from the wall so they can pick the right extension cable; multiplying the X coordinates of those two junction boxes (216 and 117) produces 25272.

Continue connecting the closest unconnected pairs of junction boxes together until they're all in the same circuit. What do you get if you multiply together the X coordinates of the last two junction boxes you need to connect?
*/
