const std = @import("std");
const util = @import("util.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();
    var lines = try util.read_delim(&allocator, "resources/day_14/test", "\n");

    var rows = std.ArrayList([]u8).init(allocator);
    while (lines.next()) |l| {
        var row = try allocator.alloc(u8, l.len);
        std.mem.copy(u8, row, l);
        try rows.append(row);
    }
    allocator.free(lines.buffer);

    for (rows.items, 0..) |row, x| {
        for (row, 0..) |item, y| {
            if (item == 'O' and x != 0) {
                var roll_x = x - 1;
                while (rows.items[roll_x][y] != 'O' and rows.items[roll_x][y] != '#') {
                    rows.items[roll_x + 1][y] = '.';
                    rows.items[roll_x][y] = 'O';
                    if (roll_x == 0) {
                        break;
                    }
                    roll_x -= 1;
                }
            }
        }
    }
    var load: usize = 0;
    for (rows.items, 0..) |row, x| {
        for (row) |item| {
            if (item == 'O') {
                load += rows.items.len - x;
            }
        }
        std.log.debug("{s}", .{row});
    }
    std.log.info("Northern Load: {d}", .{load});
}
