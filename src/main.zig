const std = @import("std");
const terminal = @cImport({
    @cInclude("terminal.h");
});

const ApplicationState = struct { should_quit: bool };

fn loadTestData(allocator: std.mem.Allocator) !std.json.ArrayHashMap(std.json.Value) {
    const json_data =
        \\{
        \\"stringKey": "value",
        \\"numberKey": 1,
        \\"nullKey": null,
        \\"objectKey": {},
        \\"arrayKey": [],
        \\"boolKey": true
        \\}
    ;
    var buffer = std.io.FixedBufferStream([]const u8){ .buffer = json_data, .pos = 0 };

    // JSON Parsing
    const options = std.json.ParseOptions{ .allocate = std.json.AllocWhen.alloc_if_needed, .max_value_len = std.json.default_max_value_len };
    var reader = std.json.reader(allocator, buffer.reader());

    return try std.json.ArrayHashMap(std.json.Value)
        .jsonParse(allocator, &reader, options);
}

fn moveLineUp(_: *ApplicationState) void {
    terminal.moveLineUp();
}

fn quit(state: *ApplicationState) void {
    state.*.should_quit = true;
}

pub fn main() !void {
    // Prepare memory allocation
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Generic application setup
    var application_state = ApplicationState{ .should_quit = false };

    // Load Data
    var parsed = try loadTestData(allocator);
    defer parsed.deinit(allocator);

    // Prepare the terminal
    terminal.init();
    defer terminal.deinit();

    // Output top-level data into terminal window
    for (parsed.map.keys()) |key| {
        const zero_termed_key: [:0]const u8 = try allocator.dupeZ(u8, key);
        defer allocator.free(zero_termed_key);
        var colors: u8 = undefined;

        switch (parsed.map.get(key).?) {
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
