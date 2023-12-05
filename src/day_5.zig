const std = @import("std");
const util = @import("util.zig");
const Allocator = std.mem.Allocator;
const SeedArray = std.ArrayList(SeedFunction);

const SeedFunction = struct { start: i128, range: i128, function: i128 };

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

    var min_loc: i128 = 1000000000000000000;
    while (seeds.next()) |s| {
        var seed = try std.fmt.parseInt(i128, s, 10);
        for (maps) |map| {
            // std.log.debug("use {any}", .{map});
            for (map.items) |seed_func| {
                if (seed >= seed_func.start and seed < seed_func.start + seed_func.range) {
                    seed += seed_func.function;
                    break;
                }
            }
            // std.log.debug("mapped {d}", .{seed});
        }
        if (seed < min_loc) {
            min_loc = seed;
        }
    }

    std.log.info("Lowest Loc Num: {d}", .{min_loc});
}
