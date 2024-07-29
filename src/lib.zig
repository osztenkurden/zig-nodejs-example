const std = @import("std");
const assert = std.debug.assert;
const translate = @import("translate.zig");

// Declare the struct as an opaque type in Zig

// Create a type alias for the pointer to the struct

export fn napi_register_module_v1(env: translate.napi_env, exports: translate.napi_value) ?translate.napi_value {
    translate.register_function(env, exports, "greet", greet) catch return null;
    return exports;
}

fn greet(env: translate.napi_env, info: translate.napi_callback_info) callconv(.C) ?translate.napi_value {
    _ = info;
    return translate.create_string(env, "world") catch return null;
}
