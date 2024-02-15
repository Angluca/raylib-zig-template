const std = @import("std");
const ray = @import("raylib.zig");

pub fn main() !void {
    try ray_main();
    try old_main(); // remove this if you don't need it
    try hints();
}

fn ray_main() !void {
    // const monitor = ray.GetCurrentMonitor();
    // const screen_width = ray.GetMonitorWidth(monitor);
    // const screen_height = ray.GetMonitorHeight(monitor);
    const screen_width = 800;
    const screen_height = 450;

    ray.SetConfigFlags(ray.FLAG_MSAA_4X_HINT | ray.FLAG_VSYNC_HINT);
    ray.InitWindow(screen_width, screen_height, "myapp");
    defer ray.CloseWindow();

    var gpa = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
    const allocator = gpa.allocator();
    defer {
        switch (gpa.deinit()) {
            .leak => @panic("leaked memory"),
            else => {},
        }
    }

    const colors = [_]ray.Color{ ray.GRAY, ray.RED, ray.GOLD, ray.LIME, ray.BLUE, ray.VIOLET, ray.BROWN };
    const colors_len: i32 = @intCast(colors.len);
    var current_color: i32 = 2;
    var hint = true;

    var mouse_pos: ray.Vector2 = undefined;
    var window_pos: ray.Vector2 = .{.x=screen_width, .y=screen_height};
    var pan_offset: ray.Vector2 = mouse_pos;
    _ = &window_pos;

    var is_drag_window: bool = false;
    var is_exit_window: bool = false;
    _ = &is_exit_window;

    ray.SetTargetFPS(60);
    while (!is_exit_window and !ray.WindowShouldClose()) {
        // mouse
        {
            mouse_pos = ray.GetMousePosition();
            window_pos = ray.GetWindowPosition();
            if(ray.IsMouseButtonPressed(ray.MOUSE_LEFT_BUTTON) and !is_drag_window) {
                if(ray.CheckCollisionPointRec(mouse_pos, .{.x=0,.y=0, .width=screen_width, .height=screen_height})) {
                    is_drag_window = true;
                    pan_offset = mouse_pos;
                }
            }

            if(is_drag_window) {
                window_pos.x += (mouse_pos.x - pan_offset.x);
                window_pos.y += (mouse_pos.y - pan_offset.y);
                ray.SetWindowPosition(@intFromFloat(window_pos.x), @intFromFloat(window_pos.y));
                if(ray.IsMouseButtonReleased(ray.MOUSE_LEFT_BUTTON)) is_drag_window = false;
            }
        }

        // input
        var delta: i2 = 0;
        if (ray.IsKeyPressed(ray.KEY_W)) delta += 1;
        if (ray.IsKeyPressed(ray.KEY_S)) delta -= 1;
        if (delta != 0) {
            current_color = @mod(current_color + delta, colors_len);
            hint = false;
        }

        // draw
        {
            ray.BeginDrawing();
            defer ray.EndDrawing();

            ray.ClearBackground(colors[@intCast(current_color)]);
            if (hint) ray.DrawText("press up or down arrow to change background color", 120, 140, 20, ray.BLUE);
            ray.DrawText("Congrats! You created your first window!", 190, 200, 20, ray.BLACK);

            ray.DrawText(ray.TextFormat("Mouse Position: [%.0f, %.0f]", mouse_pos.x, mouse_pos.y), 0, 0, 20, ray.DARKGRAY);
            ray.DrawText(ray.TextFormat("Window Position: [%.0f, %.0f]", window_pos.x, window_pos.y), 0, 20, 20, ray.DARKGRAY);

            if(ray.GuiButton(.{.x=10,.y=70,.width=50, .height=20}, "button") != 0) {
            }

            // now lets use an allocator to create some dynamic text
            // pay attention to the Z in `allocPrintZ` that is a convention
            // for functions that return zero terminated strings
            const seconds: u32 = @intFromFloat(ray.GetTime());
            const dynamic = try std.fmt.allocPrintZ(allocator, "running since {d} seconds", .{seconds});
            defer allocator.free(dynamic);
            ray.DrawText(dynamic, 300, 250, 20, ray.WHITE);

            ray.DrawFPS(screen_width - 100, 10);
        }
    }
}

// remove this function if you don't need it
fn old_main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

fn hints() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("\n⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯\n", .{});
    try stdout.print("Here are some hints:\n", .{});
    try stdout.print("Run `zig build --help` to see all the options\n", .{});
    try stdout.print("Run `zig build -Doptimize=ReleaseSmall` for a small release build\n", .{});
    try stdout.print("Run `zig build -Doptimize=ReleaseSmall -Dstrip=true` for a smaller release build, that strips symbols\n", .{});
    try stdout.print("Run `zig build -Draylib-optimize=ReleaseFast` for a debug build of your application, that uses a fast release of raylib (if you are only debugging your code)\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.items[0]);
    try std.testing.expectEqual(@as(i32, 42), list.getLast());
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
