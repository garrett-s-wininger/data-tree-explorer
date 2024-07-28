const std = @import("std");

pub fn loadTestData(allocator: std.mem.Allocator) !std.json.ArrayHashMap(std.json.Value) {
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
    var buffer = std.io.FixedBufferStream([]const u8){ .buffer = json_data, .pos = 0 };

    // JSON Parsing
    const options = std.json.ParseOptions{ .allocate = std.json.AllocWhen.alloc_if_needed, .max_value_len = std.json.default_max_value_len };
    var reader = std.json.reader(allocator, buffer.reader());

    return try std.json.ArrayHashMap(std.json.Value)
        .jsonParse(allocator, &reader, options);
}
