const movement = @import("terminal/movement.zig");
const output = @import("terminal/output.zig");
const state = @import("terminal/state.zig");
const std = @import("std");
const terminal = @cImport({
    @cInclude("terminal.h");
});

fn setupKeybinds(actions: *std.StringHashMap(*const fn (*state.ApplicationState) void)) !void {
    try actions.put("q", &state.quit);
    try actions.put("k", &movement.lineUp);
    try actions.put("^P", &movement.lineUp);
    try actions.put("j", &movement.lineDown);
    try actions.put("^N", &movement.lineDown);
    try actions.put("g", &movement.lineFirst);
    try actions.put("$", &movement.lineLast);
}

pub fn run(allocator: std.mem.Allocator, data: *std.ArrayHashMapUnmanaged([]const u8, std.json.Value, std.array_hash_map.StringContext, true)) !void {
    // Generic application setup
    var application_state = state.ApplicationState{ .should_quit = false, .data_lines = data.*.keys().len };

    // Prepare the terminal
    terminal.init();
    defer _ = terminal.endwin();

    output.printHeader();

    // Output top-level data into terminal window
    for (data.*.keys(), 0..) |key, idx| {
        const zero_termed_key: [:0]const u8 = try allocator.dupeZ(u8, key);
        defer allocator.free(zero_termed_key);

        output.print(zero_termed_key, output.outputColorForData(data, key));

        if (idx < data.*.keys().len - 1) {
            output.printDefault("\n");
        } else {
            movement.lineLast(&application_state);
        }
    }

    // Keybind configuration
    var actions = std.StringHashMap(*const fn (*state.ApplicationState) void).init(allocator);
    defer actions.deinit();

    try setupKeybinds(&actions);
    movement.lineFirst(&application_state);

    // Main application loop
    while (!application_state.should_quit) {
        const input: [*:0]const u8 = terminal.getInput();

        if (actions.get(std.mem.span(input))) |action| {
            action(&application_state);
        }
    }
}
