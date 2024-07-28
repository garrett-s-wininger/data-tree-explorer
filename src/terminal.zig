const std = @import("std");
const terminal = @cImport({
    @cInclude("terminal.h");
});

fn print(data: [*:0]const u8, color: terminal.OutputColorPair) void {
    terminal.print(data, color);
}

fn printDefault(data: [*:0]const u8) void {
    terminal.print(data, terminal.DEFAULT_COLORS);
}

fn lineUp(_: *ApplicationState) void {
    const coord = terminal.getCursorPosition();

    if (coord.y != 0) {
        _ = terminal.move(coord.y - 1, 0);
    }
}

fn quit(state: *ApplicationState) void {
    state.*.should_quit = true;
}

fn setupKeybinds(actions: *std.StringHashMap(*const fn (*ApplicationState) void)) !void {
    try actions.put("q", &quit);
    try actions.put("k", &lineUp);
    try actions.put("^P", &lineUp);
}

fn outputColorForData(comptime T: type, data: *std.ArrayHashMapUnmanaged([]const u8, T, std.array_hash_map.StringContext, true), key: []const u8) u8 {
    switch (T) {
        std.json.Value => {
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
        },
        else => {
            return terminal.DEFAULT_COLORS;
        },
    }
}

const ApplicationState = struct { should_quit: bool };

pub fn run(comptime T: type, allocator: std.mem.Allocator, data: *std.ArrayHashMapUnmanaged([]const u8, T, std.array_hash_map.StringContext, true)) !void {
    // Generic application setup
    var application_state = ApplicationState{ .should_quit = false };

    // Prepare the terminal
    terminal.init();
    defer _ = terminal.endwin();

    // Output top-level data into terminal window
    for (data.*.keys()) |key| {
        const zero_termed_key: [:0]const u8 = try allocator.dupeZ(u8, key);
        defer allocator.free(zero_termed_key);

        print(zero_termed_key, outputColorForData(T, data, key));
        printDefault("\n");
    }

    // Keybind configuration
    var actions = std.StringHashMap(*const fn (*ApplicationState) void).init(allocator);
    defer actions.deinit();

    try setupKeybinds(&actions);

    // Main application loop
    while (!application_state.should_quit) {
        const input: [*:0]const u8 = terminal.getInput();

        if (actions.get(std.mem.span(input))) |action| {
            action(&application_state);
        }
    }
}
