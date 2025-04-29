const cl = @import("zclay");
const ClayUI = @import("clayui.zig").ClayUI;

const LABEL_FONT_SIZE = @import("constants.zig").LABEL_FONT_SIZE;
const FONT_ID_REGULAR = @import("constants.zig").FONT_ID_REGULAR;
const COLOR_TEXT_TIME = @import("constants.zig").COLOR_TEXT_TIME;

pub fn mainPane() void {
    ClayUI.element(
        .{
            .id = .ID("MainPane"),
            .layout = .{
                .direction = .top_to_bottom,
                .sizing = .grow,
                .child_alignment = .{ .x = .left, .y = .top },
                .padding = .{
                    .top = LABEL_FONT_SIZE,
                    .bottom = LABEL_FONT_SIZE,
                    .left = 32,
                    .right = 32,
                },
                //.child_gap = 8,
            },
        },
    ).content(mainPaneInner);
}

fn mainPaneInner() void {
    mainPaneTitle();
    mainPaneMenu();
    mainPaneHelpKeys();
}

fn mainPaneTitle() void {
    ClayUI.element(
        .{
            .layout = .{
                .sizing = .{ .w = .grow },
                .child_alignment = .{
                    .x = .center,
                    .y = .top,
                },
                .padding = .{ .bottom = 32 },
            },
        },
    ).content(mainPaneText);
}

fn mainPaneText() void {
    cl.text("Quick Launch", .{
        .font_id = FONT_ID_REGULAR,
        .font_size = 72,
        .color = COLOR_TEXT_TIME,
    });
}

fn mainPaneMenu() void {
    ClayUI.element(
        .{
            .layout = .{
                .sizing = .{ .w = .grow },
                .padding = .all(32),
            },
            .border = .{
                .color = .{ 0, 0, 240, 255 },
                .width = .all(2),
            },
        },
    ).content(mainPaneMenuInner);
}

fn mainPaneMenuInner() void {
    ClayUI.element(
        .{
            .layout = .{
                .direction = .top_to_bottom,
                .sizing = .{ .w = .grow },
                .child_alignment = .{
                    .x = .left,
                    .y = .top,
                },
                .child_gap = 48,
                .padding = .{ .left = 48 },
            },
        },
    ).content(mainPaneMenuContent);
}

fn mainPaneMenuContent() void {
    cl.text("A) yt-dlp", .{
        .font_id = FONT_ID_REGULAR,
        .font_size = 72,
        .color = COLOR_TEXT_TIME,
    });
    cl.text("B) ffmpeg", .{
        .font_id = FONT_ID_REGULAR,
        .font_size = 72,
        .color = COLOR_TEXT_TIME,
    });
    cl.text("C) something", .{
        .font_id = FONT_ID_REGULAR,
        .font_size = 72,
        .color = COLOR_TEXT_TIME,
    });
}
fn mainPaneHelpKeys() void {
    cl.UI()(.{
        .layout = .{
            .direction = .left_to_right,
            .sizing = .{ .w = .grow },
            .child_alignment = .{
                .x = .left,
                .y = .top,
            },
            .child_gap = 16,
            .padding = .{
                .left = 48,
                .top = 48,
            },
        },
    })({
        cl.text("[F1] Help", .{
            .font_id = FONT_ID_REGULAR,
            .font_size = 24,
            .color = COLOR_TEXT_TIME,
        });
        cl.text("[F10] Quit", .{
            .font_id = FONT_ID_REGULAR,
            .font_size = 24,
            .color = COLOR_TEXT_TIME,
        });
    });
}
