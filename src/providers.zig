const std = @import("std");

const allocation_limit = 1_000_000;

pub const ProviderArgs = struct { allocator: std.mem.Allocator, source: std.fs.File };

pub fn example(args: ProviderArgs) !std.json.Parsed(std.json.Value) {
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

    return std.json.parseFromSlice(std.json.Value, args.allocator, json_data, .{});
}

pub fn file(args: ProviderArgs) !std.json.Parsed(std.json.Value) {
    const in = args.source;
    var reader = in.reader();

    const data = try reader.readAllAlloc(args.allocator, allocation_limit);
    defer args.allocator.free(data);

    const in_stat = try in.stat();

    if (in_stat.kind == .named_pipe) {
        in.close();
        const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .read_only });
        _ = std.os.linux.dup(tty.handle);
    }

    return std.json.parseFromSlice(std.json.Value, args.allocator, data, .{});
}
