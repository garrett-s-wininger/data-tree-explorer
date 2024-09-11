const movement = @import("terminal/movement.zig");
const output = @import("terminal/output.zig");
const state = @import("terminal/state.zig");
const std = @import("std");
const terminal = @import("terminal/ncurses.zig");

// Global application state
var application_state = state.ApplicationState{ .should_quit = false };

fn outputColorForData(data: *std.ArrayHashMapUnmanaged([]const u8, std.json.Value, std.array_hash_map.StringContext, true), key: []const u8) u8 {
    switch (data.*.get(key).?) {
        .null => {
            return output.NULL_COLORS;
        },
        .array, .object => {
            return output.COLLECTION_COLORS;
        },
        else => {
            return output.DEFAULT_COLORS;
        },
    }
}

fn setupKeybinds(actions: *std.StringHashMap(*const fn () void)) !void {
    try actions.put("q", &quit);
    try actions.put("k", &movement.previousLine);
    try actions.put("^P", &movement.previousLine);
    try actions.put("j", &movement.nextLine);
    try actions.put("^N", &movement.nextLine);
    try actions.put("g", &movement.firstLine);
    try actions.put("$", &movement.lastLine);
}

fn quit() void {
    application_state.should_quit = true;
}

pub fn run(allocator: std.mem.Allocator, data: *std.ArrayHashMapUnmanaged([]const u8, std.json.Value, std.array_hash_map.StringContext, true)) !void {
    // Prepare the terminal
    terminal.init();
    defer terminal.deinit();

    try output.printHeader(allocator);

    // Output top-level data into terminal window
    for (data.*.keys(), 0..) |key, idx| {
        try output.print(allocator, key, outputColorForData(data, key));

        if (idx < data.*.keys().len - 1) {
            try output.printDefault(allocator, "\n");
        } else {
            movement.lastLine();
        }
    }

    // Keybind configuration
    var actions = std.StringHashMap(*const fn () void).init(allocator);
    defer actions.deinit();

    try setupKeybinds(&actions);
    movement.firstLine();

    // Main application loop
    while (!application_state.should_quit) {
        const input = try terminal.getInput(allocator);
        defer allocator.free(input);

        if (actions.get(input)) |action| {
            action();
        }
    }
}
