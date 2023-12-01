const std = @import("std");
const util = @import("util.zig");

const char_map = std.ComptimeStringMap(u8, .{ .{ "one", "1" }, .{ "two", "2" }, .{ "three", "3" }, .{ "four", "4" }, .{ "five", "5" }, .{ "six", "6" }, .{ "seven", "7" }, .{ "eight", "8" }, .{ "nine", "9" } });

fn shiftLeft(comptime T: [type]u8, arr: T) T {
    var i: usize = 0;
    while (i < arr.len - 1) : (i += 1) {
        arr[i] = arr[i + 1];
    }
    return arr;
}

fn advance_buffer(comptime T: [type]u8, buffer: T, char: u8) !T {
    const buffer_len = buffer.len;
    for (std.meta.enumerate(buffer)) |e| {
        if (e.value == undefined) {
            buffer[e.index] = char;
            break;
        } else if (e.index == buffer_len - 1) {
            buffer = shiftLeft(T, buffer);
            buffer[e.index] = char;
        }
    }
}

pub fn main() !void {
    // Setup Arena Alloc
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const allocator = arena.child_allocator;

    var lines = try util.read_delim(&allocator, "resources/day_1/input", "\n");
    var digit_sum: i32 = 0;

    var greedy_buffer_3 = [3]u8{ 0, 0, 0 };
    var greedy_buffer_4 = [4]u8{ 0, 0, 0, 0 };
    var greedy_buffer_5 = [5]u8{ 0, 0, 0, 0, 0 };

    while (lines.next()) |line| {
        var digits = [2]u8{ undefined, undefined };
        for (line) |char| {
            greedy_buffer[buffer_idx] = char;
            const greedy_val = char_map.get(greedy_buffer);
            if (greedy_val != null) {
                std.log.info("Buffer: {s}", .{greedy_buffer});
            }
            buffer_idx += 1;

            if (digits[0] == undefined and char >= 48 and char < 58) {
                digits[0] = char;
            } else if (digits[0] != undefined and char >= 48 and char < 58) {
                digits[1] = char;
            }
        }
        if (digits[1] == undefined) {
            digits[1] = digits[0];
        }
        if (digits[0] != undefined and digits[1] != undefined) {
            const number = try std.fmt.parseInt(i32, &digits, 10);
            digit_sum += number;
        }
    }

    std.log.info("Digit Sum: {d}", .{digit_sum});
}
