const std = @import("std");
const print = std.log.info;
const expect = std.testing.expect;

var global_var: i32 = 345;
const global_const: i32 = 84;
pub fn main() anyerror!void {

    // The Zig standard library also has a general purpose allocator. This is a safe allocator which can prevent double-free, use-after-free and can detect leaks. Safety checks and thread safety can be turned off via its configuration struct (left empty below). Zig’s GPA is designed for safety over performance, but may still be many times faster than page_allocator.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();

    var array_in_heap: []i32 = try alloc.alloc(i32, 3);
    array_in_heap[0] = 31;
    print("arr {any}", .{array_in_heap});
}

// an allocation of a single byte will likely reserve multiple kibibytes. As asking the OS for memory requires a system call this is also extremely inefficient for speed.
test "page allocator" {
    const allocator = std.heap.page_allocator;

    const memory = try allocator.alloc(u8, 100);

    defer allocator.free(memory);

    try expect(memory.len == 100);
    try expect(@TypeOf(memory) == []u8);

    var i: u8 = 0;

    while (i < 80) {
        memory[i] = i;
        i += 1;
    }
    print("{any}", .{memory});
    try expect(memory[0] == 0);
}

// is an allocator that allocates memory into a fixed buffer, and does not make any heap allocations.
test "fixed buffer alloc" {
    var buffer: [1000]u8 = undefined;

    var fba = std.heap.FixedBufferAllocator.init(&buffer);

    const allocator = fba.allocator();

    const memory = try allocator.alloc(u8, 100);
    defer allocator.free(memory);
    try expect(memory.len == 100);
}

// take children allocator, and allocate repeatedly, and can free all memory all at once
test "arena allocator" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit(); // free all
    const allocator = arena.allocator();

    _ = try allocator.alloc(u8, 1);
    _ = try allocator.alloc(u8, 10);
    _ = try allocator.alloc(u8, 100);
}

// alloc and free are used for slices. For single items, consider using create and destroy.
test "create/destroy" {
    const byte = try std.heap.page_allocator.create(u8);
    defer std.heap.page_allocator.destroy(byte);
    byte.* = 128;
}



test "arrayList" {
     var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit(); // free all
    const allocator = arena.allocator();


    var List = std.ArrayList(i32).init(allocator);
    defer List.deinit();
    try List.append(1);
   try List.append(2);
    try List.append(3);
    try List.append(4);
    for(List.items) |val|{
        
     std.log.info("{any}", .{val});
    }
}