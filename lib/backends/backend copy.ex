defmodule SimpleAudio.Backend.Null do
  @moduledoc """
  Useless-but-observably-correct backend for SimpleAudio
  """
  @behaviour SimpleAudio.Backend

  alias SimpleAudio

  @source_table Module.concat([__MODULE__, SourceTable])
  @instance_table Module.concat([__MODULE__, InstanceTable])

  @impl SimpleAudio.Backend
  def init() do
    :ets.new(@source_table, [:named_table, :set, :protected])
    :ets.new(@instance_table, [:named_table, :set, :protected])
    :ok
  end

  @impl SimpleAudio.Backend
  def shutdown() do
    :ok
  end

  @impl SimpleAudio.Backend
  def load(path) do
    {:ok, make_resource(path)}
  end

  @impl SimpleAudio.Backend
  def instantiate(resource) do
    {:ok, make_instance(resource)}
  end

  @impl SimpleAudio.Backend
  def set_state(instance, state) do
    :ok
  end

  @impl SimpleAudio.Backend
  def set_volume(instance, volume) do
    :ok
  end

  @impl SimpleAudio.Backend
  def set_panning(instance, panning) do
    :ok
  end

  @impl SimpleAudio.Backend
  def set_pitch(instance, pitch) do
    :ok
  end

  @impl SimpleAudio.Backend
  def get_status(instance) do
    status = :playing
    {:ok, status}
  end

  defp make_resource(_path) do
    source_handle = make_ref()
    source_handle
  end

  defp make_instance(_path) do
    instance_handle = make_ref()
    instance_handle
  end
end
