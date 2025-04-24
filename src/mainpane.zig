const cl = @import("zclay");
const LABEL_FONT_SIZE = @import("constants.zig").LABEL_FONT_SIZE;
const FONT_ID_REGULAR = @import("constants.zig").FONT_ID_REGULAR;
const COLOR_TEXT_TIME = @import("constants.zig").COLOR_TEXT_TIME;

pub fn mainPane() void {
    // --- Time Container ---
    // This remains inside the normal layout flow of the panel
    cl.UI()(.{
        .id = .ID("MainPane"),
        .layout = .{
            .sizing = .grow, // Take remaining space *within the padded area*
            .child_alignment = .{ .x = .left, .y = .top }, // Center the text element inside
            // Add top padding to push time down below the floating label area
            // We need to account for the panel's top padding (15) and roughly the label height (16)
            .padding = .{ .top = LABEL_FONT_SIZE },
        },
    })({
        cl.UI()(
            .{
                .layout = .{
                    .direction = .top_to_bottom,
                    .sizing = .{ .w = .grow, .h = .grow },
                    .child_alignment = .{ .x = .center, .y = .top },
                    .child_gap = 32,
                },
            },
        )({
            cl.text("Quick Launch", .{
                .font_id = FONT_ID_REGULAR,
                .font_size = 72,
                .color = COLOR_TEXT_TIME,
            });

            cl.UI()(
                .{
                    .layout = .{
                        .direction = .left_to_right,
                        .sizing = .{ .w = .grow, .h = .grow },
                        .padding = .{
                            .left = 64,
                            .right = 64,
                            .top = 64,
                            .bottom = 128,
                        },
                    },
                },
            )({
                cl.UI()(
                    .{
                        .layout = .{
                            .direction = .top_to_bottom,
                            .sizing = .{ .w = .grow, .h = .grow },
                            .child_alignment = .center,
                            .child_gap = 16,
                        },
                        .border = .{
                            .color = .{ 0, 0, 240, 255 },
                            .width = .all(2),
                        },
                    },
                )({
                    cl.UI()(
                        .{
                            .layout = .{
                                .direction = .top_to_bottom,
                                .sizing = .{ .w = .grow, .h = .grow },
                                .padding = .all(64),
                                .child_alignment = .center,
                                .child_gap = 32,
                            },
                        },
                    )({
                        cl.UI()(
                            .{
                                .layout = .{
                                    .direction = .top_to_bottom,
                                    .sizing = .{ .w = .grow, .h = .grow },
                                    .child_alignment = .{ .x = .left, .y = .top },
                                    .child_gap = 24,
                                },
                            },
                        )({
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
                            cl.text("C) Something", .{
                                .font_id = FONT_ID_REGULAR,
                                .font_size = 72,
                                .color = COLOR_TEXT_TIME,
                            });
                        });
                    });
                });

                // cl.UI()(
                //     .{
                //         .layout = .{
                //             .direction = .left_to_right,
                //             .sizing = .{ .w = .percent(0.8), .h = .grow },
                //         },
                //     },
                // )({
                //     cl.text("LHS", .{
                //         .font_id = FONT_ID_REGULAR,
                //         .font_size = 72,
                //         .color = COLOR_TEXT_TIME,
                //     });
                // });
                // cl.UI()(
                //     .{
                //         .layout = .{
                //             .direction = .left_to_right,
                //             .sizing = .{ .w = .grow, .h = .grow },
                //         },
                //     },
                // )({
                //     cl.text("RHS", .{
                //         .font_id = FONT_ID_REGULAR,
                //         .font_size = 72,
                //         .color = COLOR_TEXT_TIME,
                //     });
                // });

            });
        });
        // Time Text

    }); // End TimeTextContainer

}
