const std = @import("std");
const util = @import("util.zig");
const CardSet = std.AutoHashMap(u8, u32);
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

fn card_map(card: u8) u32 {
    return switch (card) {
        65 => 14, // A
        75 => 13, // K
        81 => 12, // Q
        74 => 11, // J
        84 => 10, // T
        57 => 9, // 9
        56 => 8, // 8
        55 => 7, // 7
        54 => 6, // 6
        53 => 5, // 5
        52 => 4, // 4
        51 => 3, // 3
        50 => 2, // 2
        else => 1, // default case
    };
}

fn score_draw(allocator: Allocator, cards: []u8) !u32 {
    var card_set = CardSet.init(allocator);

    for (cards) |card| {
        if (card_set.get(card)) |amt| {
            try card_set.put(card, amt + 1);
        } else {
            try card_set.put(card, 1);
        }
    }
    var valueIt = card_set.valueIterator();
    return switch (card_set.count()) {
        1 => 7, // five of a kind
        2 => {
            while (valueIt.next()) |amt| {
                if (amt.* == 4) { // four of a kind
                    return 6;
                }
            } else {
                return 5; // full house
            }
        },
        3 => {
            while (valueIt.next()) |amt| {
                if (amt.* == 3) { // three of a kind
                    return 4;
                }
            } else { // two pair
                return 3;
            }
        },
        4 => 2, // one pair
        else => 1, // high card
    };
}

fn tiebreak(_: void, cards_1: [2][]u8, cards_2: [2][]u8) bool {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();

    const cards_1_rank = score_draw(allocator, cards_1[0]) catch return true;
    const cards_2_rank = score_draw(allocator, cards_2[0]) catch return true;
    std.log.debug("{s}|{d} <-> {s}|{d}", .{ cards_1[0], cards_1_rank, cards_2[0], cards_2_rank });
    if (cards_1_rank == cards_2_rank) {
        for (cards_1[0], cards_2[0]) |card_1, card_2| {
            if (card_1 != card_2) {
                if (card_map(card_1) < card_map(card_2)) return true else return false;
            }
        }
        return true;
    } else {
        return cards_1_rank < cards_2_rank;
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();

    var camel_cards = ArrayList([2][]u8).init(allocator);
    var lines = try util.read_delim(&allocator, "resources/day_7/input", "\n");
    while (lines.next()) |cards| {
        var draw_and_bid = std.mem.splitScalar(u8, cards, ' ');
        const draw = draw_and_bid.next().?;
        var draw_slice = try allocator.alloc(u8, draw.len);
        std.mem.copy(u8, draw_slice, draw);

        const bid = draw_and_bid.next().?;
        var bid_slice = try allocator.alloc(u8, bid.len);
        std.mem.copy(u8, bid_slice, bid);
        try camel_cards.append(.{ draw_slice, bid_slice });
    }
    std.sort.block([2][]u8, camel_cards.items, {}, tiebreak);

    var winnings: usize = 0;
    for (camel_cards.items, 1..) |card_and_bid, rank| {
        winnings += try std.fmt.parseUnsigned(usize, card_and_bid[1], 10) * rank;
        std.log.debug("{s}", .{card_and_bid[0]});
    }

    std.log.debug("Winnigs: {d}", .{winnings});
}
