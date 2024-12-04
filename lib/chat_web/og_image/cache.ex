defmodule ChatWeb.OgImage.Cache do
  use GenServer

  @table :og_image_cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(@table, [:set, :protected, :named_table])
    {:ok, %{}}
  end

  def put_image(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
  end

  def get_image(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    :ets.insert(@table, {key, value})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    result =
      case :ets.lookup(@table, key) do
        [{^key, value}] -> {:ok, value}
        [] -> :error
      end

    {:reply, result, state}
  end
end
