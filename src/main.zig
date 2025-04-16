// src/main.zig
const std = @import("std");
const rl = @import("raylib");
const cl = @import("zclay");
const renderer = @import("raylib_render_clay.zig");

// Define Colors (using Clay's Color type [4]f32)
const COLOR_PANEL_BACKGROUND: cl.Color = .{ 61, 26, 5, 255 }; // Brownish background
const COLOR_BORDER: cl.Color = .{ 240, 240, 240, 255 }; // White-ish border
const COLOR_TEXT_LABEL: cl.Color = .{ 240, 240, 240, 255 }; // White-ish for label
const COLOR_TEXT_TIME: cl.Color = .{ 0, 228, 48, 255 }; // Bright Green

// Font IDs
const FONT_ID_REGULAR = 0;
const FONT_ID_DIGITAL = 1; // Let's assume we load a digital-style font

// Constants for floating label effect
const BORDER_WIDTH: f32 = 2.0;
const LABEL_FONT_SIZE: u16 = 16;
const LABEL_HORIZONTAL_OFFSET: f32 = 15.0; // How far inset from the left the label starts
// Vertical offset to make label sit on the border (approx half font size)
const LABEL_VERTICAL_OFFSET: f32 = @as(f32, @floatFromInt(LABEL_FONT_SIZE)) / 2.0;

const SCREEN_WIDTH = 1024;
const SCREEN_HEIGHT = 768;

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

fn leftContainer() void {
    // --- Time Container ---
    // This remains inside the normal layout flow of the panel
    cl.UI()(.{
        .id = .ID("TimeTextContainer"),
        .layout = .{
            .sizing = .grow, // Take remaining space *within the padded area*
            .child_alignment = .center, // Center the text element inside
            // Add top padding to push time down below the floating label area
            // We need to account for the panel's top padding (15) and roughly the label height (16)
            .padding = .{ .top = LABEL_FONT_SIZE },
        },
    })({
        // Time Text
        cl.text("08 : 48 : 23", .{
            .font_id = FONT_ID_REGULAR,
            .font_size = 72,
            .color = COLOR_TEXT_TIME,
        });
    }); // End TimeTextContainer

}

fn fieldset(content: fn () void) void {
    // --- Day Time Clock Panel ---
    cl.UI()(.{
        .id = .ID("DayTimeClockPanel"),
        .layout = .{
            .direction = .top_to_bottom,
            .sizing = .{ .w = .fixed(350), .h = .fixed(150) },
            .padding = .all(15),
            .child_gap = 10,
            .child_alignment = .{ .x = .center, .y = .top },
        },
        .background_color = COLOR_PANEL_BACKGROUND,
        .corner_radius = .all(10),
        .border = .{
            // Use the BORDER_WIDTH constant
            .width = .outside(@intFromFloat(BORDER_WIDTH)),
            .color = COLOR_BORDER,
        },
    })({
        // // --- Floating Label Container ---
        // // This container holds the text and uses 'floating' to position it
        cl.UI()(.{
            .id = .ID("FloatingLabelContainer"),
            .layout = .{
                .sizing = .fit, // Size to fit the text inside + padding
                .padding = .{ .left = 5, .right = 5 }, // Padding around the text
            },
            // Make background same as panel to obscure the border underneath
            .background_color = COLOR_PANEL_BACKGROUND,
            .floating = .{
                .attach_to = .to_parent, // Attach relative to DayTimeClockPanel
                .attach_points = .{
                    .element = .left_top, // Attach using the top-left of this label container
                    .parent = .left_top, // Attach relative to the top-left of the parent panel
                },
                .offset = .{ // Adjust position
                    .x = LABEL_HORIZONTAL_OFFSET, // Move right
                    .y = -LABEL_VERTICAL_OFFSET, // Move up to sit on the border
                },
                .zIndex = 1, // Ensure it's drawn above the border
            },
        })({
            //The actual Label Text
            cl.text("Day Time Clock", .{
                .font_id = FONT_ID_REGULAR,
                .font_size = LABEL_FONT_SIZE,
                .color = COLOR_TEXT_LABEL,
            });
        }); // End FloatingLabelContainer

        content();
    });
}

fn createLayout() cl.ClayArray(cl.RenderCommand) {
    // --- Create Layout ---
    cl.beginLayout();

    // Root container
    cl.UI()(.{
        .id = .ID("RootContainer"),
        .layout = .{ .sizing = .grow, .child_alignment = .center },
        .background_color = .{ 20, 20, 20, 255 },
    })({
        // End DayTimeClockPanel
        fieldset(leftContainer);
    }); // End RootContainer

    return cl.endLayout();
}

// --- Main Application Logic ---
pub fn main() !void {
    //const allocator = std.heap.page_allocator;
    const allocator = std.heap.page_allocator;

    // --- Initialize Clay ---
    const min_memory_size: u32 = cl.minMemorySize();
    const memory = try allocator.alloc(u8, min_memory_size);
    defer allocator.free(memory);
    const arena = cl.createArenaWithCapacityAndMemory(memory);
    _ = cl.initialize(arena, .{ .h = 1024, .w = 800 }, .{});
    cl.setMeasureTextFunction(void, {}, renderer.measureText);

    // --- Initialize Raylib ---
    rl.setConfigFlags(.{
        .msaa_4x_hint = true,
        .window_resizable = true,
    });
    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Quick Launcher");
    rl.setWindowMinSize(200, 100);
    rl.setTargetFPS(60);

    // --- Load Assets ---
    // Using default font for simplicity
    //renderer.raylib_fonts[FONT_ID_REGULAR] = rl.getFontDefault();
    //renderer.raylib_fonts[FONT_ID_DIGITAL] = rl.getFontDefault();
    try loadFont(@embedFile("./resources/Roboto-Regular.ttf"), 0, 24);

    // --- Main Loop ---
    while (!rl.windowShouldClose()) {
        // --- Update ---
        const screen_width = rl.getScreenWidth();
        const screen_height = rl.getScreenHeight();
        cl.setLayoutDimensions(.{
            .w = @floatFromInt(screen_width),
            .h = @floatFromInt(screen_height),
        });

        // --- Draw ---
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        var render_commands = createLayout();
        try renderer.clayRaylibRender(&render_commands, allocator);
    }

    // --- Cleanup ---
    rl.closeWindow();
}
