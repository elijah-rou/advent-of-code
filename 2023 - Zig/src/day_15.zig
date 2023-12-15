const std = @import("std");
const util = @import("util.zig");
const Hashmap = std.AutoHashMap(u32, std.StringHashMap(u32));

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    const alloc = gp.allocator();
    var lines = try util.read_delim(&alloc, "resources/day_15/input", "\n");
    defer alloc.free(lines.buffer);
    var hashes = std.mem.split(u8, lines.next().?, ",");

    var total_hash: u32 = 0;
    var hashmap = Hashmap.init(alloc);
    defer alloc.free(hashmap);
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const aa = arena.allocator();
    while (hashes.next()) |h| {
        var current_hash: u32 = 0;
        for (h, 0..) |char, i| {
            current_hash += char;
            current_hash *= 17;
            current_hash = try std.math.rem(u32, current_hash, 256);
            const label = h[0..i];
            if (char == '=') {
                const focal = try std.fmt.parseUnsigned(u32, h[i + 1 ..], 10);
                if (hashmap.getPtr(current_hash)) |box| {
                    try box.put(label, focal);
                } else {
                    var lenses = std.StringHashMap(u32).init(aa);
                    try lenses.put(label, focal);
                    try hashmap.put(current_hash, lenses);
                }
            } else if (char == '-') {
                if (hashmap.getPtr(current_hash)) |box| {
                    _ = box.remove(label);
                }
            }
        }
        total_hash += current_hash;
    }

    std.log.info("Total Hash: {d}", .{total_hash});
}
