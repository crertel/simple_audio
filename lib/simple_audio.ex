defmodule SimpleAudio do
  @moduledoc """
  Basic interfaces for simple audio.
  """
  use GenServer

  require Record

  Record.defrecord(:simple_audio, engine: nil)
  @type simple_audio :: record(:simple_audio, engine: term())

  alias SimpleAudio.Backend.ZigMiniaudio, as: ZMA

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
  The duration of a sound instance, in seconds.
  """
  @type sound_duration :: float()

  @spec start_link([{atom(), any()}]) :: {:error, any()} | {:ok, pid}
  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec load(source()) :: {:ok, resource()} | {:error, binary()}
  def load({:file, path} = res) when is_binary(path), do: GenServer.call(__MODULE__, {:load, res})
  def load(_), do: {:error, "Invalid source."}

  @spec instantiate(resource()) :: {:ok, instance()} | {:error, binary()}
  def instantiate(resource), do: GenServer.call(__MODULE__, {:instantiate, resource})

  @spec set_volume(instance(), volume()) :: :ok | {:error, binary()}
  def set_volume(sound, volume),
    do: GenServer.call(__MODULE__, {:set_volume, sound, 1.0 * volume})

  @spec set_panning(instance(), volume()) :: :ok | {:error, binary()}
  def set_panning(sound, panning),
    do: GenServer.call(__MODULE__, {:set_panning, sound, 1.0 * panning})

  @spec set_pitch(instance(), pitch()) :: :ok | {:error, binary()}
  def set_pitch(sound, pitch), do: GenServer.call(__MODULE__, {:set_pitch, sound, 1.0 * pitch})

  @spec get_duration(instance()) :: {:ok, sound_duration()} | {:error, binary()}
  def get_duration(sound), do: GenServer.call(__MODULE__, {:get_duration, sound})

  @spec play(instance()) :: :ok | {:error, binary()}
  def play(sound), do: GenServer.call(__MODULE__, {:play, sound})

  @spec stop(instance()) :: :ok | {:error, binary()}
  def stop(sound), do: GenServer.call(__MODULE__, {:play, sound})

  @spec init(any) :: none
  def init(_) do
    {:ok, simple_audio(engine: ZMA.create_engine())}
  end

  def handle_call({:load, {:file, file_path}}, _from, simple_audio(engine: engine) = s) do
    {:reply, {:ok, ZMA.load_from_path(engine, file_path)}, s}
  end

  def handle_call({:instantiate, resource}, _from, simple_audio(engine: engine) = s) do
    {:reply, {:ok, ZMA.instantiate(engine, resource)}, s}
  end

  def handle_call({:set_volume, sound, volume}, _from, simple_audio(engine: _engine) = s) do
    ZMA.set_volume(sound, max(0.0, min(volume, 1.0)))
    {:reply, :ok, s}
  end

  def handle_call({:set_panning, sound, panning}, _from, simple_audio(engine: _engine) = s) do
    ZMA.set_panning(sound, max(-1.0, min(panning, 1.0)))
    {:reply, :ok, s}
  end

  def handle_call({:set_pitch, sound, pitch}, _from, simple_audio(engine: _engine) = s) do
    ZMA.set_pitch(sound, max(0.0, pitch))
    {:reply, :ok, s}
  end

  def handle_call({:get_duration, sound}, _from, simple_audio(engine: _engine) = s) do
    {:reply, {:ok, ZMA.get_duration(sound)}, s}
  end

  def handle_call({:play, sound}, _from, simple_audio(engine: _engine) = s) do
    ZMA.play(sound)
    {:reply, :ok, s}
  end

  def handle_call({:stop, sound}, _from, simple_audio(engine: _engine) = s) do
    ZMA.stop(sound)
    {:reply, :ok, s}
  end
end
