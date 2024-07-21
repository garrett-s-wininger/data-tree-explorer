const std = @import("std");
const terminal = @cImport({
    @cInclude("terminal.h");
});

pub fn main() !void {
    const data = [_][*:0]const u8{ "Line1".ptr, "Line2".ptr, "Line3".ptr };

    terminal.run(&data, data.len);
}
