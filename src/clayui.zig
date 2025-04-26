const cl = @import("zclay");

pub const ClayUI = struct {
    config: cl.ElementDeclaration,

    pub fn element(config: cl.ElementDeclaration) ClayUI {
        return ClayUI{ .config = config };
    }

    pub fn content(self: ClayUI, innerContentFn: fn () void) void {
        // cl.UI()(self.config)({ innerContentFn(); })
        cl.UI()(self.config)({
            innerContentFn();
        });
    }
};

// --- Example Usage (within a function like createLayout) ---

// Assuming you have a function like this:
fn createLayoutExample() cl.ClayArray(cl.RenderCommand) {
    cl.beginLayout();

    // Using the original zclay pattern:
    cl.UI()(.{
        .id = cl.ElementId.ID("OriginalPattern"),
        .layout = .{ .padding = .all(10), .sizing = .{ .h = .fixed(100) } },
        .background_color = .{ 200, 200, 220, 255 },
    })({
        cl.text("Text inside original pattern", .{});
    });

    // Using the ClayUI helper struct:
    ClayUI.layout(.{ // Call layout() with the config
        .id = cl.ElementId.ID("HelperPattern"),
        .layout = .{ .padding = .all(10), .sizing = .{ .h = .fixed(100) }, .direction = .top_to_bottom },
        .background_color = .{ 220, 200, 200, 255 },
        .corner_radius = .all(8),
    }).content( // Chain content() with the inner function/block
        \\{ // Using an inline block (anonymous function literal) for content
        \\    cl.text("Text inside helper pattern", .{ .color = cl.COLOR_RED });
        \\    cl.text("Another line", .{});
        \\},
    );

    // Example using a separate named function for content:
    ClayUI.layout(.{
        .id = cl.ElementId.ID("HelperWithFunction"),
        .layout = .{ .padding = .all(5), .sizing = .{ .h = .fixed(50) } },
        .background_color = .{ 200, 220, 200, 255 },
    }).content(addMySpecificContent); // Pass the function name

    return cl.endLayout();
}

// Example content function to be passed to ClayUI.content()
fn addMySpecificContent() void {
    cl.text("Content from a separate function!", .{ .font_size = 12 });
    // Add more complex children here if needed
}

// --- Boilerplate for a minimal runnable example (if needed) ---
// You would need the rest of the main setup (init raylib, init clay, load assets, main loop)
// from the provided examples to make this fully runnable.

// pub fn main() !void {
//     const allocator = std.heap.page_allocator;
//     // ... init clay (memory, arena, initialize, setMeasureTextFunction) ...
//     // ... init raylib (window, fps) ...
//     // ... load assets (fonts) ...
//
//     while (!rl.windowShouldClose()) {
//         // ... handle input (setPointerState, updateScrollContainers) ...
//         // ... set layout dimensions ...
//
//         var render_commands = createLayoutExample(); // Call the layout function
//
//         rl.beginDrawing();
//         rl.clearBackground(rl.Color.white); // Example clear
//         // ... renderer.clayRaylibRender(&render_commands, allocator) ...
//         rl.endDrawing();
//     }
//     // ... deinit ...
// }
