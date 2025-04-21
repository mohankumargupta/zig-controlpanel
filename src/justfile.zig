const std = @import("std");
const parseFromSlice = std.json.parseFromSlice;

const Justfile = struct {
    recipes: std.json.ArrayHashMap(Recipe),
};

pub const Recipe = struct {
    name: []const u8,
    parameters: []Parameter,
};

pub const Parameter = struct {
    name: []const u8,
    default: ?[]const u8,
};

pub fn parseJustfile(allocator: std.mem.Allocator, contents: []const u8) ![]const Recipe {
    var parsed = try parseFromSlice(Justfile, allocator, contents, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();
    var root = parsed.value;
    const recipes = root.recipes.map.values();
    return recipes;
}
