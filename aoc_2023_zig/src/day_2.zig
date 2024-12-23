const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;

const GameResult = struct {
    const Self = @This();
    const RED_MAX = 12;
    const GREEN_MAX = 13;
    const BLUE_MAX = 14;

    red: i32 = 0,
    green: i32 = 0,
    blue: i32 = 0,

    fn remax(self: *Self, new_colours: GameResult) void {
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
        var game_result = GameResult{};
        var invalid_game = false;
        while (bag_draws.next()) |set| {
            var sets = std.mem.splitScalar(u8, set, ',');
            var draw_result = GameResult{};
            while (sets.next()) |cubes| {
                var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
                defer _ = arena.deinit();
                const allocator = arena.allocator();
                var amount = ArrayList(u8).init(allocator);
                for (cubes) |char| {
                    if (util.is_digit(char)) {
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
            }
            if (draw_result.is_invalid()) {
                invalid_game = true;
            }
            game_result.remax(draw_result);
        }
        if (!invalid_game) {
            game_id_sum += try std.fmt.parseInt(i32, game_id, 10);
        }
        game_power_sum += game_result.power();
    }
    std.log.info("Id Sum: {d}", .{game_id_sum});
    std.log.info("Power Sum: {d}", .{game_power_sum});
}
