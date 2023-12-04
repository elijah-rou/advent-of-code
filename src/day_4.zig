const std = @import("std");
const util = @import("util.zig");
const Set = std.AutoHashMap(u32, void);
const Allocator = std.mem.Allocator;

fn scratch_draw(allocator: Allocator, score_list: []const u8) !Set {
    // std.log.debug("{s}", .{score_list});
    var str_scores = std.mem.tokenizeScalar(u8, score_list, ' ');
    var winning_scores = Set.init(allocator);
    while (str_scores.next()) |s| {
        // std.log.debug("{s}", .{s});
        const score = try std.fmt.parseInt(u32, s, 10);
        try winning_scores.put(score, undefined);
    }
    return winning_scores;
}

fn get_points(winning_scores: Set, score_list: []const u8) !u32 {
    var str_scores = std.mem.tokenizeScalar(u8, score_list, ' ');
    var total_score: u32 = 0;
    while (str_scores.next()) |s| {
        const score = try std.fmt.parseInt(u32, s, 10);
        if (winning_scores.contains(score)) {
            total_score = switch (total_score) {
                0 => 1,
                else => total_score * 2,
            };
        }
    }
    return total_score;
}

fn am_i_lucky(allocator: Allocator, scorecard: []const u8) !u32 {
    var score_lists = std.mem.splitScalar(u8, scorecard, '|');
    const winning_scores = try scratch_draw(allocator, score_lists.next().?);
    return try get_points(winning_scores, score_lists.next().?);
}

pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var lines = try util.read_delim(&ma, "resources/day_4/input", "\n");
    var total_score: u32 = 0;
    while (lines.next()) |line| {
        if (line.len > 0) {
            total_score += try am_i_lucky(ma, line[9..]);
        }
    }
    std.log.info("Score: {d}", .{total_score});
}
