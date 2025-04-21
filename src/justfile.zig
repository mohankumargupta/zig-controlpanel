//src/justfile.zig
const std = @import("std");
const json = std.json;
const parseFromSlice = std.json.parseFromSlice;

pub const Justfile = struct {
    recipes: std.json.ArrayHashMap(Recipe),
};

pub const Recipe = struct {
    name: []const u8,
    //parameters: []Parameter,
};

pub const Parameter = struct {
    name: []const u8,
    default: []const u8,
};

pub fn parseJustfile(allocator: std.mem.Allocator, contents: []const u8) !std.json.Parsed(Justfile) {
    const parsed = try parseFromSlice(
        Justfile,
        allocator,
        contents,
        .{
            .ignore_unknown_fields = true,
            .allocate = .alloc_always,
        },
    );
    return parsed;
    //defer parsed.deinit();
    //var root = parsed.value;
    //const recipes = root.recipes.map.values();
    //return recipes;
}

pub fn deinit(parsed: json.Parsed(Justfile)) void {
    parsed.deinit();
}
