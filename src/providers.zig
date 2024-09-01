const std = @import("std");

const allocation_limit = 1_000_000;

pub fn stdIn(allocator: std.mem.Allocator) !std.json.Parsed(std.json.Value) {
    const in = std.io.getStdIn();
    var reader = in.reader();

    const data = try reader.readAllAlloc(allocator, allocation_limit);
    defer allocator.free(data);

    const in_stat = try in.stat();

    if (in_stat.kind == .named_pipe) {
        in.close();
        const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .read_write });
        _ = std.os.linux.dup(tty.handle);
    }

    return std.json.parseFromSlice(std.json.Value, allocator, data, .{});
}

pub fn example(allocator: std.mem.Allocator) !std.json.Parsed(std.json.Value) {
    const json_data =
        \\{
        \\"stringKey": "value",
        \\"numberKey": 1,
        \\"nullKey": null,
        \\"objectKey": {},
        \\"arrayKey": [],
        \\"boolKey": true
        \\}
    ;

    return std.json.parseFromSlice(std.json.Value, allocator, json_data, .{});
}
