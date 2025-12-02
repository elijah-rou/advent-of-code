const std = @import("std");

pub fn read_delim(allocator: std.mem.Allocator, filename: []const u8, delimiter: []const u8) !std.mem.SplitIterator(u8, .sequence) {
    // Read File
    var path_buffer: [std.fs.max_path_bytes]u8 = undefined;
    const path = try std.fs.realpath(filename, &path_buffer);
    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    const file_stats = try file.stat();
    const file_size = file_stats.size;
    const buffer = try file.readToEndAlloc(allocator, file_size);
    errdefer allocator.free(buffer);

    // Return iterator
    return std.mem.splitSequence(u8, buffer, delimiter);
}

pub fn is_digit(char: u8) bool {
    return char >= '0' and char <= '9';
}

pub fn parse_args(allocator: std.mem.Allocator, day: i32) !struct { []const u8, i32 } {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.next(); // ignore program name

    // test file
    const test_file = args.next() orelse "example";
    const test_path = try std.fmt.allocPrint(allocator, "resources/day_{d}/{s}", .{ day, test_file });

    // part
    const part = if (args.next()) |arg|
        try std.fmt.parseInt(i32, arg, 10)
    else
        1;

    // only 2 args
    if (args.next() != null) {
        return error.TooManyArgs;
    }

    return .{ test_path, part };
}
