const coordinate = @import("coordinate.zig");
const cstr = @cImport({
    @cInclude("string.h");
});
const ncurses = @cImport({
    @cInclude("terminal.h");
});

const std = @import("std");

const Coordinate = coordinate.Coordinate;

pub fn init() void {
    ncurses.init();
}

pub fn deinit() void {
    _ = ncurses.endwin();
}

pub fn getInput(allocator: std.mem.Allocator) ![]const u8 {
    const data: [*c]const u8 = ncurses.getInput();
    const length = cstr.strlen(data);

    return try allocator.dupe(u8, data[0..length]);
}
