const std = @import("std");

const Node = struct {
    previous: ?*Node,
    data: [*:0]const u8,
    next: ?*Node,

    pub fn new(data: [*:0]const u8) Node {
        return Node{ .previous = null, .data = data, .next = null };
    }
};

pub fn count_length(pointer: [*:0]const u8) u32 {
    var sentinel = std.meta.sentinel(@TypeOf(pointer));
    var i: u32 = 0;
    while(pointer[i] != sentinel){
        i += 1;
    }
    return i;
}

pub fn compare_str(a: [*:0]const u8, b: [*:0]const u8) bool{
    var a_len = count_length(a);
    var b_len = count_length(b);
    if(a_len != b_len){
        return false;
    }
    return std.mem.eql(u8, a[0..a_len], b[0..b_len]); 
}

const List = struct {
    head: ?*Node,
    tail: ?*Node,

    pub fn new() List {
        return List{
            .head = null,
            .tail = null,
        };
    }

    pub fn find(self: *List, data: [*:0]const u8) ?Node {
        var node = self.head;
        while (node != null) : (node = node.?.next) {
            if(compare_str(data, node.?.data)){
                return node.?.*;
            }
            
        }
        return null;
    }

    pub fn insert(self: *List, node: *Node) void {
        // first case: empty
        if (self.head == null) {
            self.head = node;
            self.tail = node;
            return;
        }

        if (self.tail) |tail| {
            tail.next = node;
            node.previous = tail;
        }
        self.tail = node;
    }

    pub fn delete(self: *List, data: [*:0]const u8) bool {
        if(self.head == null) return false;
        var node = self.head;
        if(compare_str(node.?.data, data)){
            self.head = node.?.next;
            if(self.head != null){
                self.head.?.previous = null;
            }
            else {
                self.tail = null;
            }
            return true;
        }
        while(node != null) : (node = node.?.next){
            if(compare_str(data, node.?.data)){
                node.?.previous.?.next = node.?.next;
                if(node.?.next != null){
                    node.?.next.?.previous = node.?.previous;
                }
                else {
                    self.tail = node.?.previous;
                }
                return true;
            }
        }
        return false;

    }

    pub fn print(self: *List) void {
        var node = self.head;
        std.debug.print("\nCurrent contents of LinkedList: ", .{});
        while (node != null) : (node = node.?.next) {
            std.debug.print("\nNode [{s}]", .{node.?.data});
        }
    }

    pub fn print_reverse(self: *List) void {
        var node = self.tail;
        std.debug.print("\nCurrent contents of LinkedList in reverse: ", .{});
        while (node != null) : (node = node.?.previous) {
            std.debug.print("\nNode [{s}]", .{node.?.data});
        }
    }
};

pub fn main() !void {
    std.debug.print("\nexpect true: {}", .{compare_str("hello", "hello")});
    std.debug.print("\nexpect false: {}", .{compare_str("true","brue")});
    var list = List.new();
    var node = Node.new("hello");
    list.insert(&node);
    var node2 = Node.new("test");
    list.insert(&node2);
    var node3 = Node.new("wowzers");
    list.insert(&node3);
    var found = list.find("wowzers");
    std.debug.print("\nFound node: {s}", .{found.?.data});
    list.print();
    list.print_reverse();
    // _ = list.delete("hello");
    _ = list.delete("test");
    // _ = list.delete("wowzers");
    std.debug.print("\nDeleted test", .{});
    list.print();
    list.print_reverse();
}

test "insert" {
    var list = List.new();
    var node = Node.new("hello");
    list.insert(&node);
    try std.testing.expect(list.find("hello") != null);
    var node2 = Node.new("test");
    list.insert(&node2);
    try std.testing.expect(list.find("test") != null);
    try std.testing.expect(list.head.? == &node);
    try std.testing.expect(list.tail.? == &node2);
}

test "find" {
    var list = List.new();
    var node = Node.new("hello");
    list.insert(&node);
    try std.testing.expect(list.find("hello") != null);
    var node2 = Node.new("test");
    list.insert(&node2);
    try std.testing.expect(list.find("test") != null);
    try std.testing.expect(list.find("world") == null);
}

test "delete"{
    var list = List.new();
    var list2 = List.new();
    var list3 = List.new();

    var node = Node.new("hello");
    var node2 = Node.new("world");
    var node3 = Node.new("tweet");

    var deleted = list.delete("random");
    try std.testing.expect(!deleted);

    list.insert(&node);
    deleted = list.delete("hello");

    try std.testing.expect(deleted);
    try std.testing.expect(list.head == null);
    try std.testing.expect(list.tail == null);

    list2.insert(&node);
    list2.insert(&node2);
    deleted = list2.delete("hello");
    try std.testing.expect(deleted);
    try std.testing.expect(list2.head.? == &node2);
    try std.testing.expect(list2.tail.? == &node2);
    
    list3.insert(&node);
    list3.insert(&node2);
    list3.insert(&node3);
    deleted = list3.delete("world");
    try std.testing.expect(deleted);
    try std.testing.expect(list3.head.? == &node);
    try std.testing.expect(list3.tail.? == &node3);

}
