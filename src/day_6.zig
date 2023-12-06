const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;

const PART = 1;

// Return a new string by concatenating strings in an ArrayList
fn concat(allocator: std.mem.Allocator, strings: ArrayList([]const u8)) ![]u8 {
    var total_len: usize = 0;
    for (strings.items) |str| {
        total_len += str.len;
    }

    var string = try allocator.alloc(u8, total_len);
    var offset: usize = 0;
    for (strings.items) |str| {
        std.mem.copy(u8, string[offset..][0..str.len], str);
        offset += str.len;
    }

    return string;
}

pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var lines = try util.read_delim(&ma, "resources/day_6/input", "\n");
    var time_input = std.mem.tokenizeScalar(u8, lines.next().?[5..], ' ');
    var dist_input = std.mem.tokenizeScalar(u8, lines.next().?[9..], ' ');

    var times = ArrayList(usize).init(ma);
    var time_strs = ArrayList([]const u8).init(ma);
    while (time_input.next()) |t| {
        const time = try std.fmt.parseUnsigned(usize, t, 10);
        try times.append(time);
        try time_strs.append(t);
    }
    const big_time_str = try concat(ma, time_strs);
    const big_time = try std.fmt.parseFloat(f64, big_time_str);
    time_strs.clearAndFree();

    var distances = ArrayList(usize).init(ma);
    var distance_strs = ArrayList([]const u8).init(ma);
    while (dist_input.next()) |d| {
        const distance = try std.fmt.parseUnsigned(usize, d, 10);
        try distances.append(distance);
        try distance_strs.append(d);
    }
    const big_record_str = try concat(ma, distance_strs);
    const big_record = try std.fmt.parseFloat(f64, big_record_str);
    distance_strs.clearAndFree();

    // Part 1: Brute Force
    var record_mult: u32 = 1;
    for (times.items, distances.items) |time, record| {
        if (time != 0) {
            var record_times: u32 = 0;
            for (1..time) |velocity| {
                const distance = velocity * (time - velocity);
                if (distance > record) {
                    record_times += 1;
                }
            }
            record_mult *= record_times;
        }
    }

    // Part 2: Quadratic Formula
    // distance = (time - velocity) * velocity
    // 0 = velocity^2 - velocity*time + distance
    // solve for velocity, time = -big_time, distance = big_record
    // velocity = (-time±√(time²-4distance))/2
    // record must equal max(velocity) - min(velocity)
    const inner_term = std.math.sqrt(big_time * big_time - 4 * big_record);
    const solution_1 = std.math.floor((big_time + inner_term) / 2);
    const solution_2 = std.math.ceil((big_time - inner_term) / 2);

    std.log.info("Record Mult: {d}", .{record_mult});
    std.log.info("Big Race Record: {d}", .{solution_1 - solution_2 + 1});
}
