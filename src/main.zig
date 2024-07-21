const std = @import("std");
const terminal = @cImport({
    @cInclude("terminal.h");
});

pub fn main() !void {
    // Example data to parse
    const jsonData =
        \\{
        \\"stringKey": "value"
        \\}
    ;
    var buffer = std.io.FixedBufferStream([]const u8){ .buffer = jsonData, .pos = 0 };

    // Configure our memory allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // JSON Parsing
    const options = std.json.ParseOptions{ .allocate = std.json.AllocWhen.alloc_if_needed, .max_value_len = std.json.default_max_value_len };
    var reader = std.json.reader(allocator, buffer.reader());
    var parsed = try std.json.ArrayHashMap(std.json.Value)
        .jsonParse(allocator, &reader, options);

    defer parsed.deinit(allocator);

    // Interactivity
    const data = [_][*:0]const u8{ "Line1".ptr, "Line2".ptr, "Line3".ptr };
    terminal.run(&data, data.len);
}
