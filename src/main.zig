const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raygui.h");
    @cInclude("raymath.h");
});

var gpa = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
const allocator = gpa.allocator();

// const monitor = rl.GetCurrentMonitor();
// const screen_width = rl.GetMonitorWidth(monitor);
// const screen_height = rl.GetMonitorHeight(monitor);
const screen_width = 800;
const screen_height = 450;

var is_drag_window: bool = false;
var is_exit_window: bool = false;

const colors = [_]rl.Color{ rl.GRAY, rl.RED, rl.GOLD, rl.LIME, rl.BLUE, rl.VIOLET, rl.BROWN };
const colors_len: i32 = @intCast(colors.len);
var current_color: i32 = 2;
var hint = true;

var window_pos: rl.Vector2 = .{.x=screen_width, .y=screen_height};
var mouse_pos: rl.Vector2 = undefined;
var pan_offset: rl.Vector2 = undefined;
var camera: rl.Camera3D = undefined;
var angle: i32 = 0;

fn init() anyerror!void {
    _ = &is_exit_window;
    _ = &window_pos;
    _ = &pan_offset;
    _ = &mouse_pos;
    //rl.SetTraceLogLevel(rl.LOG_WARNING);

    rl.SetConfigFlags(rl.FLAG_MSAA_4X_HINT | rl.FLAG_VSYNC_HINT);
    rl.InitWindow(screen_width, screen_height, "myapp");
    rl.SetTargetFPS(60);

    camera.position = .{ .x=40.0, .y=20, .z=0 };
    camera.target = .{ .x=0, .y=0, .z=0 };
    camera.up = .{ .x=0, .y=1.0, .z=0 };
    camera.fovy = 70.0;
    camera.projection = rl.CAMERA_PERSPECTIVE;
}

fn deinit() anyerror!void {
    switch (gpa.deinit()) {
        .leak => @panic("leaked memory"),
        else => {},
    }
    rl.CloseWindow();
}

fn input(dt: f32) anyerror!void {
    _ = &dt;
    // mouse
    {
        mouse_pos = rl.GetMousePosition();
        window_pos = rl.GetWindowPosition();
        if(rl.IsMouseButtonPressed(rl.MOUSE_LEFT_BUTTON) and !is_drag_window) {
            if(rl.CheckCollisionPointRec(mouse_pos, .{.x=0,.y=0, .width=screen_width, .height=screen_height})) {
                is_drag_window = true;
                pan_offset = mouse_pos;
            }
        }

        if(is_drag_window) {
            window_pos.x += (mouse_pos.x - pan_offset.x);
            window_pos.y += (mouse_pos.y - pan_offset.y);
            rl.SetWindowPosition(@intFromFloat(window_pos.x), @intFromFloat(window_pos.y));
            if(rl.IsMouseButtonReleased(rl.MOUSE_LEFT_BUTTON)) is_drag_window = false;
        }
    }
    // input
    {
        var delta: i2 = 0;
        if (rl.IsKeyPressed(rl.KEY_W)) delta += 1;
        if (rl.IsKeyPressed(rl.KEY_S)) delta -= 1;
        if (delta != 0) {
            current_color = @mod(current_color + delta, colors_len);
            hint = false;
        }
    }
}

fn update(dt: f32) anyerror!void {
    _ = &dt;
    const camera_time: f32 = @floatCast(rl.GetTime() * 0.3);
    camera.position.x = @cos(camera_time) * 40.0;
    camera.position.z = @sin(camera_time) * 40.0;
}

fn draw(dt: f32) anyerror!void {
    _ = &dt;

    rl.BeginDrawing(); // --------

    rl.ClearBackground(colors[@intCast(current_color)]);
    if (hint) rl.DrawText("press up or down arrow to change background color", 120, 140, 20, rl.BLUE);
    rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.BLACK);

    rl.DrawText(rl.TextFormat("Mouse Position: [%.0f, %.0f]", mouse_pos.x, mouse_pos.y), 0, 0, 20, rl.DARKGRAY);
    rl.DrawText(rl.TextFormat("Window Position: [%.0f, %.0f]", window_pos.x, window_pos.y), 0, 20, 20, rl.DARKGRAY);

    if(rl.GuiButton(.{.x=10,.y=70,.width=50, .height=20}, "button") != 0) {
        rl.ClearBackground(rl.SKYBLUE);
    }

    // now lets use an allocator to create some dynamic text
    // pay attention to the Z in `allocPrintZ` that is a convention
    // for functions that return zero terminated strings
    const seconds: u32 = @intFromFloat(rl.GetTime());
    const dynamic = try std.fmt.allocPrintZ(allocator, "running since {d} seconds", .{seconds});
    defer allocator.free(dynamic);
    rl.DrawText(dynamic, 300, 250, 20, rl.WHITE);

    rl.DrawFPS(screen_width - 100, 10);

    rl.BeginMode3D(camera);
        rl.DrawCube((rl.Vector3{.x=0,.y=-20,.z=0}),10,10,10,rl.VIOLET);
    rl.EndMode3D();

    rl.EndDrawing(); // ---------
}

fn loops(dt: f32) anyerror!void {
    try input(dt);
    try update(dt);
    try draw(dt);
}

fn logging(comptime fmt: []const u8, args: anytype) void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);

    bw.writer().print(fmt, args) catch {};
    bw.flush() catch {};
}

pub fn main() !void {
    // init
    init() catch |err| {
        logging("=== initFn Error: {any}", .{err});
    };

    // loops
    var dt: f32 = 0;
    while (!is_exit_window and !rl.WindowShouldClose()) {
        dt = rl.GetFrameTime();
        //try ray_main();
        loops(dt) catch |err| {
            if(err != error.Exit) {
                logging("=== loopFn Error: {any}", .{err});
            } else break;
        };
    }
    // deinit
    deinit() catch |err| {
        logging("=== deinitFn Error: {any}", .{err});
    };
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

