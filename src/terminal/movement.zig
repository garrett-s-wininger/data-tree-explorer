const state = @import("state.zig");
const terminal = @cImport({
    @cInclude("terminal.h");
});

pub fn lineDown(app_state: *state.ApplicationState) void {
    const coord = terminal.getCursorPosition();

    if (coord.y < app_state.*.data_lines) {
        _ = terminal.move(coord.y + 1, 0);
    }
}

pub fn lineFirst(_: *state.ApplicationState) void {
    _ = terminal.move(1, 0);
}

pub fn lineLast(app_state: *state.ApplicationState) void {
    _ = terminal.move(@intCast(app_state.*.data_lines - 1), 0);
}

pub fn lineUp(_: *state.ApplicationState) void {
    const coord = terminal.getCursorPosition();

    if (coord.y != 1) {
        _ = terminal.move(coord.y - 1, 0);
    }
}
