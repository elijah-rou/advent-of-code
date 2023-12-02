const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;

fn is_digit(char: u8) bool {
    return char >= '0' and char <= '9';
}

const Result = struct {
    const Self = @This();
    const RED_MAX = 12;
    const GREEN_MAX = 13;
    const BLUE_MAX = 14;

    red: i32 = 0,
    green: i32 = 0,
    blue: i32 = 0,

    fn remax(self: *Self, new_colours: Result) void {
        self.red = @max(new_colours.red, self.red);
        self.green = @max(new_colours.green, self.green);
        self.blue = @max(new_colours.blue, self.blue);
    }

    fn power(self: *Self) i32 {
        return self.red * self.green * self.blue;
    }

    fn is_invalid(self: *Self) bool {
        if (self.red > RED_MAX) {
            return true;
        } else if (self.green > GREEN_MAX) {
            return true;
        } else if (self.blue > BLUE_MAX) {
            return true;
        }
        return false;
    }
};

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
        const game_id = details.next().?[5..];
        const gameplay = details.next().?;

        var bag_draws = std.mem.splitScalar(u8, gameplay, ';');
        var result = Result{};
        var invalid_game = false;
        while (bag_draws.next()) |set| {
            var sets = std.mem.splitScalar(u8, set, ',');
            var draw_result = Result{};
            while (sets.next()) |cubes| {
                var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
                defer _ = arena.deinit();
                const allocator = arena.allocator();
                var amount = ArrayList(u8).init(allocator);
                for (cubes) |char| {
                    if (is_digit(char)) {
                        try amount.append(char);
                    } else if (char == 'r') {
                        draw_result.red = try std.fmt.parseInt(i32, amount.items, 10);
                        break;
                    } else if (char == 'g') {
                        draw_result.green = try std.fmt.parseInt(i32, amount.items, 10);
                        break;
                    } else if (char == 'b') {
                        draw_result.blue = try std.fmt.parseInt(i32, amount.items, 10);
                        break;
                    }
                }
                if (draw_result.is_invalid()) {
                    invalid_game = true;
                }
            }
            result.remax(draw_result);
        }
        if (!invalid_game) {
            // std.log.debug("Take: {s}", .{game_id});
            game_id_sum += try std.fmt.parseInt(i32, game_id, 10);
        }
        // std.log.debug("{d}, {d}, {d}", .{ red_max, green_max, blue_max });
        game_power_sum += result.power();
    }
    std.log.info("Id Sum: {d}", .{game_id_sum});
    std.log.info("Power Sum: {d}", .{game_power_sum});
}
