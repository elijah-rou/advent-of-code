const std = @import("std");
const util = @import("util.zig");

const part = 2;

fn parse_combo(combo: []const u8) !struct { i64, i64 } {
    const turn_dir: i64 = switch (combo[0]) {
        82 => 1, // 'R'
        else => -1,
    };
    const turn_amt = try std.fmt.parseInt(i64, combo[1..], 10);
    return .{ turn_amt, turn_dir };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();

    var lines = try util.read_delim(&allocator, "resources/day_1/input", "\n");
    var combo_sum: i64 = 50;
    var click_count: i64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        const parsed_combo = try parse_combo(line);
        const turn_amt = parsed_combo[0];
        const turn_dir = parsed_combo[1];
        const combo_was_positive = combo_sum > 0;
        combo_sum += turn_amt * turn_dir;
        const rolling_combo = combo_sum;
        if (part == 1) {
            combo_sum = @mod(combo_sum, 100);
            if (combo_sum == 0) {
                click_count += 1;
            }
        } else {
            var turn_clicks: i64 = undefined;
            if (turn_dir == 1) {
                turn_clicks = @divTrunc(combo_sum, 100);
            } else if (combo_sum == 0) {
                turn_clicks = 1;
            } else if (combo_was_positive and combo_sum < 0) {
                turn_clicks = -@divTrunc(combo_sum, 100) + 1;
            } else {
                turn_clicks = -@divTrunc(combo_sum, 100);
            }
            click_count += turn_clicks;
            combo_sum = @mod(combo_sum, 100);
        }
        std.log.info("Combo: {s}, Turn {d}, Dir {d}, Rolling {d}, New: {d}, Click Rolling {d}", .{ line, turn_amt, turn_dir, rolling_combo, combo_sum, click_count });
    }
    std.log.info("Click Count: {d}", .{click_count});
}
