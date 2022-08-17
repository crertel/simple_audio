const zaudio = @import("zaudio.zig");
const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const Mutex = std.Thread.Mutex;

const AudioState = struct {
    const num_sets = 100;
    const samples_per_set = 512;
    const usable_samples_per_set = 480;

    device: zaudio.Device,
    engine: zaudio.Engine,
    mutex: Mutex = .{},
    current_set: u32 = num_sets - 1,
    samples: std.ArrayList(f32),

    fn audioCallback(context: ?*anyopaque, outptr: *anyopaque, num_frames: u32) void {
        if (context == null) return;

        const audio = @ptrCast(*AudioState, @alignCast(@alignOf(AudioState), context));

        audio.engine.readPcmFrames(outptr, num_frames, null) catch {};

        audio.mutex.lock();
        defer audio.mutex.unlock();

        audio.current_set = (audio.current_set + 1) % num_sets;

        const num_channels = 2;
        const base_index = samples_per_set * audio.current_set;
        const frames = @ptrCast([*]f32, @alignCast(@sizeOf(f32), outptr));

        var i: u32 = 0;
        while (i < math.min(num_frames, usable_samples_per_set)) : (i += 1) {
            audio.samples.items[base_index + i] = frames[i * num_channels];
        }
    }

    fn create(allocator: std.mem.Allocator) !*AudioState {
        const samples = samples: {
            var samples = std.ArrayList(f32).initCapacity(
                allocator,
                num_sets * samples_per_set,
            ) catch unreachable;
            samples.expandToCapacity();
            std.mem.set(f32, samples.items, 0.0);
            break :samples samples;
        };

        const audio = try allocator.create(AudioState);

        const device = device: {
            var config = zaudio.DeviceConfig.init(.playback);
            config.playback_callback = .{
                .context = audio,
                .callback = audioCallback,
            };
            config.raw.playback.format = @enumToInt(zaudio.Format.float32);
            config.raw.playback.channels = 2;
            config.raw.sampleRate = 48_000;
            config.raw.periodSizeInFrames = 480;
            config.raw.periodSizeInMilliseconds = 10;
            break :device try zaudio.createDevice(allocator, null, &config);
        };

        const engine = engine: {
            var config = zaudio.EngineConfig.init();
            config.raw.pDevice = device.asRaw();
            config.raw.noAutoStart = 1;
            break :engine try zaudio.createEngine(allocator, config);
        };

        audio.* = .{
            .device = device,
            .engine = engine,
            .samples = samples,
        };
        return audio;
    }

    fn destroy(audio: *AudioState, allocator: std.mem.Allocator) void {
        audio.samples.deinit();
        audio.engine.destroy(allocator);
        audio.device.destroy(allocator);
        allocator.destroy(audio);
    }
};

pub fn run(allocator: std.mem.Allocator) !void {
    var audioState = try AudioState.create(allocator);
    defer audioState.destroy(allocator);
}
