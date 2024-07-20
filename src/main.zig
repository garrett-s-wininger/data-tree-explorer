const std = @import("std");
const ncurses = @cImport({
    @cInclude("ncurses.h");
});

pub fn main() !void {
    _ = ncurses.initscr();
    _ = ncurses.printw("Application Window");
    _ = ncurses.refresh();
    _ = ncurses.getch();
    _ = ncurses.endwin();
}
