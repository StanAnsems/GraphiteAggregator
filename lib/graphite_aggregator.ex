defmodule GraphiteAggregator do
  @moduledoc """
  A GenServer to send metrics to graphite
  """
  use GenServer
  require Logger

  @name __MODULE__

  # Aggregation interval in seconds
  @aggregation_interval 60

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def init([]) do
    {:ok, socket} = :gen_udp.open(0)

    interval = Application.get_env(:graphite_aggregator, :interval, @aggregation_interval)
    :timer.send_interval(interval * 1000, :send_data)

    state = %{
      socket: socket,
      interval: interval,
      host: Application.fetch_env!(:graphite_aggregator, :host) |> String.to_charlist(),
      port: Application.fetch_env!(:graphite_aggregator, :port),
      prefix: Application.fetch_env!(:graphite_aggregator, :prefix),
      chunk_size: Application.get_env(:graphite_aggregator, :chunk_size, 5),
      debug: Application.get_env(:graphite_aggregator, :debug, "false") == "true",
      data: %{}
    }

    {:ok, state}
  end

  def metric(namespace, value \\ 1, timestamp \\ System.os_time(:second)) do
    GenServer.cast(@name, {:metric, namespace, value, timestamp})
  end

  def handle_cast({:metric, ns, val, ts}, state = %{data: data, interval: interval}) do
    bucket = {ns, div(ts, interval)}
    data = Map.update(data, bucket, {val, ts}, fn {sum, _ts} -> {sum + val, ts} end)
    {:noreply, %{state | data: data}}
  end

  def handle_info(:send_data, state = %{data: data}) do
    data
    |> Enum.chunk_every(state.chunk_size)
    |> Enum.each(fn chunk ->
      send_data(state, chunk)
    end)

    {:noreply, %{state | data: %{}}}
  end

  defp send_data(state, data) do
    packet =
      for {{ns, _}, {val, ts}} <- data, into: "" do
        if (state.debug) do
          Logger.info("ga | Send metric: #{ns} #{val} #{ts}")
        end
        pack_msg(state.prefix <> ns, val, ts)
      end

    if packet != "" do
      case :gen_udp.send(state.socket, state.host, state.port, packet) do
        {:error, error} ->
          Logger.error("ga | Error when pushing graphite data #{inspect(error)}")

        :ok ->
          :ok
      end
    end
  end

  defp pack_msg(ns, val, ts) do
    "#{ns} #{val} #{ts}\n"
  end
end
