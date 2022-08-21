defmodule SimpleAudio.Backend.ZigMiniaudio do
  @moduledoc """
  The low-level backend, in Zig, for simple audio.
  """

  use Zig,
    sources: [
      {"miniaudio.c",
       [
         "-DMA_NO_WEBAUDIO",
         "-DMA_NO_ENCODING",
         "-DMA_NO_NULL",
         "-DMA_NO_JACK",
         "-fno-sanitize=undefined"
       ]},
      "cabi_workarounds.c"
    ],
    link_libc: true

  ~Z"""

  const be = @import("backend.zig");
  const zaudio = @import("zaudio.zig");

  ///////////////////////////////////
  // Audio engine resource and API
  ///////////////////////////////////

  /// resource: audio_engine_res definition
  const audio_engine_res = *be.AudioState;

  /// resource: audio_engine_res cleanup
  fn audio_engine_res_cleanup(_: beam.env, audio: *audio_engine_res) void {
    audio.*.destroy(beam.allocator);
    std.debug.print("Removed old engine",.{});
  }

  /// nif: create_engine/0
  fn create_engine(env: beam.env) !beam.term {
    var audio = be.AudioState.create(beam.allocator) catch {
      return beam.raise_resource_error(env);
    };
    errdefer audio.destroy(beam.allocator);

    try audio.engine.start();
    var res = try __resource__.create(audio_engine_res, env, audio);
    __resource__.release(audio_engine_res, env, res);
    return res;
  }

  ///////////////////////////////////
  // Sound
  ///////////////////////////////////

  /// resource: sound_res definition
  const sound_res = zaudio.Sound;

  /// nif: load_from_path/2
  fn load_from_path(env: beam.env, audio: beam.term, path: []u8) !beam.term {
    _ = audio;

    var c_path = try beam.allocator.allocSentinel(u8, path.len, 0);
    //std.debug.print("Typeof c_path: {}\n", .{@TypeOf(c_path)});
    std.mem.copy(u8, c_path, path);
    //std.debug.print("Got string: |{s}|\n",.{c_path});

    var engine = __resource__.fetch(audio_engine_res, env, audio)
      catch return beam.raise_resource_error(env);

    var sound = engine.engine.createSoundFromFile( beam.allocator, c_path, .{})
        catch return beam.raise_resource_error(env);

    return __resource__.create(sound_res, env, sound) catch {
        defer sound.destroy(beam.allocator);
      return beam.raise_resource_error(env);
    };
  }

  /// nif: instantiate/1
  fn instantiate(env: beam.env, resource: beam.term) !beam.term {
    _ = resource;
    return beam.make_error_binary(env, "NYI");
  }

  /// nif: set_volume/2
  fn set_volume(env: beam.env, sound_resource: beam.term, volume: f32) !beam.term {
    var sound = __resource__.fetch(sound_res, env, sound_resource)
      catch return beam.raise_resource_error(env);

    sound.setVolume(volume);

    return beam.make_ok(env);
  }

  /// nif: set_panning/2
  fn set_panning(env: beam.env, sound_resource: beam.term, panning: f32) !beam.term {
    var sound = __resource__.fetch(sound_res, env, sound_resource)
      catch return beam.raise_resource_error(env);

    sound.setPan(panning);

    return beam.make_ok(env);
  }

  /// nif: set_pitch/2
  fn set_pitch(env: beam.env, sound_resource: beam.term, pitch: f32) !beam.term {
    var sound = __resource__.fetch(sound_res, env, sound_resource)
      catch return beam.raise_resource_error(env);

    sound.setPitch(pitch);

    return beam.make_ok(env);
  }

  /// nif: set_state/2
  fn set_state(env: beam.env, instance: beam.term, status: beam.term) !beam.term {
    _ = instance;
    _ = status;
    return beam.make_error_binary(env, "NYI");
  }

  /// nif: get_status/1
  fn get_status(env: beam.env, instance: beam.term) !beam.term {
    _ = instance;
    return beam.make_error_binary(env, "NYI");
  }

  /// nif: play/1
  fn play(env: beam.env, sound_resource: beam.term) !beam.term {
    var sound = __resource__.fetch(sound_res, env, sound_resource)
      catch return beam.raise_resource_error(env);

    try sound.start();

    return beam.make_ok(env);
  }

  """
end
