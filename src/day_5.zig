const std = @import("std");
const util = @import("util.zig");
const HashMap = std.AutoHashMap(usize, usize);
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var lines = try util.read_delim(&ma, "resources/day_5/input", "\n");
    var seeds = std.mem.splitScalar(u8, lines.next().?[7..], ' ');
    var maps = [7]HashMap{ undefined, undefined, undefined, undefined, undefined, undefined, undefined };

    var idx: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            maps[idx] = HashMap.init(ma);
            idx += 1;
        } else if (util.is_digit(line[0])) {
            var values = std.mem.splitScalar(u8, line, ' ');
            const dest = try std.fmt.parseUnsigned(usize, values.next().?, 10);
            const source = try std.fmt.parseUnsigned(usize, values.next().?, 10);
            const range = try std.fmt.parseUnsigned(usize, values.next().?, 10);

            for (source..source + range, dest..dest + range) |s_val, d_val| {
                try maps[idx - 1].put(s_val, d_val);
            }
        }
    }

    var min_loc: usize = 1000000;
    while (seeds.next()) |seed| {
        var seed_u = try std.fmt.parseUnsigned(usize, seed, 10);
        for (maps) |map| {
            if (map.get(seed_u)) |value| {
                seed_u = value;
            }
        }
        if (seed_u < min_loc) {
            min_loc = seed_u;
        }
        std.log.debug("Loc Val: {d}", .{seed_u});
    }

    std.log.info("Lowest Loc Num: {d}", .{min_loc});
}
