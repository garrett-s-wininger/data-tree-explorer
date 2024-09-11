const ncurses = @cImport({
    @cInclude("terminal.h");
});

const movement = @import("movement.zig");
const std = @import("std");

pub const COLLECTION_COLORS = ncurses.COLLECTION_COLORS;
pub const DEFAULT_COLORS = ncurses.DEFAULT_COLORS;
pub const NULL_COLORS = ncurses.NULL_COLORS;

pub fn print(allocator: std.mem.Allocator, data: []const u8, color: ncurses.OutputColorPair) !void {
    const zero_termed_key: [:0]const u8 = try allocator.dupeZ(u8, data);
    defer allocator.free(zero_termed_key);

    ncurses.print(zero_termed_key, color);
}

pub fn printDefault(allocator: std.mem.Allocator, data: []const u8) !void {
    try print(allocator, data, ncurses.DEFAULT_COLORS);
}

pub fn printHeader(allocator: std.mem.Allocator) !void {
    const max_x: usize = @intCast(ncurses.getMaxPosition().x);
    const header = "Data Tree Explorer\n";
    const padding = (max_x - header.len) / 2;

    movement.moveTo(movement.currentPosition().line, @intCast(padding));
    try printDefault(allocator, header);
}
