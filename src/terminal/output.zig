const std = @import("std");
const terminal = @cImport({
    @cInclude("terminal.h");
});

pub fn outputColorForData(data: *std.ArrayHashMapUnmanaged([]const u8, std.json.Value, std.array_hash_map.StringContext, true), key: []const u8) u8 {
    switch (data.*.get(key).?) {
        .null => {
            return terminal.NULL_COLORS;
        },
        .array, .object => {
            return terminal.COLLECTION_COLORS;
        },
        else => {
            return terminal.DEFAULT_COLORS;
        },
    }
}

pub fn print(data: [*:0]const u8, color: terminal.OutputColorPair) void {
    terminal.print(data, color);
}

pub fn printDefault(data: [*:0]const u8) void {
    terminal.print(data, terminal.DEFAULT_COLORS);
}

pub fn printHeader() void {
    const max_x: usize = @intCast(terminal.getMaxPosition().x);
    const header = "Data Tree Explorer\n";
    const padding = (max_x - header.len) / 2;

    _ = terminal.move(terminal.getCursorPosition().y, @intCast(padding));
    printDefault(header);
}
