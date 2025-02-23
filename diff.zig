const std = @import("std");

const NOT_VALUE = 1111110;
var NOT_VALUE_ACTION: u8 = '_';

const IGNORE = '=';
const ADD = '+';
const REMOVE = '-';

const Operation = struct { action: u8, value: []const u8 };

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

fn print_diff(result: []Operation) void {
    for (0..result.len - 1) |i| {
        if (result[i].action != 'x') {
            std.debug.print("\n{c} {s}", .{ result[i].action, result[i].value });
        } else {
            std.debug.print("\n  {s}", .{result[i].value});
        }
    }
}

fn append_operations(operations: *[]Operation, action: u8, value: []const u8) void {
    //std.debug.print("VINDO: action {c} - value {s}\n", .{ action, value });
    for (0..operations.len) |i| {
        if (operations.*[i].action == NOT_VALUE_ACTION) {
            //std.debug.print("action {c} - value {s}\n", .{ action, value });
            operations.*[i] = Operation{ .value = value, .action = action };
            break;
        }
    }
}

fn reverse(arr: *[]Operation) void {
    var start: usize = 0;
    var end: usize = arr.len - 1;

    while (start < end) {
        const temp = arr.*[start];
        arr.*[start] = arr.*[end];
        arr.*[end] = temp;

        start += 1;
        end -= 1;
    }
}

// TODO: TAKEN FROM DEEPSEEK
// for some reasos its returnin a  +1 bigger slice
fn split(allocator: std.mem.Allocator, input: []const u8, delimiter: u8) ![][]const u8 {
    var result = std.ArrayList([]const u8).init(allocator);
    defer result.deinit();

    var start: usize = 0;
    while (true) {
        // Find the next occurrence of the delimiter
        const end = std.mem.indexOfScalarPos(u8, input, start, delimiter) orelse input.len;

        // Add the substring to the result
        try result.append(input[start..end]);

        // Move the start position past the delimiter
        start = end + 1;

        // Stop if we've reached the end of the string
        if (end == input.len) break;
    }

    _ = result.pop();
    return result.toOwnedSlice();
}

fn lev(a: [][]const u8, b: [][]const u8, distances_cache_ptr: *[][]usize, actions_ptr: *[][]u8, out: *[]Operation) void {
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
            if (std.mem.eql(u8, a[n1 - 1], b[n2 - 1])) {
                cache[n1][n2] = cache[n1 - 1][n2 - 1];
                actions[n1][n2] = IGNORE;
                continue;
            }

            const rem = cache[n1 - 1][n2];
            const add = cache[n1][n2 - 1];

            cache[n1][n2] = rem;
            actions[n1][n2] = REMOVE;

            if (cache[n1][n2] > add) {
                cache[n1][n2] = add;
                actions[n1][n2] = ADD;
            }

            cache[n1][n2] += 1;
        }
    }

    n1 = a.len;
    n2 = b.len;
    var count: usize = 0;

    while (n1 > 0 or n2 > 0) {
        const action = actions[n1][n2];
        if (action == ADD) {
            n2 -= 1;
            append_operations(out, action, b[n2]);
        } else if (action == REMOVE) {
            n1 -= 1;
            append_operations(out, action, a[n1]);
        } else if (action == IGNORE) {
            n1 -= 1;
            n2 -= 1;
            append_operations(out, action, b[n2]);
        } else {
            std.debug.assert(false);
            std.debug.print("ERROR", .{});
        }

        count += 1;
    }

    return;
}

pub fn diff(file_a: []const u8, file_b: []const u8) !void {
    const allocator = std.heap.page_allocator;

    const a = try split(allocator, file_a, '\n');
    const b = try split(allocator, file_b, '\n');

    const a_len = a.len + 1;
    const b_len = b.len + 1;

    var distances = try allocator.alloc([]usize, a_len);
    for (distances) |*row| {
        row.* = try allocator.alloc(usize, b_len);
        for (row.*) |*col| {
            col.* = NOT_VALUE;
        }
    }

    var actions = try allocator.alloc([]u8, a_len);
    var out = try allocator.alloc(Operation, b_len);

    for (out) |*i| {
        i.* = Operation{ .action = NOT_VALUE_ACTION, .value = "" };
    }

    for (actions) |*row| {
        row.* = try allocator.alloc(u8, b_len);
        for (row.*) |*col| {
            col.* = NOT_VALUE_ACTION;
        }
    }

    _ = lev(a, b, &distances, &actions, &out);

    reverse(&out);
    print_diff(out);
}
