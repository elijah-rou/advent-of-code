const std = @import("std");
const util = @import("util.zig");

pub fn main() !void {
    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    const alloc = gp.allocator();
    var lines = try util.read_delim(&alloc, "resources/day_15/input", "\n");
    defer alloc.free(lines.buffer);
    var hashes = std.mem.split(u8, lines.next().?, ",");

    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer _ = arena.deinit();
    const aa = arena.allocator();
    var total_hash: usize = 0;
    var hashmap = std.AutoHashMap(usize, std.StringArrayHashMap(u32)).init(aa);
    while (hashes.next()) |h| {
        var current_hash: usize = 0;
        for (h, 0..) |char, i| {
            const label = h[0..i];
            if (char == '=') {
                const focal = try std.fmt.parseUnsigned(u32, h[i + 1 ..], 10);
                std.log.debug("Put focal {s} {d} in {d}", .{ label, focal, current_hash });
                if (hashmap.getPtr(current_hash)) |box| {
                    try box.put(label, focal);
                } else {
                    var lenses = std.StringArrayHashMap(u32).init(aa);
                    try lenses.put(label, focal);
                    try hashmap.put(current_hash, lenses);
                }
            } else if (char == '-') {
                std.log.debug("Remove focal {s} from {d}", .{ label, current_hash });
                if (hashmap.getPtr(current_hash)) |box| {
                    _ = box.orderedRemove(label);
                }
            }
            current_hash += char;
            current_hash *= 17;
            current_hash = try std.math.rem(usize, current_hash, 256);
        }
        total_hash += current_hash;
    }

    var focus_power: usize = 0;
    for (0..256) |box| {
        if (hashmap.get(box)) |lenses| {
            var iterator = lenses.iterator();
            var slot: u32 = 1;
            while (iterator.next()) |lense| {
                focus_power += (box + 1) * slot * lense.value_ptr.*;
                std.log.debug("Box {d}, Lense {s}: {d}", .{ box, lense.key_ptr.*, focus_power });
                slot += 1;
            }
        }
    }

    std.log.info("Total Hash: {d}", .{total_hash});
    std.log.info("Focus Power: {d}", .{focus_power});
}
