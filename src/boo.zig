const std = @import("std");

const Step = struct {
    name: []const u8,

    // jsonParse function required for std.json.readFromSlice
    pub fn jsonParse(
        alloc: std.mem.Allocator,
        stream: *std.json.TokenStream,
        comptime T: type,
    ) !T {
        //_ = T; // T is always Step here
        var object_stream = try stream.objectStream();
        var name: []const u8 = undefined;
        var found_name = false;

        // Iterate through the key-value pairs in the object ({ "name": "..." })
        while (try object_stream.next()) |key| {
            if (std.mem.eql(u8, key, "name")) {
                // Read the value for the "name" key as a string
                name = try stream.string(alloc);
                found_name = true;
            } else {
                // Skip any unknown fields
                try stream.skipValue();
            }
        }

        // Check if the required "name" field was found
        if (!found_name) {
            return error.MissingNameField;
        }

        // Return the populated struct
        return Step{ .name = name };
    }

    // Add a deinit if Step contained allocated memory, although []const u8 doesn't own memory here.
    // pub fn deinit(self: *Step, alloc: std.mem.Allocator) void {
    //    // if (self.name != null) alloc.free(self.name); // If name was copied/allocated
    // }
};

// Helper function to parse the inner "recipes" object into a StringHashMap<Step>
fn parseStepsMap(
    alloc: std.mem.Allocator,
    stream: *std.json.TokenStream,
) !std.StringHashMap(Step) {
    // Initialize the hash map that will store the steps
    var map = std.StringHashMap(Step).init(alloc);
    // Ensure map is deinitialized if an error occurs during parsing
    errdefer map.deinit();

    // Get a stream to iterate over the key-value pairs of the current object ({ "step1": {...}, "step2": {...} })
    var object_stream = try stream.objectStream();

    // Iterate through each key ("step1", "step2", etc.) in the object
    while (try object_stream.next()) |step_key_slice| {
        // The key slice needs to be copied because StringHashMap requires owned keys by default.
        // The map will own this copied key.
        const step_key_copy = try alloc.dupe(u8, step_key_slice);
        // Ensure the copied key is freed if parsing the value fails before it's put into the map
        errdefer alloc.free(step_key_copy);

        // Parse the value associated with the key as a Step struct
        const step_value = try stream.parse(Step, alloc);
        // If Step struct needed deinitialization (e.g., owned strings), add errdefer here
        // errdefer step_value.deinit(&alloc);

        // Put the copied key and the parsed step value into the map.
        // The map takes ownership of step_key_copy upon success.
        try map.put(step_key_copy, step_value);
        // If put succeeded, the errdefer alloc.free(step_key_copy) is skipped.
    }

    // Return the fully populated map
    return map;
}

const RecipeRoot = struct {
    recipes: std.StringHashMap(Step),

    // jsonParse function required for std.json.readFromSlice
    pub fn jsonParse(
        alloc: std.mem.Allocator,
        stream: *std.json.TokenStream,
        comptime T: type,
    ) !T {
        //_ = T; // T is always RecipeRoot here
        var object_stream = try stream.objectStream();
        var recipes_map: std.StringHashMap(Step) = undefined; // This will be initialized by parseStepsMap

        var found_recipes = false;

        // Iterate through the key-value pairs in the root object ({ "recipes": {...} })
        while (try object_stream.next()) |key| {
            if (std.mem.eql(u8, key, "recipes")) {
                // Found the "recipes" key, now parse its value using the helper function
                recipes_map = try parseStepsMap(alloc, stream);
                found_recipes = true;
            } else {
                // Skip any unknown fields in the root object
                try stream.skipValue();
            }
        }

        // Check if the required "recipes" field was found
        if (!found_recipes) {
            return error.MissingRecipesField;
        }

        // Return the populated struct
        return RecipeRoot{ .recipes = recipes_map };
    }

    // Deinitialization function for RecipeRoot
    pub fn deinit(self: *RecipeRoot) void {
        // StringHashMap deinit frees all owned keys and calls value deinit if the value type has one.
        self.recipes.deinit();
    }
};

const json_string =
    \\{
    \\  "recipes": {
    \\   "step1": {
    \\      "name": "Boo"
    \\   },
    \\   "step2": {
    \\      "name": "Moo"
    \\   }
    \\
    \\  }
    \\}
;

pub fn main() anyerror!void {
    // Use the page allocator for dynamic memory needed by the parser and structs
    var allocator = std.heap.page_allocator;

    // Create a token stream from the JSON string slice
    var stream = std.json.TokenStream.init(json_string);
    // Ensure the token stream is deinitialized
    defer stream.deinit();

    // Use stream.parse to read the JSON into our defined RecipeRoot struct
    // This calls RecipeRoot.jsonParse internally
    var parsed_data = try stream.parse(RecipeRoot, allocator);
    // Ensure the parsed data (specifically the StringHashMap) is deinitialized
    defer parsed_data.deinit(&allocator);

    std.debug.print("Successfully parsed JSON:\n", .{});

    // Iterate through the steps stored in the StringHashMap
    var iterator = parsed_data.recipes.iterator();
    while (iterator.next()) |entry| {
        // Print the step key (e.g., "step1") and the step name (e.g., "Boo")
        std.debug.print("  Step '{}': name='{}'\n", .{ entry.key_ptr.*, entry.value_ptr.*.name });
    }
}

// Define custom errors used in jsonParse functions
const JsonParseErrors = error{
    MissingNameField,
    MissingRecipesField,
};
