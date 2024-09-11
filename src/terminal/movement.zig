const coordinate = @import("coordinate.zig");
const ncurses = @cImport({
    @cInclude("terminal.h");
});

const std = @import("std");

const Coordinate = coordinate.Coordinate;

pub fn currentPosition() Coordinate {
    const pos = ncurses.getCursorPosition();
    return .{ .line = @intCast(pos.y), .column = @intCast(pos.x) };
}

pub fn firstLine() void {
    moveTo(0, 0);
}

pub fn lastLine() void {
    moveTo(max().line, 0);
}

pub fn max() Coordinate {
    const coord = ncurses.getMaxPosition();

    return .{ .line = @intCast(coord.y - 1), .column = @intCast(coord.x - 1) };
}

pub fn moveTo(line: usize, column: usize) void {
    var destinationLine = line;
    var destinationColumn = column;

    if (line > max().line) {
        destinationLine = max().line;
    }

    if (column > max().column) {
        destinationColumn = max().column;
    }

    _ = ncurses.move(@intCast(line), @intCast(column));
}

pub fn nextLine() void {
    moveTo(@intCast(ncurses.getCursorPosition().y + 1), 0);
}

pub fn previousLine() void {
    if (ncurses.getCursorPosition().y == 0) {
        return;
    }

    moveTo(@intCast(ncurses.getCursorPosition().y - 1), 0);
}
