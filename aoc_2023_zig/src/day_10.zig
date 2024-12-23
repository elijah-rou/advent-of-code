const std = @import("std");
const util = @import("util.zig");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

const Direction = enum { up, down, left, right };
const HashSet = std.AutoHashMap([2]usize, void);
const PipeResult = struct {
    x: usize,
    y: usize,
    momentum: Direction,
};

fn follow_pipe(pipe: u8, momentum: Direction, x: usize, y: usize) PipeResult {
    return switch (momentum) {
        .up => {
            return switch (pipe) {
                '|' => PipeResult{ .x = x, .y = y - 1, .momentum = .up },
                '7' => PipeResult{ .x = x - 1, .y = y, .momentum = .left },
                else => PipeResult{ .x = x + 1, .y = y, .momentum = .right },
            };
        },
        .down => {
            return switch (pipe) {
                '|' => PipeResult{ .x = x, .y = y + 1, .momentum = .down },
                'J' => PipeResult{ .x = x - 1, .y = y, .momentum = .left },
                else => PipeResult{ .x = x + 1, .y = y, .momentum = .right },
            };
        },
        .left => {
            return switch (pipe) {
                '-' => PipeResult{ .x = x - 1, .y = y, .momentum = .left },
                'L' => PipeResult{ .x = x, .y = y - 1, .momentum = .up },
                else => PipeResult{ .x = x, .y = y + 1, .momentum = .down },
            };
        },
        else => {
            return switch (pipe) {
                '-' => PipeResult{ .x = x + 1, .y = y, .momentum = .right },
                '7' => PipeResult{ .x = x, .y = y + 1, .momentum = .down },
                else => PipeResult{ .x = x, .y = y - 1, .momentum = .up },
            };
        },
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var lines = try util.read_delim(&allocator, "resources/day_10/input", "\n");
    var grid = std.mem.zeroes([140][140]u8);
    var s_loc: [2]usize = undefined;
    var y: usize = 0;
    while (lines.next()) |line| {
        for (line, 0..) |char, x| {
            grid[y][x] = char;
            if (char == 'S') {
                s_loc = .{ x, y };
            }
        }
        y += 1;
    }

    var steps: u32 = 1;
    var current_pipe: u8 = '|';
    var momentum: Direction = .down;
    var current_x = s_loc[0];
    var current_y = s_loc[1] + 1;
    var pipe_locs = HashSet.init(allocator);
    try pipe_locs.put(.{ current_x, current_y }, undefined);

    while (current_pipe != 'S') {
        const next_pipe = follow_pipe(current_pipe, momentum, current_x, current_y);
        current_x = next_pipe.x;
        current_y = next_pipe.y;
        momentum = next_pipe.momentum;

        current_pipe = grid[current_y][current_x];
        try pipe_locs.put(.{ current_x, current_y }, undefined);
        steps += 1;
    }
    const longest_len = steps / 2;
    std.log.info("Longest Len: {d}", .{longest_len});

    var space: u32 = 0;
    for (0..140) |row| {
        var in: bool = false;
        for (0..140) |col| {
            const pipe = grid[row][col];
            if (pipe_locs.contains(.{ col, row })) {
                if (pipe == '7' or pipe == 'F' or pipe == '|' or pipe == 'S') {
                    in = !in;
                }
            } else if (in and !pipe_locs.contains(.{ col, row })) {
                space += 1;
            }
        }
    }
    std.log.info("Contained Space: {d}", .{space});
}
