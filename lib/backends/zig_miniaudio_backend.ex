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

  /// resource: audio_engine_res definition
  const audio_engine_res = *be.AudioState;

  /// resource: audio_engine_res cleanup
  fn audio_engine_res_cleanup(_: beam.env, audio: *audio_engine_res) void {
    audio.*.destroy(beam.allocator);
  }

  /// nif: create_engine/0
  fn create_engine(env: beam.env) beam.term {
    var audio = be.AudioState.create(beam.allocator) catch {
      return beam.raise_resource_error(env);
    };
    audio.engine.start() catch {
      defer audio.destroy(beam.allocator);
      return beam.raise_resource_error(env);
    };

    return __resource__.create(audio_engine_res, env, audio) catch {
      defer audio.destroy(beam.allocator);
      return beam.raise_resource_error(env);
    };
  }

  /// nif: destroy_engine/1
  fn destroy_engine(env: beam.env, audio: beam.term) !beam.term {
    var result = __resource__.fetch(audio_engine_res, env, audio)
      catch return beam.raise_resource_error(env);
    result.destroy(beam.allocator);
    return beam.make_ok(env);
  }

  /// nif: load/1
  fn load(env: beam.env, src: beam.term) !beam.term {
    _ = src;
    return beam.make_error_binary(env, "NYI");
  }

  /// nif: instantiate/1
  fn instantiate(env: beam.env, resource: beam.term) !beam.term {
    _ = resource;
    return beam.make_error_binary(env, "NYI");
  }

  /// nif: set_volume/2
  fn set_volume(env: beam.env, instance: beam.term, volume: f64) !beam.term {
    _ = instance;
    _ = volume;
    return beam.make_error_binary(env, "NYI");
  }

  /// nif: set_panning/2
  fn set_panning(env: beam.env, instance: beam.term, panning: f64) !beam.term {
    _ = instance;
    _ = panning;
    return beam.make_error_binary(env, "NYI");
  }

  /// nif: set_pitch/2
  fn set_pitch(env: beam.env, instance: beam.term, pitch: f64) !beam.term {
    _ = instance;
    _ = pitch;
    return beam.make_error_binary(env, "NYI");
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

  """
end
