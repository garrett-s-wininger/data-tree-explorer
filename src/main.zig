const std = @import("std");
const parsing = @import("parsing.zig");
const terminal = @import("terminal.zig");

pub fn main() !void {
    // Prepare memory allocation
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // Load Data
    var parsed = try parsing.loadTestData(allocator);
    defer parsed.deinit(allocator);

    try terminal.run(allocator, &parsed);
}
