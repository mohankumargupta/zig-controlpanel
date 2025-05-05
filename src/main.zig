// src/main.zig
const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");
const parseJustfile = @import("justfile.zig").parseJustfile;
const Recipe = @import("justfile.zig").Recipe;
const Parameter = @import("justfile.zig").Parameter;
const justfile = @import("justfile.zig");
const Justfile = @import("justfile.zig").Justfile;
const mainPane = @import("mainpane.zig").mainPane;
const ClayUI = @import("clayui.zig").ClayUI;

const fs = std.fs;
const fmt = std.fmt;
const os = std.os;
const builtin = @import("builtin");
const process = std.process;
const RunResult = std.process.Child.RunResult;
const mem = std.mem;
const json = std.json;

const COLOR_PANEL_BACKGROUND: cl.Color = .{ 61, 26, 5, 255 };
const COLOR_BORDER: cl.Color = .{ 240, 240, 240, 255 };
const COLOR_TEXT_LABEL: cl.Color = .{ 240, 240, 240, 255 };
const COLOR_TEXT_TIME: cl.Color = .{ 0, 228, 48, 255 };
const COLOR_BLACK: cl.Color = .{ 0, 0, 0, 255 };

// Font IDs
const FONT_ID_REGULAR = 0;
const FONT_ID_DIGITAL = 1; // Let's assume we load a digital-style font

const BORDER_WIDTH: f32 = 2.0;
const LABEL_FONT_SIZE: u16 = 32;
const LABEL_HORIZONTAL_OFFSET: f32 = 32.0;
const LABEL_VERTICAL_OFFSET: f32 = @as(f32, @floatFromInt(LABEL_FONT_SIZE)) / 2.0;

const SCREEN_WIDTH = 1024;
const SCREEN_HEIGHT = 768;

const AppActiveWindow = enum {
    MAIN_MENU,
    QUICK_LINKS,
    SCRIPTS,
};

const AppMainMenuState = struct {
    index: u8,

    pub const default = AppMainMenuState{0};
};

const AppState = struct {
    main_menu: AppMainMenuState,

    pub const default = AppState{AppMainMenuState.default};
};

fn loadFont(file_data: ?[]const u8, font_id: u16, font_size: i32) !void {
    renderer.raylib_fonts[font_id] = try rl.loadFontFromMemory(
        ".ttf",
        file_data,
        font_size * 2,
        null,
    );
    rl.setTextureFilter(
        renderer.raylib_fonts[font_id].?.texture,
        .bilinear,
    );
}

//fn getTasks(allocator: std.mem.Allocator, exeDir: []const u8) !std.json.Parsed(Justfile) {
// const justfile_path = try fs.path.join(allocator, &.{ exeDir, "justfile" });
// defer allocator.free(justfile_path);
// const justfile_json = try fs.cwd().readFileAlloc(allocator, "./src/justfile2.json", 20000);
// defer allocator.free(justfile_json);
// const parsed = try parseJustfile(allocator, justfile_json);
// const recipes = parsed.value.recipes.map.values();

// for (recipes) |recipe| {
//     const name = recipe.name;
//     std.debug.print("recipe name:{s}\n", .{name});
// }
// return parsed;
//}

fn doesProgramExist(allocator: std.mem.Allocator, program: []const u8) !bool {
    const checker: []const u8 = switch (builtin.target.os.tag) {
        .windows => "where",
        else => "which",
    };
    var child_proc = process.Child.init(&.{ checker, program }, allocator);
    child_proc.stdout_behavior = .Ignore;
    child_proc.stderr_behavior = .Ignore;
    const result = try child_proc.spawnAndWait();
    switch (result) {
        .Exited => |code| {
            if (code == 0) {
                return true;
            } else {
                return false;
            }
        },
        else => unreachable,
    }
}

