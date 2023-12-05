const std = @import("std");
const util = @import("util.zig");
const Allocator = std.mem.Allocator;
const SeedArray = std.ArrayList(SeedFunction);

const SeedFunction = struct { start: i128, range: i128, function: i128 };
const PART = 2;

fn seed_map(maps: [7]SeedArray, seed: i128) i128 {
    var location = seed;
    for (maps) |map| {
        for (map.items) |seed_func| {
            if (location >= seed_func.start and location < seed_func.start + seed_func.range) {
                location += seed_func.function;
                break;
            }
        }
    }
    return location;
}

pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var lines = try util.read_delim(&ma, "resources/day_5/input", "\n");
    var seeds = std.mem.splitScalar(u8, lines.next().?[7..], ' ');
    var maps = [7]SeedArray{ undefined, undefined, undefined, undefined, undefined, undefined, undefined };

    var idx: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            maps[idx] = SeedArray.init(ma);
            idx += 1;
        } else if (util.is_digit(line[0])) {
            var values = std.mem.splitScalar(u8, line, ' ');
            const dest = try std.fmt.parseInt(i128, values.next().?, 10);

            const source = try std.fmt.parseInt(i128, values.next().?, 10);
            const range = try std.fmt.parseInt(i128, values.next().?, 10);
            const function: i128 = dest - source;

            try maps[idx - 1].append(SeedFunction{ .start = source, .range = range, .function = function });
        }
    }

    var min_loc: i128 = 1000000000000000000; // BEEG number
    while (seeds.next()) |s| {
        switch (PART) {
            1 => {
                const seed = try std.fmt.parseInt(i128, s, 10);
                const location = seed_map(maps, seed);
                if (location < min_loc) {
                    min_loc = location;
                }
            },
            else => {
                const seed_start = try std.fmt.parseUnsigned(usize, s, 10);
                const seed_range = try std.fmt.parseUnsigned(usize, seeds.next().?, 10);
                std.log.debug("{} {} ", .{ seed_start, seed_range });
                for (seed_start..seed_start + seed_range) |current_seed| {
                    const location = seed_map(maps, @as(i128, current_seed));
                    if (location < min_loc) {
                        min_loc = location;
                    }
                }
            },
        }
    }

    std.log.info("Lowest Loc Num: {d}", .{min_loc});
}
