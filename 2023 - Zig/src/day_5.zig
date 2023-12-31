const std = @import("std");
const util = @import("util.zig");
const Allocator = std.mem.Allocator;
const SeedArray = std.ArrayList(SeedFunction);
const ArrayList = std.ArrayList;

const SeedFunction = struct { start: i64, end: i64, function: i64 };
const PART = 2;

fn min(x: i64, y: i64) i64 {
    if (x <= y) return x else return y;
}

fn max(x: i64, y: i64) i64 {
    if (x > y) return x else return y;
}

pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var lines = try util.read_delim(&ma, "resources/day_5/input", "\n");
    var seed_list = std.mem.splitScalar(u8, lines.next().?[7..], ' ');
    var maps = [7]SeedArray{ undefined, undefined, undefined, undefined, undefined, undefined, undefined };

    var idx: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            maps[idx] = SeedArray.init(ma);
            idx += 1;
        } else if (util.is_digit(line[0])) {
            var values = std.mem.splitScalar(u8, line, ' ');
            const dest = try std.fmt.parseInt(i64, values.next().?, 10);

            const source = try std.fmt.parseInt(i64, values.next().?, 10);
            const range = try std.fmt.parseInt(i64, values.next().?, 10);
            const function: i64 = dest - source;

            try maps[idx - 1].append(SeedFunction{ .start = source, .end = source + range, .function = function });
        }
    }
    var min_loc: i64 = @bitCast(std.math.inf(f64));
    switch (PART) {
        1 => {
            while (seed_list.next()) |s| {
                var location = try std.fmt.parseInt(i64, s, 10);
                for (maps) |map| {
                    for (map.items) |seed_func| {
                        if (location >= seed_func.start and location < seed_func.end) {
                            location += seed_func.function;
                            break;
                        }
                    }
                }
                if (location < min_loc) {
                    min_loc = location;
                }
            }
        },
        else => {
            var seeds = ArrayList([2]i64).init(ma);
            while (seed_list.next()) |s| {
                const range_start = try std.fmt.parseInt(i64, s, 10);
                const seed_range = try std.fmt.parseInt(i64, seed_list.next().?, 10);
                try seeds.append(.{ range_start, range_start + seed_range });
            }
            for (maps) |map| {
                var ranges = ArrayList([2]i64).init(ma);
                while (seeds.popOrNull()) |seed| {
                    for (map.items) |range| {
                        const max_start = max(seed[0], range.start);
                        const min_end = min(seed[1], range.end);
                        if (max_start < min_end) {
                            try ranges.append(.{ max_start + range.function, min_end + range.function });
                            if (max_start > seed[0]) {
                                try seeds.append(.{ seed[0], max_start });
                            }
                            if (min_end < seed[1]) {
                                try seeds.append(.{ min_end, seed[1] });
                            }
                            break;
                        }
                    } else {
                        try ranges.append(.{ seed[0], seed[1] });
                    }
                }
                seeds.clearAndFree();
                seeds = ranges;
            }
            for (seeds.items) |range| {
                if (range[0] < min_loc) {
                    min_loc = range[0];
                }
            }
        },
    }
    std.log.info("Lowest Loc Num: {d}", .{min_loc});
}
