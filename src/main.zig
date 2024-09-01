const providers = @import("providers.zig");
const std = @import("std");
const terminal = @import("terminal.zig");

fn die(message: []const u8) noreturn {
    std.debug.print("[ERROR] {s}\n", .{message});
    std.process.exit(1);
}

fn demo(allocator: std.mem.Allocator) !void {
    try runWithData(allocator, &providers.example);
}

fn fromStdIn(allocator: std.mem.Allocator) !void {
    try runWithData(allocator, &providers.stdIn);
}

fn runWithData(allocator: std.mem.Allocator, data_retriever: *const fn (std.mem.Allocator) anyerror!std.json.Parsed(std.json.Value)) !void {
    var parsed = try data_retriever(allocator);
    defer parsed.deinit();

    try terminal.run(allocator, @ptrCast(&parsed.value.object));
}

fn usage(_: std.mem.Allocator) !void {
    std.debug.print("data-tree-explorer v0.0.0\n", .{});
    std.debug.print("Usage: data-tree-explorer --|-h|--help|--demo\n\n", .{});
    std.debug.print("--: Use STDIN as the input data source\n", .{});
    std.debug.print("-h, --help: Print help information about this program\n", .{});
    std.debug.print("--demo: Run the application with a set of test JSON data as a demo\n", .{});
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
        } else if (std.mem.eql(u8, arg, "--demo")) {
            action = &demo;
        } else if (std.mem.eql(u8, arg, "--")) {
            action = &fromStdIn;
        }
    }

    // Output help data if inputs are inappropriate
    if (argCount != 1) {
        action = &usage;
    }

    action(allocator) catch |err| {
        std.debug.print("\n\n", .{});

        switch (err) {
            error.StreamTooLong => {
                die("Retrieved JSON Data Larger than 1MB Limit");
            },
            error.SyntaxError => {
                die("Data Not Valid JSON");
            },
            error.UnexpectedEndOfInput => {
                die("Provided Data Incomplete, Unable to Parse");
            },
            else => {
                return err;
            },
        }
    };
}
