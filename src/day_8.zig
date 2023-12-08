const std = @import("std");
const util = @import("util.zig");
const HashMap = std.StringHashMap([2][]const u8);
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var desert_map = HashMap.init(allocator);
    var starting_points = ArrayList([]const u8).init(allocator);
    var lines = try util.read_delim(&allocator, "resources/day_8/input", "\n");
    const instructions = lines.next().?;

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const node = line[0..3];
        const dest_l = line[7..10];
        const dest_r = line[12..15];
        try desert_map.put(node, .{ dest_l, dest_r });
        if (node[2] == 'A') {
            try starting_points.append(node);
        }
    }

    // Part 1
    var current_loc: []const u8 = "AAA";
    var steps: u128 = 0;
    while (!std.mem.eql(u8, current_loc, "ZZZ")) {
        for (instructions) |instr| {
            const options = desert_map.get(current_loc).?;
            current_loc = switch (instr) {
                'L' => options[0],
                else => options[1],
            };
            steps += 1;
            if (std.mem.eql(u8, current_loc, "ZZZ")) {
                break;
            }
        }
    }
    std.log.debug("Num Steps to ZZZ: {d}", .{steps});

    // Part 2 LCM (not generalisable)
    var cycle_lengths = ArrayList(u128).init(allocator);
    for (starting_points.items) |point| {
        steps = 0;
        current_loc = point;
        var last_char: u8 = 'A';
        while (last_char != 'Z') {
            for (instructions) |instr| {
                const options = desert_map.get(current_loc).?;
                current_loc = switch (instr) {
                    'L' => options[0],
                    else => options[1],
                };
                steps += 1;
                last_char = current_loc[2];
                if (last_char == 'Z') {
                    break;
                }
            }
        }
        try cycle_lengths.append(steps);
    }
    var lcm: u128 = 1;
    for (cycle_lengths.items) |length| {
        lcm = (lcm * length) / std.math.gcd(lcm, length);
    }
    std.log.debug("LCM Z Cycles: {d}", .{lcm});

    // Part 2 Proper
    steps = 0;
    var all_z = false;
    while (!all_z) {
        for (instructions) |instr| {
            var is_all_z = true;
            for (starting_points.items, 0..) |point, idx| {
                const options = desert_map.get(point).?;
                const new_point = switch (instr) {
                    'L' => options[0],
                    else => options[1],
                };
                is_all_z = is_all_z and point[2] == 'Z';
                starting_points.items[idx] = new_point;
            }
            steps += 1;
            if (is_all_z) {
                all_z = true;
                break;
            }
        }
    }

    std.log.debug("Num Steps before all Z: {d}", .{steps});
}
