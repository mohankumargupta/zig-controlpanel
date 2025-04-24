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
            .child_alignment = .center, // Center the text element inside
            // Add top padding to push time down below the floating label area
            // We need to account for the panel's top padding (15) and roughly the label height (16)
            .padding = .{ .top = LABEL_FONT_SIZE },
        },
    })({
        // Time Text
        cl.text("This is the main menu", .{
            .font_id = FONT_ID_REGULAR,
            .font_size = 72,
            .color = COLOR_TEXT_TIME,
        });
    }); // End TimeTextContainer

}
