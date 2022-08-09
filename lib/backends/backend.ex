defmodule SimpleAudio.Backend do
  @moduledoc """
  Behavior for the backend of simple audio.
  """

  alias SimpleAudio

  @callback init() :: :ok | {:error, binary()}

  @callback shutdown() :: :ok | {:error, binary()}

  @callback load(SimpleAudio.source()) :: {:ok, SimpleAudio.resource()} | {:error, binary()}

  @callback instantiate(SimpleAudio.resource()) ::
              {:ok, SimpleAudio.instance()} | {:error, binary()}

  @callback set_state(SimpleAudio.instance(), SimpleAudio.instance_state()) ::
              :ok | {:error, binary()}
  @callback set_volume(SimpleAudio.instance(), SimpleAudio.volume()) :: :ok | {:error, binary()}
  @callback set_panning(SimpleAudio.instance(), SimpleAudio.volume()) :: :ok | {:error, binary()}
  @callback set_pitch(SimpleAudio.instance(), SimpleAudio.pitch()) :: :ok | {:error, binary()}
  @callback get_status(SimpleAudio.instance()) :: {:ok, SimpleAudio.status()} | {:error, binary()}
end
