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

    cache[sa][sb] = 1 + @min(lev(a, b, sa - 1, sb, cache_ptr, "REM"), @min(lev(a, b, sa, sb - 1, cache_ptr, "ADD"), lev(a, b, sa - 1, sb - 1, cache_ptr, "REP")));

    return cache[sa][sb];
}

fn lev2(a: []const u8, b: []const u8, cache_ptr: *[][]usize) usize {
    const cache = cache_ptr.*;

    var n1: usize = undefined;
    var n2: usize = undefined;

    for (0..b.len + 1) |i| {
        n2 = i;
        n1 = 0;
        cache[n1][n2] = n2;
    }

    for (0..a.len + 1) |i| {
        n1 = i;
        n2 = 0;
        cache[i][n2] = n1;
    }

    for (1..a.len + 1) |i| {
        n1 = i;
        for (1..b.len + 1) |j| {
            n2 = j;
            if (a[n1 - 1] == b[n2 - 1]) {
                cache[n1][n2] = cache[n1 - 1][n2 - 1];
                continue;
            }
            cache[n1][n2] = 1 + @min(cache[n1 - 1][n2], @min(cache[n1][n2 - 1], cache[n1 - 1][n2 - 1]));
        }
    }

    return cache[n1][n2];
}
pub fn diff() void {
    const a = "add";
    const b = "daddy";

    //const a = "adddfjksdfkdgjks";
    //const b = "addf9sdfjksdfjkljsdf";

    const a_len = a.len + 1;
    const b_len = b.len + 1;

    var data: [a_len][b_len]usize = undefined;

    for (0..a_len) |i| {
        for (0..b_len) |j| {
            data[i][j] = NOT_VALUE;
        }
    }

    var cache: [][]usize = undefined;
    var buffer: [a_len][]usize = undefined;

    for (0..a_len) |i| {
        // slicing the columns inside the array
        const r_ptr = &data[i];
        buffer[i] = r_ptr;
    }

    cache = buffer[0..];

    std.debug.print("A: {s} - B: {s}\n\n", .{ a, b });

    const res = lev2(a, b, &cache);

    std.debug.print("RES {}\n", .{res});
}
