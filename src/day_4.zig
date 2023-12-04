const std = @import("std");
const util = @import("util.zig");
const HashMap = std.AutoHashMap(u32, u32);
const Set = std.StringHashMap(void);
const Allocator = std.mem.Allocator;

fn scratch_draw(allocator: Allocator, score_list: []const u8) !Set {
    var str_scores = std.mem.tokenizeScalar(u8, score_list, ' ');
    var winning_scores = Set.init(allocator);
    while (str_scores.next()) |score| {
        try winning_scores.put(score, undefined);
    }
    return winning_scores;
}

fn am_i_lucky(winning_scores: Set, score_list: []const u8) !u32 {
    var draw_scores = std.mem.tokenizeScalar(u8, score_list, ' ');
    var total_score: u32 = 0;
    while (draw_scores.next()) |score| {
        if (winning_scores.contains(score)) {
            total_score = switch (total_score) {
                0 => 1,
                else => total_score * 2,
            };
        }
    }
    return total_score;
}

fn scratchcard_bonanza(card: u32, winning_scores: Set, card_collection: *HashMap, score_list: []const u8) !void {
    var draw_scores = std.mem.tokenizeScalar(u8, score_list, ' ');
    var count: u32 = 1;
    while (draw_scores.next()) |score| {
        if (winning_scores.contains(score)) {
            const received_card = card + count;
            if (card_collection.get(received_card)) |value| {
                try card_collection.put(received_card, value + 1);
            } else {
                try card_collection.put(received_card, 1);
            }
        }
    }
}

pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var lines = try util.read_delim(&ma, "resources/day_4/test", "\n");
    var total_score: u32 = 0;

    var card_collection = HashMap.init(ma);
    var card_idx: u32 = 1;
    while (lines.next()) |line| {
        if (line.len > 0) {
            var score_lists = std.mem.splitScalar(u8, line[9..], '|');
            const winning_scores = try scratch_draw(ma, score_lists.next().?);
            const draw_scores = score_lists.next().?;

            total_score += try am_i_lucky(winning_scores, draw_scores);
            try scratchcard_bonanza(card_idx, winning_scores, &card_collection, draw_scores);
        }
        card_idx += 1;
    }

    var total_cards: u32 = 0;
    var card_iterator = card_collection.valueIterator();
    while (card_iterator.next()) |card_number| {
        total_cards += card_number.*;
    }

    std.log.info("Score: {d}", .{total_score});
    std.log.info("Total Cards: {d}", .{total_cards});
}