fn runProcess(allocator: mem.Allocator, argv: []const []const u8) !RunResult {
    var child = process.Child.init(argv, allocator);
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    var stdout: std.ArrayListUnmanaged(u8) = .empty;
    defer stdout.deinit(allocator);
    var stderr: std.ArrayListUnmanaged(u8) = .empty;
    defer stderr.deinit(allocator);
    try child.spawn();
    errdefer {
        _ = child.kill() catch {};
    }
    try child.collectOutput(allocator, &stdout, &stderr, 50 * 1024);
    return RunResult{
        .stdout = try stdout.toOwnedSlice(allocator),
        .stderr = try stdout.toOwnedSlice(allocator),
        .term = try child.wait(),
    };
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const exeDir = try fs.selfExeDirPathAlloc(allocator);
    defer allocator.free(exeDir);

    std.log.err("exe dir: {s}", .{exeDir});

    const is_just_installed = try doesProgramExist(allocator, "just");

    if (is_just_installed) {
        std.log.err("Just installed.", .{});
        const justfile_path = try fs.path.join(allocator, &.{ exeDir, "justfile" });
        defer allocator.free(justfile_path);
        std.log.err("Justfile location:  {s}", .{justfile_path});
        const child = try runProcess(allocator, &.{ "just", "--dump", "--dump-format", "json", "-f", justfile_path });
        defer allocator.free(child.stdout);
        defer allocator.free(child.stderr);
        switch (child.term) {
            .Exited => |code| {
                if (code == 0) {
                    //std.log.err("msg: {s}", .{child.stdout});
                    var parsed = try json.parseFromSlice(json.Value, allocator, child.stdout, .{});
                    defer parsed.deinit();
                    var root = parsed.value;
                    const recipes = root.object.get("recipes");
                    if (recipes) |r| {
                        const recipe_values = r.object.values();
                        for (recipe_values) |recipe| {
                            const name = recipe.object.get("name");
                            if (name) |recipe_name| {
                                if (!std.mem.startsWith(u8, recipe_name.string, "_")) {
                                    std.log.err("recipe name: {s}", .{recipe_name.string});
                                }
                            }
                        }
                    }
                }
            },
            .Signal => return error.Signal,
            .Stopped => return error.Stopped,
            .Unknown => return error.Unknown,
        }
    } else {
        std.log.err("Just not installed.", .{});
    }

    //const allocator = std.heap.page_allocator;

    // --- Initialize Clay ---
    const min_memory_size: u32 = cl.minMemorySize();
    const memory = try allocator.alloc(u8, min_memory_size);
    defer allocator.free(memory);
    const arena = cl.createArenaWithCapacityAndMemory(memory);
    _ = cl.initialize(arena, .{ .h = 800, .w = 600 }, .{});
    cl.setMeasureTextFunction(void, {}, renderer.measureText);

    // --- Initialize Raylib ---
    rl.setConfigFlags(.{
        .msaa_4x_hint = true,
        .window_resizable = true,
        //.fullscreen_mode = true,
    });
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Quick Launcher");
    rl.setWindowMinSize(SCREEN_WIDTH, SCREEN_HEIGHT);
    rl.setTargetFPS(15);
    //rl.enableEventWaiting();

    // --- Load Assets ---
    // Using default font for simplicity
    //renderer.raylib_fonts[FONT_ID_REGULAR] = rl.getFontDefault();
    //renderer.raylib_fonts[FONT_ID_DIGITAL] = rl.getFontDefault();
    try loadFont(@embedFile("./resources/Roboto-Regular.ttf"), 0, 24);

    // --- Main Loop ---
    while (!rl.windowShouldClose()) {
        if (!rl.isWindowFullscreen()) {
            const display = rl.getCurrentMonitor();
            rl.setWindowSize(rl.getMonitorWidth(display), rl.getMonitorHeight(display));
            cl.setLayoutDimensions(.{
                .w = @floatFromInt(rl.getMonitorWidth(display)),
                .h = @floatFromInt(rl.getMonitorHeight(display)),
            });
            rl.toggleFullscreen();
        }

        if (rl.isKeyDown(.s)) {
            rl.takeScreenshot("screenshot.jpg");
        }

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        var render_commands = createLayout();
        try renderer.clayRaylibRender(&render_commands, allocator);
    }

    // --- Cleanup ---
    rl.closeWindow();
}

