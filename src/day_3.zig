const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;
pub fn main() !void {
    var main_arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    const ma = main_arena.allocator();
    defer _ = main_arena.deinit();

    var grid = ArrayList([]u8).init(ma);
    var lines = try util.read_delim(&ma, "resources/day_2/input", "\n");
    while (lines.next()) |line| {
        var components = ArrayList(u8).init(ma);
        for (line) |char| {
            try components.append(char);
        }
        try grid.append(try components.toOwnedSlice());
    }
    const engine = try grid.toOwnedSlice();
    const y_dim = engine.len;
    const x_dim = engine[0].len;
    std.log.info("{any}", .{engine});
    std.log.info("{any}", .{y_dim});
    std.log.info("{any}", .{x_dim});
}
