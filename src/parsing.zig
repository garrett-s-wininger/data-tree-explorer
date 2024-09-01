const std = @import("std");

pub fn loadTestData(allocator: std.mem.Allocator) !std.json.Parsed(std.json.Value) {
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
