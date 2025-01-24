const std = @import("std");
const util = @import("util.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();
    var lines = try util.read_delim(&allocator, "resources/day_14/input", "\n");

    var rows = std.ArrayList([]u8).init(allocator);
    while (lines.next()) |l| {
        var row = try allocator.alloc(u8, l.len);
        std.mem.copy(u8, row, l);
        try rows.append(row);
    }

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
    }
    std.log.info("Northern Load: {d}", .{load});

    rows.deinit();
    rows = std.ArrayList([]u8).init(allocator);
    lines.reset();
    while (lines.next()) |l| {
        var row = try allocator.alloc(u8, l.len);
        std.mem.copy(u8, row, l);
        try rows.append(row);
    }
    allocator.free(lines.buffer);
    for (1..1000000000) |_| {
        for (0..4) |dir| {
            for (rows.items, 0..) |row, x| {
                for (row, 0..) |item, y| {
                    if (item == 'O') {
                        switch (dir) {
                            0 => { // North
                                if (x != 0) {
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
                            },
                            1 => { // West
                                if (y != 0) {
                                    var roll_y = y - 1;
                                    while (rows.items[x][roll_y] != 'O' and rows.items[x][roll_y] != '#') {
                                        rows.items[x][roll_y + 1] = '.';
                                        rows.items[x][roll_y] = 'O';
                                        if (roll_y == 0) {
                                            break;
                                        }
                                        roll_y -= 1;
                                    }
                                }
                            },
                            2 => { // South
                                const row_len = rows.items.len - 1;
                                if (x != row_len) {
                                    var roll_x = x + 1;
                                    while (rows.items[roll_x][y] != 'O' and rows.items[roll_x][y] != '#') {
                                        rows.items[roll_x - 1][y] = '.';
                                        rows.items[roll_x][y] = 'O';
                                        if (roll_x == row_len) {
                                            break;
                                        }
                                        roll_x += 1;
                                    }
                                }
                            },
                            else => { // East
                                const col_len = rows.items[x].len - 1;
                                if (y != col_len) {
                                    var roll_y = y + 1;
                                    while (rows.items[x][roll_y] != 'O' and rows.items[x][roll_y] != '#') {
                                        rows.items[x][roll_y - 1] = '.';
                                        rows.items[x][roll_y] = 'O';
                                        if (roll_y == col_len) {
                                            break;
                                        }
                                        roll_y += 1;
                                    }
                                }
                            },
                        }
                    }
                }
            }
        }
    }
    load = 0;
    for (rows.items, 0..) |row, x| {
        for (row) |item| {
            if (item == 'O') {
                load += rows.items.len - x;
            }
        }
    }
    std.log.info("Cycles Load: {d}", .{load});
}
