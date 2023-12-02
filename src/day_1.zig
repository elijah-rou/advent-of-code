const std = @import("std");
const util = @import("util.zig");

const char_map = std.ComptimeStringMap(u8, .{ .{ "zero", 48 }, .{ "one", 49 }, .{ "two", 50 }, .{ "three", 51 }, .{ "four", 52 }, .{ "five", 53 }, .{ "six", 54 }, .{ "seven", 55 }, .{ "eight", 56 }, .{ "nine", 57 } });
test "Get an element from char map" {
    try std.testing.expect(char_map.get("one").? == 49);
}

fn part_1(digits: *[2]u8, char: u8) void {
    if (char >= 48 and char < 58) {
        if (digits[0] == undefined) {
            digits[0] = char;
            digits[1] = char;
        } else {
            digits[1] = char;
        }
    }
}

fn take_greedy(char: u8, greedy_nums: [3]?u8) u8 {
    if (char >= 48 and char < 58) {
        return char;
    } else {
        for (greedy_nums) |char_num| {
            if (char_num != null) {
                return char_num.?;
            }
        }
    }
    return 0;
}

fn part_2(digits: *[2]u8, idx: usize, line: []const u8, char: u8) void {
    const end_3 = @min(idx + 3, line.len);
    const end_4 = @min(idx + 4, line.len);
    const end_5 = @min(idx + 5, line.len);
    const greedy_3 = char_map.get(line[idx..end_3]);
    const greedy_4 = char_map.get(line[idx..end_4]);
    const greedy_5 = char_map.get(line[idx..end_5]);

    const greedy_num = take_greedy(char, [3]?u8{ greedy_3, greedy_4, greedy_5 });
    if (greedy_num != 0) {
        if (digits[0] == undefined) {
            digits[0] = greedy_num;
            digits[1] = greedy_num;
        } else {
            digits[1] = greedy_num;
        }
    }
}

pub fn main() !void {
    const part = std.os.argv[1][0];
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();

    var lines = try util.read_delim(&allocator, "resources/day_1/input", "\n");
    var digit_sum: i32 = 0;

    while (lines.next()) |line| {
        var digits = [2]u8{ undefined, undefined };
        for (line, 0..) |char, idx| {
            switch (part) {
                49 => { // arg = 1
                    part_1(&digits, char);
                },
                else => {
                    part_2(&digits, idx, line, char);
                },
            }
        }
        if (digits[0] != undefined and digits[1] != undefined) {
            const number = try std.fmt.parseInt(i32, &digits, 10);
            digit_sum += number;
        }
    }

    std.log.info("Digit Sum: {d}", .{digit_sum});
}
