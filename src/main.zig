const providers = @import("providers.zig");
const std = @import("std");
const terminal = @import("terminal.zig");

fn applicationError(err: anyerror) !void {
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
}

fn die(message: []const u8) noreturn {
    std.debug.print("[ERROR] {s}\n", .{message});
    std.process.exit(1);
}

fn demo(args: providers.ProviderArgs) !void {
    try runWithData(args, &providers.example);
}

fn fromFile(args: providers.ProviderArgs) !void {
    try runWithData(args, &providers.file);
}

fn parseArgs(allocator: std.mem.Allocator, source_file: *std.fs.File) !*const fn (providers.ProviderArgs) anyerror!void {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    // Skip the executable for argument parsing
    _ = args.next();

    var action: *const fn (providers.ProviderArgs) anyerror!void = &usage;
    var arg_count: u8 = 0;
    var parse_as_file = false;
    var required_args: u8 = 1;

    while (args.next()) |arg| {
        arg_count += 1;

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            action = &usage;
        } else if (std.mem.eql(u8, arg, "--demo")) {
            action = &demo;
        } else if (std.mem.eql(u8, arg, "--")) {
            action = &fromFile;
        } else if (std.mem.eql(u8, arg, "-f") or std.mem.eql(u8, arg, "--file")) {
            action = &fromFile;
            required_args += 1;
            parse_as_file = true;
        } else if (parse_as_file) {
            source_file.* = try std.fs.openFileAbsolute(arg, .{ .mode = .read_only });
            parse_as_file = false;
        }
    }

    // Output help data if inputs are inappropriate
    if (arg_count != required_args) {
        action = &usage;
    }

    return action;
}

fn runWithData(args: providers.ProviderArgs, provider: *const fn (providers.ProviderArgs) anyerror!std.json.Parsed(std.json.Value)) !void {
    var parsed = try provider(args);
    defer parsed.deinit();
    defer args.source.close();

    try terminal.run(args.allocator, @ptrCast(&parsed.value.object));
}

fn usage(_: providers.ProviderArgs) !void {
    std.debug.print("data-tree-explorer v0.0.0\n", .{});
    std.debug.print("Usage: data-tree-explorer --|-f <FILE>|--file <FILE>|-h|--help|--demo\n\n", .{});
    std.debug.print("--: Use STDIN as the input data source\n", .{});
    std.debug.print("-f, --file: Use FILE as the input data source\n", .{});
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

    var provider_args = .{ .allocator = allocator, .source = std.io.getStdIn() };
    const action = parseArgs(allocator, &provider_args.source) catch {
        die("Unable to parse application arguments");
    };

    action(provider_args) catch |err| {
        try applicationError(err);
    };
}
