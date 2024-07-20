const std = @import("std");
const locale = @cImport({
    @cInclude("locale.h");
});
const ncurses = @cImport({
    @cInclude("ncurses.h");
});

pub fn main() !void {
    // Prepare locale for curses library calls
    _ = locale.setlocale(locale.LC_ALL, "");

    // Initialize curses screen
    _ = ncurses.initscr().?;
    _ = ncurses.keypad(ncurses.stdscr, true);
    _ = ncurses.cbreak();
    _ = ncurses.noecho();

    _ = ncurses.printw("Entered application!");
    _ = ncurses.refresh();

    // Application loop
    while (true) {
        const char: c_int = ncurses.getch();

        if (char == 'q') {
            break;
        }
    }

    // Cleanup
    _ = ncurses.endwin();
}