fn createLayout() cl.ClayArray(cl.RenderCommand) {
    // --- Create Layout ---
    cl.beginLayout();
    ClayUI.element(
        .{
            .id = .ID("RootContainer"),
            .layout = .{
                .direction = .left_to_right,
                .sizing = .{
                    .w = .percent(1.0),
                    .h = .percent(1.0),
                },
                .padding = .all(12),
                .child_alignment = .{
                    .x = .left,
                    .y = .top,
                },
                .child_gap = 16,
            },
            .background_color = .{ 0, 0, 0, 255 },
        },
    ).content(createLayoutInner);

    return cl.endLayout();
}

fn createLayoutInner() void {
    lhs();
    rhs();
}

fn lhs() void {
    cl.UI()(.{
        .id = .ID("lhs"),
        .layout = .{
            .direction = .top_to_bottom,
            .sizing = .{
                .w = .percent(0.33),
                .h = .grow,
            },
            .child_gap = 32,
        },
    })({
        fieldset(1, "Selection", "[1] Selection", previousPane);
        fieldset(2, "Quick Launch", "[2] QuickLaunch", quickLaunchPane);
        fieldset(3, "Scripts", "[3] Scripts", scriptsPane);
    });
}

fn rhs() void {
    cl.UI()(.{
        .id = .ID("rhs"),
        .layout = .{
            .direction = .top_to_bottom,
            .sizing = .{
                .w = .percent(0.67),
                .h = .grow,
            },
        },
    })({
        fieldset(4, "Main Menu", "[4] Main Menu", mainPane);
    });
}

fn previousPane() void {
    cl.UI()(.{
        .id = .ID("PreviousPane"),
        .layout = .{
            .sizing = .grow,
            .child_alignment = .center,

            .padding = .{ .top = LABEL_FONT_SIZE },
        },
    })({
        cl.text("08 : 48 : 23", .{
            .font_id = FONT_ID_REGULAR,
            .font_size = 72,
            .color = COLOR_TEXT_TIME,
        });
    });
}

fn quickLaunchPane() void {
    cl.UI()(.{
        .id = .ID("QuickLaunch"),
        .layout = .{
            .sizing = .grow,
            .child_alignment = .center,

            .padding = .{ .top = LABEL_FONT_SIZE },
        },
    })({
        cl.text("", .{
            .font_id = FONT_ID_REGULAR,
            .font_size = 72,
            .color = COLOR_TEXT_TIME,
        });
    });
}

fn scriptsPane() void {
    cl.UI()(.{
        .id = .ID("ScriptsPane"),
        .layout = .{
            .sizing = .grow,
            .child_alignment = .center,

            .padding = .{ .top = LABEL_FONT_SIZE },
        },
    })({
        cl.text("", .{
            .font_id = FONT_ID_REGULAR,
            .font_size = 72,
            .color = COLOR_TEXT_TIME,
        });
    });
}

fn fieldset(id: u32, title: []const u8, fieldset_title: []const u8, content: fn () void) void {
    cl.UI()(.{
        .id = .IDI("DayTimeClockPanel", id),
        .layout = .{
            .direction = .top_to_bottom,
            .sizing = .grow,
            .padding = .all(15),
            .child_gap = 10,
            .child_alignment = .{ .x = .left, .y = .top },
        },
        .background_color = COLOR_BLACK,
        .corner_radius = .all(10),
        .border = .{
            .width = .outside(@intFromFloat(BORDER_WIDTH)),
            .color = COLOR_BORDER,
        },
    })({
        cl.UI()(.{
            .id = .IDI("FloatingLabelContainer", id),
            .layout = .{
                .sizing = .grow,
                .padding = .{ .left = 5, .right = 5 },
            },

            .background_color = COLOR_BLACK,
            .floating = .{
                .attach_to = .to_parent,
                .attach_points = .{
                    .element = .left_top,
                    .parent = .left_top,
                },
                .offset = .{
                    .x = LABEL_HORIZONTAL_OFFSET,
                    .y = -LABEL_VERTICAL_OFFSET,
                },
                .zIndex = 1,
            },
        })({
            _ = title;
            cl.text(fieldset_title, .{
                .font_id = FONT_ID_REGULAR,
                .font_size = LABEL_FONT_SIZE,
                .color = COLOR_TEXT_LABEL,
            });
        });

        content();
    });
}
