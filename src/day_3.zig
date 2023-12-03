const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;

const EnginePart = enum { gear, part, none };

fn check_part(part: u8) EnginePart {
    if (part == 42) {
        return .gear;
    } else if (util.is_digit(part) or part == 46) {
        return .none;
    } else {
        return .part;
    }
}

fn check_surrounds(engine: [][]const u8, y_max: usize, y: usize, x_max: usize, x: usize) struct { part: EnginePart, x: usize, y: usize } {
    var part: EnginePart = .none;
    if (y > 0 and x > 0) {
        part = check_part(engine[y - 1][x - 1]);
        if (part != .none) {
            return .{ .part = part, .x = x - 1, .y = y - 1 };
        }
    }
    if (y > 0) {
        part = check_part(engine[y - 1][x]);
        if (part != .none) {
            return .{ .part = part, .x = x, .y = y - 1 };
        }
    }
    if (y > 0 and x < x_max) {
        part = check_part(engine[y - 1][x + 1]);
        if (part != .none) {
            return .{ .part = part, .x = x + 1, .y = y - 1 };
        }
    }
    if (x > 0) {
        part = check_part(engine[y][x - 1]);
        if (part != .none) {
            return .{ .part = part, .x = x - 1, .y = y };
        }
    }
    if (x < x_max) {
        part = check_part(engine[y][x + 1]);
        if (part != .none) {
            return .{ .part = part, .x = x + 1, .y = y };
        }
    }
    if (y < y_max and x > 0) {
        part = check_part(engine[y + 1][x - 1]);
        if (part != .none) {
            return .{ .part = part, .x = x - 1, .y = y + 1 };
        }
    }
    if (y < y_max) {
        part = check_part(engine[y + 1][x]);
        if (part != .none) {
            return .{ .part = part, .x = x, .y = y + 1 };
        }
    }
    if (y < y_max and x < x_max) {
        part = check_part(engine[y + 1][x + 1]);
        if (part != .none) {
            return .{ .part = part, .x = x + 1, .y = y + 1 };
        }
    }
    return .{ .part = part, .x = 0, .y = 0 };
}

fn update_accumulators(current_part: *EnginePart, part_accumulator: *u32, gear_accumulator: *u32, current_value: *ArrayList(u8), current_gear: [2]usize, gears: *HashMap([2]usize, u32)) !void {
    if (current_part.* != .none) {
        const part_value = try std.fmt.parseInt(u32, current_value.items, 10);
        part_accumulator.* += part_value;
        if (current_part.* == .gear) {
            var gear_value = gears.get(current_gear);
            if (gear_value == null) {
                try gears.put(current_gear, part_value);
            } else {
                gear_accumulator.* += (gear_value.? * part_value);
            }
        }
    }
    current_part.* = .none;
    current_value.clearAndFree();
}

pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var grid = ArrayList([]const u8).init(ma);
    var lines = try util.read_delim(&ma, "resources/day_3/input", "\n");
    while (lines.next()) |line| {
        try grid.append(line);
    }
    const engine = try grid.toOwnedSlice();
    const y_dim = engine.len;
    const x_dim = engine[0].len;
    std.log.info("Grid y size: {d}", .{y_dim});
    std.log.info("Grid x size: {d}", .{x_dim});

    var part_accumulator: u32 = 0;
    var current_part: EnginePart = .none;
    var current_value = ArrayList(u8).init(ma);
    var gear_accumulator: u32 = 0;
    var gears = HashMap([2]usize, u32).init(ma);
    var current_gear: [2]usize = .{ undefined, undefined };
    for (engine, 0..) |col, y| {
        for (col, 0..) |char, x| {
            if (util.is_digit(char)) {
                try current_value.append(char);
                if (current_part == .none) {
                    const part_details = check_surrounds(engine, y_dim - 1, y, x_dim - 1, x);
                    current_part = part_details.part;
                    if (current_part == .gear) {
                        current_gear = .{ part_details.x, part_details.y };
                    }
                }
            } else {
                try update_accumulators(&current_part, &part_accumulator, &gear_accumulator, &current_value, current_gear, &gears);
            }
        }
        try update_accumulators(&current_part, &part_accumulator, &gear_accumulator, &current_value, current_gear, &gears);
    }
    std.log.info("Part Sum: {d}", .{part_accumulator});
    std.log.info("Gears: {d}", .{gears.count()});
    std.log.info("Gear Ratio Sum: {d}", .{gear_accumulator});
}
