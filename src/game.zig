const std = @import("std");
const logging = @import("main.zig").logging;
pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("raygui.h");
});

var screen_width: i32 = 800;
var screen_height: i32 = 450;

pub fn init() !void {
    rl.SetExitKey(rl.KEY_ESCAPE);
    rl.SetTraceLogLevel(rl.LOG_WARNING);

    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT | rl.FLAG_VSYNC_HINT);
    rl.InitWindow(screen_width, screen_height, "myapp");
    rl.SetTargetFPS(60);
}
pub fn deinit() !void {
    rl.CloseWindow();
}
pub fn input(dt: f32) !void {
    _ = &dt;
    switch (rl.GetKeyPressed()) {
        0 => {},
        else => |key| logging("Input key:{}\n", .{key}),
    }
}
pub fn update(dt: f32) !void {
    _ = &dt;
}
pub fn draw_start(dt: f32) !void {
    _ = &dt;
}
pub fn draw_end(dt: f32) !void {
    _ = &dt;
}
pub fn draw(dt: f32) !void {
    _ = &dt;
}
