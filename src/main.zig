const std = @import("std");
const terminal = @cImport({
    @cInclude("terminal.h");
});

pub fn main() !void {
    terminal.run();
}
