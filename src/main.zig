const parsing = @import("parsing.zig");
const std = @import("std");
const terminal = @import("terminal.zig");

fn usage(_: std.mem.Allocator) !void {
    std.debug.print("data-tree-explorer v0.0.0\n", .{});
    std.debug.print("Usage: data-tree-explorer [-h|--help|--demo]\n\n", .{});
    std.debug.print("-h, --help: Print help information about this program\n", .{});
    std.debug.print("--demo: Run the application with a set of test JSON data as a demo\n", .{});
}

fn demo(allocator: std.mem.Allocator) !void {
    var parsed = try parsing.loadTestData(allocator);
    defer parsed.deinit();

    try terminal.run(allocator, @ptrCast(&parsed.value.object));
}

pub fn main() !void {
    // Prepare memory allocation
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        if (gpa.deinit() == .leak) {
            @panic("Memory leak detected in application.");
        }
    }

    // Parse Options
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    // Skip the executable for argument parsing
    _ = args.next();
    var argCount: u8 = 0;
    var action: *const fn (std.mem.Allocator) anyerror!void = &usage;

    while (args.next()) |arg| {
        argCount += 1;

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help") or argCount > 1) {
            action = &usage;
        } else if (std.mem.eql(u8, arg, "--demo") or std.mem.eql(u8, arg, "--")) {
            action = &demo;
        }
    }

    // We expect one action to take
    if (argCount == 0) {
        action = &usage;
    }

    try action(allocator);
}
