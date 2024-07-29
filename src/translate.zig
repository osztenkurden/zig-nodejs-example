// SPDX-FileCopyrightText: 2021 Coil Technologies, Inc
//
// SPDX-License-Identifier: Apache-2.0

// References:
// https://github.com/staltz/zig-nodejs-example
// https://github.com/tigerbeetledb/tigerbeetle-node

// Fix error: parameter of type 'fn' must be declared comptime
// https://stackoverflow.com/questions/74251650/how-to-pass-zig-function-pointers-to-other-functions
// Starting with 0.10, there are 2 ways to pass a function as an argument:
// As a function body. Must be comptime-known.
// As a function pointer.

const std = @import("std");
const assert = std.debug.assert;

const napi_opaque_struct = extern opaque {};

pub const napi_env = *napi_opaque_struct;
pub const napi_value = *napi_opaque_struct;
pub const napi_callback_info = *napi_opaque_struct;
pub const napi_callback = *napi_opaque_struct;


extern fn napi_create_function(
    env: napi_env,
    utf8name: [*c]const u8,
    length: usize,
    cb: *const fn (env: napi_env, info: napi_callback_info) callconv(.C) ?napi_value,
    data: ?*anyopaque,
    result: *napi_value
) i32;

extern fn napi_throw_error(
    env: napi_env,
    code: [*c]const u8,
    msg: [*c]const u8
) i32;

extern fn napi_set_named_property(
    env: napi_env,
    object: napi_value,
    utf8name: [*c]const u8,
    value: napi_value
) i32;


extern fn napi_create_string_utf8(
    env: napi_env,
    str: [*c]const u8,
    length: usize,
    result: *napi_value
) i32;






const TranslationError = error{ExceptionThrown};
pub fn throw(env: napi_env, comptime message: [:0]const u8) TranslationError {
    const result = napi_throw_error(env, null, message);
    switch (result) {
        0, 10 => {},
        else => unreachable,
    }

    return TranslationError.ExceptionThrown;
}




pub fn register_function(
    env: napi_env,
    exports: napi_value,
    comptime name: [:0]const u8,
    comptime function: fn (env: napi_env, info: napi_callback_info) callconv(.C) ?napi_value,
) !void {
    var napi_function: napi_value = undefined;
    if (napi_create_function(env, null, 0, function, null, &napi_function) != 0) {
        return throw(env, "Failed to create function " ++ name ++ "().");
    }

    if (napi_set_named_property(env, exports, name, napi_function) !=  0) {
        return throw(env, "Failed to add " ++ name ++ "() to exports.");
    }
}

pub fn create_string(env: napi_env, value: [:0]const u8) !napi_value {
    var result: napi_value = undefined;
    if (napi_create_string_utf8(env, value, value.len, &result) !=  0) {
        return throw(env, "Failed to create string");
    }

    return result;
}
