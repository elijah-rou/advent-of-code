const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

fn seq_next(allocator: Allocator, seq: []i32, forward_pass: bool) !i32 {
    var diffs = ArrayList(i32).init(allocator);
    var all_zero: bool = seq[0] == 0;
    for (0..seq.len - 1) |i| {
        const diff = switch (forward_pass) {
            true => seq[i + 1] - seq[i],
            false => seq[i] - seq[i + 1],
        };
        try diffs.append(diff);
        all_zero = all_zero and seq[i + 1] == 0;
    }
    if (all_zero) {
        return 0;
    }
    const pass_value = if (forward_pass) seq[seq.len - 1] else seq[0];
    return pass_value + try seq_next(allocator, diffs.items, forward_pass);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var acc: i32 = 0;
    var neg_acc: i32 = 0;
    var lines = try util.read_delim(&allocator, "resources/day_9/input", "\n");
    while (lines.next()) |line| {
        var nums = std.mem.tokenizeScalar(u8, line, ' ');
        var seq = ArrayList(i32).init(allocator);
        while (nums.next()) |n| {
            const int = try std.fmt.parseInt(i32, n, 10);
            try seq.append(int);
        }
        acc += try seq_next(allocator, seq.items, true);
        neg_acc += try seq_next(allocator, seq.items, false);
    }

    std.log.info("Forward Seq Sum: {d}", .{acc});
    std.log.info("Backward Seq Sum: {d}", .{neg_acc});
}
