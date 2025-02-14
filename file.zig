const std = @import("std");

pub fn write(filename: [64]u8, data: []u8) !void {
    const allocator = std.heap.page_allocator;

    const full_name: []u8 = try std.mem.concat(allocator, u8, &.{ filename[0..], ".gtt" });

    const file = try std.fs.cwd().createFile(full_name, .{});

    defer allocator.free(full_name);
    defer file.close();

    file.writeAll(data) catch |err| {
        std.debug.print("ERRO: {}", .{err});
    };
}

pub fn read(filename: []u8) ![]u8 {
    const allocator = std.heap.page_allocator;
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const file_size = (try file.stat()).size;

    const buffer = try allocator.alloc(u8, file_size);

    _ = try file.readAll(buffer);

    const result: []u8 = buffer;

    return result;
}
