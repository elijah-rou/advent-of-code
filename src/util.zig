const std = @import("std");

pub fn read_delim(allocator: *const std.mem.Allocator, filename: []const u8, delimiter: []const u8) !std.mem.SplitIterator(u8, .sequence) {
    // Read File
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath(filename, &path_buffer);
    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    const file_stats = try file.stat();
    const file_size = file_stats.size;
    const buffer = try file.readToEndAlloc(allocator.*, file_size);
    errdefer allocator.free(buffer);

    // Return iterator
    return std.mem.splitSequence(u8, buffer, delimiter);
}

fn is_digit(char: u8) bool {
    return char >= '0' and char <= '9';
}
