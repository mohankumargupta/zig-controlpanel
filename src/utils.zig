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

test "try hashmap" {
    const justfile =
        \\{
        \\    "recipes": {
        \\        "step1": {
        \\            "name": "Boo"
        \\        },
        \\        "step2": {
        \\            "name": "Moo"
        \\        }
        \\    }
        \\}
    ;

    var parsed = try parseFromSlice(std.json.Value, testing.allocator, justfile, .{});
    defer parsed.deinit();
    var root = parsed.value;
    const recipes = root.object.get("recipes").?.object;
    const keys = recipes.keys();
    try std.testing.expectEqual(keys.len, 2);
    const expected = [_][]const u8{ "Boo", "Moo" };
    for (keys, 0..) |key, index| {
        const recipe = recipes.get(key);
        const recipe_name = recipe.?.object.get("name").?.string;
        try std.testing.expectEqualSlices(u8, recipe_name, expected[index]);
    }
}

test "try struct" {
    const justfile =
        \\{
        \\    "recipes": {
        \\        "step1": {
        \\            "name": "Boo"
        \\        },
        \\        "step2": {
        \\            "name": "Moo"
        \\        }
        \\    }
        \\}
    ;

    const Recipe = struct {
        name: []const u8,
    };

    const Justfile = struct {
        recipes: std.json.ArrayHashMap(Recipe),
    };

    var parsed = try parseFromSlice(Justfile, testing.allocator, justfile, .{});
    defer parsed.deinit();
    var root = parsed.value;
    const recipe_name = root.recipes.map.get("step1").?.name;
    try std.testing.expectEqualSlices(u8, "Boo", recipe_name);
}
