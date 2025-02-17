const std = @import("std");

const NOT_VALUE = 1111110;

fn lev(a: []const u8, b: []const u8, sa: usize, sb: usize, cache_ptr: *[][]usize, op: *const [3]u8) usize {
    const cache = cache_ptr.*;

    std.debug.print("OP: {s} a: {s}({}) - b:{s}({}) - cache: {}\n", .{ op, a[0 .. sa + 1], sa, b[0 .. sb + 1], sb, cache[sa][sb] });

    if (cache[sa][sb] != NOT_VALUE) {
        std.debug.print("OUT\n", .{});
        return cache[sa][sb];
    }

    if (sa == 0) {
        cache[sa][sb] = sb;
        std.debug.print("OUT\n", .{});
        return cache[sa][sb];
    }

    if (sb == 0) {
        cache[sa][sb] = sa;
        std.debug.print("OUT\n", .{});
        return cache[sa][sb];
    }

    const a_last_char = a[sa];
    const b_last_char = b[sb];

    std.debug.print("last_a {c}\nlast_b: {c}\n", .{ a_last_char, b_last_char });

    if (a_last_char == b_last_char) {
        cache[sa][sb] = lev(a, b, sa - 1, sb - 1, cache_ptr, "IG"); // IGNORE
        std.debug.print("OUT\n", .{});
        return cache[sa][sb];
    }

    //cache[sa][sb] = 1 + @min(lev(a, b, sa - 1, sb, cache_ptr, "REM"), @min(lev(a, b, sa, sb - 1, cache_ptr, "ADD"), lev(a, b, sa - 1, sb - 1, cache_ptr, "REP")));

    //return cache[sa][sb];

    const rem = lev(a, b, sa - 1, sb, cache_ptr, "REM"); // REMOVE
    const add = lev(a, b, sa, sb - 1, cache_ptr, "ADD"); // ADD
    const rep = lev(a, b, sa - 1, sb - 1, cache_ptr, "REP"); // REPLACE
    if (rem <= add and rem <= rep) {
        std.debug.print("REM CHOOSED{}\n", .{rem});
        cache[sa][sb] = 1 + rem;
    } else if (add < rem and add < rep) {
        std.debug.print("ADD CHOOSED {}\n", .{add});
        cache[sa][sb] = 1 + add;
    } else if (rep < rem and rep < add) {
        std.debug.print("REP CHOOSED {}\n", .{rep});
        cache[sa][sb] = 1 + rep;
    }

    std.debug.print("-----------------------\n", .{});
    return cache[sa][sb];
}

pub fn diff() void {
    //const a = "add";
    //const b = "daddy";

    const a = "adddfjksdfkdgjks";
    const b = "addf9sdfjksdfjkljsdf";

    var data: [a.len][b.len]usize = undefined;

    for (0..a.len) |i| {
        for (0..b.len) |j| {
            data[i][j] = NOT_VALUE;
        }
    }

    var cache: [][]usize = undefined;
    var buffer: [a.len][]usize = undefined;

    for (0..a.len) |i| {
        // slicing the columns inside the array
        const r_ptr = &data[i];
        buffer[i] = r_ptr;
    }

    cache = buffer[0..];

    std.debug.print("A: {s} - B: {s}\n\n", .{ a, b });

    const res = lev(a, b, a.len - 1, b.len - 1, &cache, "INI");

    std.debug.print("RES {}\n", .{res});
}
