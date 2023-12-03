const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;
const HashMap = std.StringHashMap;

const EnginePart = enum { gear, part, none };

fn check_part(part: u8) EnginePart {
    if (part == 42) {
        return .gear;
    } else if (util.is_digit(part) or part == 46) {
        return .none;
    }
    return .part;
}

fn check_surrounds(engine: [][]u8, y_max: usize, y: usize, x_max: usize, x: usize) struct { part: EnginePart, x: usize, y: usize } {
    var part: EnginePart = .none;
    if (y > 0 and x > 0) {
        part = check_part(engine[y - 1][x - 1]);
        if (part == .gear) {
            return .{ .part = part, .x = x - 1, .y = y - 1 };
        }
    }
    if (y > 0) {
        part = check_part(engine[y - 1][x]);
        if (part == .gear) {
            return .{ .part = part, .x = x, .y = y - 1 };
        }
    }
    if (y > 0 and x < x_max) {
        part = check_part(engine[y - 1][x + 1]);
        if (part == .gear) {
            return .{ .part = part, .x = x + 1, .y = y - 1 };
        }
    }
    if (x > 0) {
        part = check_part(engine[y][x - 1]);
        if (part == .gear) {
            return .{ .part = part, .x = x - 1, .y = y };
        }
    }
    if (x < x_max) {
        part = check_part(engine[y][x + 1]);
        if (part == .gear) {
            return .{ .part = part, .x = x + 1, .y = y };
        }
    }
    if (y < y_max and x > 0) {
        part = check_part(engine[y + 1][x - 1]);
        if (part == .gear) {
            return .{ .part = part, .x = x - 1, .y = y + 1 };
        }
    }
    if (y < y_max) {
        part = check_part(engine[y + 1][x]);
        if (part == .gear) {
            return .{ .part = part, .x = x, .y = y + 1 };
        }
    }
    if (y < y_max and x < x_max) {
        part = check_part(engine[y + 1][x + 1]);
        if (part == .gear) {
            return .{ .part = part, .x = x + 1, .y = y + 1 };
        }
    }
    return .{ .part = part, .x = 0, .y = 0 };
}

fn update_accumulators(ma: std.mem.Allocator, part_type: *EnginePart, part_accumulator: *u32, gear_accumulator: *u32, current_part: *ArrayList(u8), gear_loc: []const u8, gears: *HashMap(*ArrayList(u32))) !void {
    if (part_type.* != .none) {
        const part_value = try std.fmt.parseUnsigned(u32, current_part.items, 10);
        part_accumulator.* += part_value;
        if (part_type.* == .gear) {
            var gear_ptr: ?*ArrayList(u32) = gears.get(gear_loc);
            std.log.info("LOC {s}", .{gear_loc});
            if (gear_ptr == null) {
                var new_gear_list = try ArrayList(u32).initCapacity(ma, 2);
                try new_gear_list.append(part_value);
                try gears.put(gear_loc, &new_gear_list);
            } else {
                std.log.info("PART {any}", .{part_value});
                std.log.info("VAL {any}", .{gear_ptr.?});
                try gear_ptr.?.append(part_value);
                if (gear_ptr.?.*.items.len == 2) {
                    var items = gear_ptr.?.items;
                    gear_accumulator.* += (items[0] * items[1]);
                }
                std.log.info("Addr {*}", .{gear_ptr.?});
                std.log.info("Items {any}", .{gear_ptr.?.items});
            }
        }
        part_type.* = .none;
    }
    current_part.clearAndFree();
}

pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var grid = ArrayList([]u8).init(ma);
    var lines = try util.read_delim(&ma, "resources/day_3/input", "\n");
    while (lines.next()) |line| {
        var components = ArrayList(u8).init(ma);
        for (line) |char| {
            try components.append(char);
        }
        try grid.append(try components.toOwnedSlice());
    }
    const engine = try grid.toOwnedSlice();
    const y_dim = engine.len;
    const x_dim = engine[0].len;
    std.log.info("{any}", .{engine});
    std.log.info(" Grid y: {d}", .{y_dim});
    std.log.info("Grid x: {d}", .{x_dim});

    var part_accumulator: u32 = 0;
    var gear_accumulator: u32 = 0;
    var part_type: EnginePart = .none;
    var current_part = ArrayList(u8).init(ma);
    var gears = HashMap(*ArrayList(u32)).init(ma);
    var gear_loc: []const u8 = undefined;
    for (engine, 0..) |col, y| {
        for (col, 0..) |char, x| {
            if (util.is_digit(char)) {
                try current_part.append(char);
                if (part_type == .none) {
                    const part_details = check_surrounds(engine, y_dim - 1, y, x_dim - 1, x);
                    part_type = part_details.part;
                    if (part_type == .gear) {
                        gear_loc = try std.fmt.allocPrint(ma, "{d}_{d}", .{ part_details.x, part_details.y });
                    }
                }
            } else {
                try update_accumulators(ma, &part_type, &part_accumulator, &gear_accumulator, &current_part, gear_loc, &gears);
            }
        }
        try update_accumulators(ma, &part_type, &part_accumulator, &gear_accumulator, &current_part, gear_loc, &gears);
    }
    std.log.info("Part Sum: {d}", .{part_accumulator});
    std.log.info("Gears: {d}", .{gears.count()});
    std.log.info("Gear Ratio Sum: {d}", .{gear_accumulator});
    var gears_it = gears.valueIterator();
    while (gears_it.next()) |stuff| {
        std.log.debug("{d}", .{stuff.*.items});
    }
}
