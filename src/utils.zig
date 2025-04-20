//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const parseFromSlice = std.json.parseFromSlice;
const testing = std.testing;

test "struct only needs to partially implement the important bits from json` " {
    const T = struct {
        first: []const u8,
    };

    const justfile =
        \\{
        \\  "aliases": {},
        \\  "assignments": {},
        \\  "first": "buildrun",
        \\  "doc": null,
        \\  "groups": [],
        \\  "modules": {}
        \\} 
    ;
    const parsed = try parseFromSlice(T, testing.allocator, justfile, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();
    try testing.expectEqualSlices(u8, parsed.value.first, "buildrun");
}

test "handle objects" {
    const T = struct {
        recipe: struct {
            build: struct {
                attributes: []const u8,
            },
        },
    };

    const justfile =
        \\{
        \\  "recipe": {
        \\    "build": {
        \\       "attributes": "boo"
        \\    }
        \\  }
        \\} 
    ;
    const parsed = try parseFromSlice(T, testing.allocator, justfile, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();
    try testing.expectEqualSlices(u8, parsed.value.recipe.build.attributes, "boo");
}
