const cl = @import("zclay");

// Define Colors (using Clay's Color type [4]f32)
pub const COLOR_PANEL_BACKGROUND: cl.Color = .{ 61, 26, 5, 255 }; // Brownish background
pub const COLOR_BORDER: cl.Color = .{ 240, 240, 240, 255 }; // White-ish border
pub const COLOR_TEXT_LABEL: cl.Color = .{ 240, 240, 240, 255 }; // White-ish for label
pub const COLOR_TEXT_TIME: cl.Color = .{ 0, 228, 48, 255 }; // Bright Green
pub const COLOR_BLACK: cl.Color = .{ 0, 0, 0, 255 };

// Font IDs
pub const FONT_ID_REGULAR = 0;
pub const FONT_ID_DIGITAL = 1; // Let's assume we load a digital-style font

// Constants for floating label effect
pub const BORDER_WIDTH: f32 = 2.0;
pub const LABEL_FONT_SIZE: u16 = 32;
pub const LABEL_HORIZONTAL_OFFSET: f32 = 32.0; // How far inset from the left the label starts
// Vertical offset to make label sit on the border (approx half font size)
pub const LABEL_VERTICAL_OFFSET: f32 = @as(f32, @floatFromInt(LABEL_FONT_SIZE)) / 2.0;

pub const SCREEN_WIDTH = 1024;
pub const SCREEN_HEIGHT = 768;
