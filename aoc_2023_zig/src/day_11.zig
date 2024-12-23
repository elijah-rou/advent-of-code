// 1) If row all ., duplicate row

// 2) create flag per col, if val at x,y not ., flag false
// 2) loop again, if flag true for x,y append .

const std = @import("std");
const util = @import("util.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const allocator = arena.allocator();
    var lines = try util.read_delim(&allocator, "resources/day_11/test", "\n");

    const num_cols = lines.next().?.len;
    var should_expand = std.AutoHashMap(usize, void).init(allocator);
    for (0..num_cols) |x| {
        try should_expand.put(x, undefined);
    }

    var grid = std.ArrayList(std.ArrayList(u8)).init(allocator);
    while (lines.next()) |line| {
        var row = std.ArrayList(u8).init(allocator);
        var all_space: bool = true;
        try row.appendSlice(line);
        for (line, 0..) |char, x| {
            try row.append(char);
            all_space = all_space and char == '.';
            if (char != '.') {
                _ = should_expand.remove(x);
            }
        }
        try grid.append(row);

        if (all_space) {
            var dup_row = std.ArrayList(u8).init(allocator);
            var dup_slice = try allocator.alloc(u8, line.len);
            std.mem.copy(u8, dup_slice, line);
            try dup_row.appendSlice(dup_slice);
        }
    }
    for (grid.items, 0..) |row, y| {
        for (row.items, 0..) |_, x| {
            if (should_expand.contains(x)) {
                try grid.items[y].insert(x + 1, '.');
            }
        }
        std.log.debug("{s}", .{row.items});
    }
}
