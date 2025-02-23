const std = @import("std");
const Sha2 = std.crypto.hash.sha2.Sha256;
const file = @import("file.zig");
const diff = @import("diff.zig");

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
    //TODO: Its loading a file and saving the gtt format.
    //TODO: create the diff algorithm
    const allocator = std.heap.page_allocator;

    const file_data = try file.read(filename);
    defer allocator.free(file_data);

    const hash = calls(file_data);

    try file.write(hash, file_data);
}

fn diff_files(path_1: []u8, path_2: []u8) !void {
    const file_1_data = try file.read(path_1);
    const file_2_data = try file.read(path_2);
    //std.debug.print("{s}", .{file_1_data});
    //std.debug.print("{s}", .{file_2_data});
    try diff.diff(file_1_data, file_2_data);
}

pub fn main() !void {
    //const a = "add\nadd";
    //const b = "add\nzaddy";
    //const a = "adddfjksdfkdgjks";
    //const b = "addf9sdfjksdfjkljsdf";

    //try diff.diff(a, b);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const p1 = args[1];
    const p2 = args[2];

    try diff_files(p1, p2);

    //for (args, 0..) |arg, i| {
    //if (std.mem.eql(u8, arg, "-s")) {
    //const filename = args[i + 1];
    //const file_data = try file.read(filename);
    //try diff.diff(file_data, file_b: []const u8)
    //}
    //std.debug.print("Argument {}: {s}\n", .{ i, arg });
    //}
}
