const std = @import("std");

const NOT_VALUE = 1111110;
var NOT_VALUE_ACTION: u8 = '-';
const IGNORE = 'I';
const ADD = 'A';
const REMOVE = 'R';
const REPLACE = 'S';

fn print_cache(d_cache_ptr: *[][]usize, a_cache_ptr: *[][]u8, a_len: usize, b_len: usize) void {
    const distances = d_cache_ptr.*;
    const actions = a_cache_ptr.*;

    for (0..a_len) |i| {
        for (0..b_len) |j| {
            std.debug.print("{d} ({c}) ", .{ distances[i][j], actions[i][j] });
        }
        std.debug.print("\n", .{});
    }
}

fn lev(a: []const u8, b: []const u8, distances_cache_ptr: *[][]usize, actions_ptr: *[][]u8) usize {
    const cache = distances_cache_ptr.*;
    const actions = actions_ptr.*;

    var n1: usize = undefined;
    var n2: usize = undefined;

    cache[0][0] = 0;
    actions[0][0] = IGNORE;

    for (1..b.len + 1) |i| {
        n2 = i;
        n1 = 0;
        actions[n1][n2] = ADD;
        cache[n1][n2] = n2;
    }

    for (1..a.len + 1) |i| {
        n1 = i;
        n2 = 0;
        actions[n1][n2] = REMOVE;
        cache[i][n2] = n1;
    }

    for (1..a.len + 1) |i| {
        n1 = i;
        for (1..b.len + 1) |j| {
            n2 = j;
            if (a[n1 - 1] == b[n2 - 1]) {
                cache[n1][n2] = cache[n1 - 1][n2 - 1];
                actions[n1][n2] = IGNORE;
                continue;
            }

            const rem = cache[n1 - 1][n2];
            const add = cache[n1][n2 - 1];
            const rep = cache[n1 - 1][n2 - 1];

            cache[n1][n2] = rem;
            actions[n1][n2] = REMOVE;

            if (cache[n1][n2] > add) {
                cache[n1][n2] = add;
                actions[n1][n2] = ADD;
            }

            if (cache[n1][n2] > rep) {
                cache[n1][n2] = rep;
                actions[n1][n2] = REPLACE;
            }

            cache[n1][n2] += 1;
        }
    }

    n1 = a.len;
    n2 = b.len;

    //TODO: MAYBE RETURN THE DIFFING STRUCTURING OR SAVE FOR OUTSIDE PRINTING
    while (n1 > 0 or n2 > 0) {
        const action = actions[n1][n2];

        if (action == ADD) {
            n2 -= 1;
            std.debug.print("{c}({c}) - ", .{ action, b[n2] });
        } else if (action == REMOVE) {
            n1 -= 1;
            std.debug.print("{c}({c}) - ", .{ action, b[n2] });
        } else if (action == REPLACE) {
            n1 -= 1;
            n2 -= 1;
            std.debug.print("{c}({c}) - ", .{ action, a[n1] });
        } else if (action == IGNORE) {
            n1 -= 1;
            n2 -= 1;
            std.debug.print("{c}({c}) - ", .{ action, a[n1] });
        } else {
            std.debug.assert(false);
            std.debug.print("ERROR", .{});
        }
    }

    return cache[n1][n2];
}
pub fn diff() void {
    const a = "add";
    const b = "daddyyyy";

    //const a = "adddfjksdfkdgjks";
    //const b = "addf9sdfjksdfjkljsdf";

    const a_len = a.len + 1;
    const b_len = b.len + 1;

    var data: [a_len][b_len]usize = undefined;
    var action_data: [a_len][b_len]u8 = undefined;

    for (0..a_len) |i| {
        for (0..b_len) |j| {
            data[i][j] = NOT_VALUE;
            action_data[i][j] = '-';
        }
    }

    var distances: [][]usize = undefined;
    var actions: [][]u8 = undefined;
    var buffer: [a_len][]usize = undefined;
    var buffer_actions: [a_len][]u8 = undefined;

    for (0..a_len) |i| {
        // slicing the columns inside the array
        const buf_distances_ptr = &data[i];
        const buf_actions_ptr = &action_data[i];
        buffer[i] = buf_distances_ptr;
        buffer_actions[i] = buf_actions_ptr;
    }

    distances = buffer[0..];
    actions = buffer_actions[0..];

    std.debug.print("A: {s} - B: {s}\n\n", .{ a, b });

    const res = lev(a, b, &distances, &actions);

    //print_cache(&distances, &actions, a_len, b_len);

    std.debug.print("\nRES {}\n", .{res});
}
