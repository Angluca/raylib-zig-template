const std = @import("std");
const game = @import("game.zig");
const rl = game.rl;

fn loops(dt: f32) !void {
    try game.input(dt);
    try game.update(dt);
    // draw
    try game.draw_start(dt);
    rl.BeginDrawing();
    try game.draw(dt);
    rl.EndDrawing();
    try game.draw_end(dt);
}

pub fn main() !void {
    game.init() catch |err| {
        logging("=== initFn Error: {any}", .{err});
    };

    var dt: f32 = 0;
    while (!rl.WindowShouldClose()) {
        dt = rl.GetFrameTime();
        loops(dt) catch |err| {
            if(err != error.Exit) {
                logging("=== loopFn Error: {any}", .{err});
            } else break;
        };
    }
    game.deinit() catch |err| {
        logging("=== deinitFn Error: {any}", .{err});
    };
}

pub fn logging(comptime fmt: []const u8, args: anytype) void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);

    bw.writer().print(fmt, args) catch {};
    bw.flush() catch {};
}

