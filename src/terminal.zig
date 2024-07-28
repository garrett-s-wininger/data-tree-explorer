const std = @import("std");
const terminal = @cImport({
    @cInclude("terminal.h");
});

fn moveLineUp(_: *ApplicationState) void {
    terminal.moveLineUp();
}

fn quit(state: *ApplicationState) void {
    state.*.should_quit = true;
}

const ApplicationState = struct { should_quit: bool };

pub fn run(allocator: std.mem.Allocator, parsed: *std.json.ArrayHashMap(std.json.Value)) !void {
    // Generic application setup
    var application_state = ApplicationState{ .should_quit = false };

    // Prepare the terminal
    terminal.init();
    defer terminal.deinit();

    // Output top-level data into terminal window
    for (parsed.*.map.keys()) |key| {
        const zero_termed_key: [:0]const u8 = try allocator.dupeZ(u8, key);
        defer allocator.free(zero_termed_key);
        var colors: u8 = undefined;

        switch (parsed.*.map.get(key).?) {
            .null => {
                colors = terminal.NULL_COLORS;
            },
            .array, .object => {
                colors = terminal.COLLECTION_COLORS;
            },
            else => {
                colors = terminal.DEFAULT_COLORS;
            },
        }

        terminal.print(zero_termed_key, colors);
        terminal.printUncolored("\n");
    }

    // Keybind configuration
    var actions = std.StringHashMap(*const fn (*ApplicationState) void).init(allocator);
    defer actions.deinit();

    try actions.put("q", &quit);
    try actions.put("k", &moveLineUp);

    // Main application loop
    while (!application_state.should_quit) {
        const input: [*:0]const u8 = terminal.getInput();

        if (actions.get(std.mem.span(input))) |action| {
            action(&application_state);
        }
    }
}
