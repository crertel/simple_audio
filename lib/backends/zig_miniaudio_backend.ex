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

  /// nif: init/0
  fn init(env: beam.env) !beam.term {
    try be.run(beam.allocator);
    return beam.make_error_binary(env, "SUCCESS");
  }

  /// nif: shutdown/0
  fn shutdown(env: beam.env) !beam.term {
    return beam.make_error_binary(env, "NYI");
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
