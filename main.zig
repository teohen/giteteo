const std = @import("std");
const Sha2 = std.crypto.hash.sha2.Sha256;
const file = @import("file.zig");

fn calls(file_data: []u8) [64]u8 {
    var out: [32]u8 = undefined;

    Sha2.hash(file_data, &out, .{});

    const t = std.fmt.bytesToHex(out, .lower);

    return t;
}

fn readFromStdIn() void {
    const stdin = std.io.getStdIn();

    var buffer: [1024]u8 = undefined;

    std.debug.print("Enter a line of text: ", .{});

    const line = (try stdin.reader().readUntilDelimiterOrEof(&buffer, '\n')) orelse {
        std.debug.print("no input received. \n", .{});
        return;
    };

    std.debug.print("You entered: {s}", .{line});
}

fn save(filename: []u8) !void {
    const allocator = std.heap.page_allocator;

    const file_data = try file.read(filename);
    defer allocator.free(file_data);

    const hash = calls(file_data);

    try file.write(hash, file_data);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    for (args, 0..) |arg, i| {
        if (std.mem.eql(u8, arg, "-s")) {
            const filename = args[i + 1];
            try save(filename);
        }
        std.debug.print("Argument {}: {s}\n", .{ i, arg });
    }
}
