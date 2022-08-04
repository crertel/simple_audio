defmodule SimpleAudio do
  @moduledoc """
  Basic interfaces for simple audio.
  """

  @typedoc """
  A source from which a sound resource is loaded.

  Currently supported sources:

  * `{:file, "<path>"}` is a sound stored on a filesystem somewhere.
  """
  @type source :: {:file, binary()}

  @typedoc """
  A handle to a loaded sound resource.

  This represents a particular sound loaded in.
  """
  @opaque resource :: reference()

  @typedoc """
  A handle to a sound instance, backed by some sound resource.

  A sound instance is a particular instantiation of a sound resource,
  with it's own volume, panning, state, and so forth.

  You can have multiple sound instances per sound resource.
  """
  @opaque instance :: reference()

  @typedoc """
  The state of a sound instance.

  * `:stopped` means that the sound is currently stopped and reset to the beginning of its clip.
  * `:playing` means that the sound is currently playing.
  * `:paused` means that the sound is currently stopped, but may resume playing where it left off.
  """
  @type instance_state :: :stopped | :playing | :paused

  @typedoc """
  The volume of a sound instance.

  This is a floating point number on the range `[0.0, 1.0]`, fully muted to fully loud respectively.

  Values outside of that range will be clamped by the API.
  """
  @type volume :: float()

  @typedoc """
  The panning of a sound instance.

  This is a floating point number on the range `[-1.0, 1.0]`, fully left to fully right respectively.

  Values outside of that range will be clamped by the API.
  """
  @type panning :: float()

  @typedoc """
  The pitch of a sound instance.

  This is a floating point number on the range `(0.0, +inf)`, with `1.0` representing normal pitch
  and higher numbers representing higher pitch.
  """
  @type pitch :: float()

  @typedoc """
  The status of a sound instance.

  * `state` is the instance state of the instance (playing, paused, stopped, etc.)
  * `panning` is the current panning of the instance
  * `pitch` is the current pitch multiplier of the sound
  * `volume` is the current volume of the sound
  """
  @type status :: %{
          state: instance_state(),
          panning: panning(),
          pitch: pitch(),
          volume: volume()
        }

  @spec init() :: :ok | {:error, binary()}
  def init() do
    {:error, "NYI"}
  end

  @spec shutdown() :: :ok | {:error, binary()}
  def shutdown() do
    {:error, "NYI"}
  end

  @spec load(source()) :: {:ok, resource()} | {:error, binary()}
  def load(source) do
    {:error, "NYI"}
  end

  @spec instantiate(resource()) :: {:ok, instance()} | {:error, binary()}
  def instantiate(resource) do
    {:error, "NYI"}
  end

  @spec set_state(instance(), instance_state()) ::
          :ok | {:error, binary()}
  def set_state(instance, state) do
    {:error, "NYI"}
  end

  @spec set_volume(instance(), volume()) :: :ok | {:error, binary()}
  def set_volume(instance, volume) do
    {:error, "NYI"}
  end

  @spec set_panning(instance(), volume()) :: :ok | {:error, binary()}
  def set_panning(instance, panning) do
    {:error, "NYI"}
  end

  @spec set_pitch(instance(), pitch()) :: :ok | {:error, binary()}
  def set_pitch(instance, pitch) do
    {:error, "NYI"}
  end

  @spec get_status(instance()) :: {:ok, status} | {:error, binary()}
  def get_status(instance) do
    {:error, "NYI"}
  end
end
