const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;

const RED = 12;
const GREEN = 13;
const BLUE = 14;

fn is_digit(char: u8) bool {
    if (char >= 48 and char < 58) {
        return true;
    }
    return false;
}

fn get_cubes(results: std.StringHashMap(?[]u8), key: []const u8) i32 {
    const amount = results.get(key).?;
    if (amount != null) {
        return std.fmt.parseInt(i32, amount.?, 10) catch |err| switch (err) {
            error.Overflow => {
                std.log.err("Overflow error\n", .{});
                return 0;
            },
            error.InvalidCharacter => {
                std.log.err("Invalid character error\n", .{});
                return 0;
            },
        };
    } else {
        return 0;
    }
}

pub fn main() !void {
    const part = std.os.argv[1][0];
    _ = part;
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var lines = try util.read_delim(&ma, "resources/day_2/input", "\n");
    var game_id_sum: i32 = 0;
    var game_power_sum: i32 = 0;
    while (lines.next()) |game| {
        var details = std.mem.splitScalar(u8, game, ':');
        const id = details.next().?;
        const game_id = if (is_digit(id[id.len - 2])) id[id.len - 2 .. id.len] else id[id.len - 1 .. id.len];

        const draws = details.next().?;
        var hands = std.mem.splitScalar(u8, draws, ';');
        var invalid: bool = false;
        var red_max: i32 = 0;
        var green_max: i32 = 0;
        var blue_max: i32 = 0;

        while (hands.next()) |set| {
            var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
            defer _ = arena.deinit();
            const allocator = arena.allocator();
            var results = std.StringHashMap(?[]u8).init(allocator);
            try results.put("red", null);
            try results.put("green", null);
            try results.put("blue", null);

            var sets = std.mem.splitScalar(u8, set, ',');
            while (sets.next()) |cubes| {
                var amount = ArrayList(u8).init(allocator);
                for (cubes) |char| {
                    if (is_digit(char)) {
                        try amount.append(char);
                    } else if (char == 114) {
                        try results.put("red", amount.items);
                        break;
                    } else if (char == 103) {
                        try results.put("green", amount.items);
                        break;
                    } else if (char == 98) {
                        try results.put("blue", amount.items);
                        break;
                    }
                }
            }
            const red_amount = get_cubes(results, "red");
            const green_amount = get_cubes(results, "green");
            const blue_amount = get_cubes(results, "blue");

            if (red_amount > RED or green_amount > GREEN or blue_amount > BLUE) {
                invalid = true;
            }
            red_max = @max(red_amount, red_max);
            green_max = @max(green_amount, green_max);
            blue_max = @max(blue_amount, blue_max);
        }
        if (!invalid) {
            // std.log.debug("Take: {s}", .{game_id});
            game_id_sum += try std.fmt.parseInt(i32, game_id, 10);
        }
        // std.log.debug("{d}, {d}, {d}", .{ red_max, green_max, blue_max });
        game_power_sum += (red_max * green_max * blue_max);
    }
    std.log.info("Id Sum: {d}", .{game_id_sum});
    std.log.info("Power Sum: {d}", .{game_power_sum});
}
