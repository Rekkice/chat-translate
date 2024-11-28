defmodule Chat.RateLimiters.LeakyBucket do
  use GenServer

  require Logger

  alias Chat.RateLimiter

  @behaviour RateLimiter

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = %{
      request_queue: :queue.new(),
      request_queue_size: 0,
      request_queue_poll_rate:
        RateLimiter.calculate_refresh_rate(
          opts.timeframe_max_requests,
          opts.timeframe,
          opts.timeframe_units
        ),
      send_after_ref: nil,
      cooldown: false,
      bucket_size: opts.bucket_size
    }

    {:ok, state}
  end

  # ---------------- Client facing function ----------------

  @impl RateLimiter
  def make_request(request_handler, response_handler) do
    GenServer.cast(__MODULE__, {:enqueue_request, request_handler, response_handler})
  end

  # ---------------- Server Callbacks ----------------

  # no cooldown, leak immediately
  @impl true
  def handle_cast(
        {:enqueue_request, request_handler, response_handler},
        %{cooldown: false} = state
      ) do
    {request_handler, response_handler} |> leak

    {:noreply,
     %{
       state
       | cooldown: true,
         send_after_ref: schedule_timer(state.request_queue_poll_rate)
     }}
  end

  # handles the case where the bucket is full
  @impl true
  def handle_cast(
        {:enqueue_request, _, {resp_module, resp_function, _resp_args}},
        %{request_queue_size: queue_size, bucket_size: bucket_size} = state
      )
      when queue_size == bucket_size do
    apply(resp_module, resp_function, [{:error, :bucket_full}])

    {:noreply, state}
  end

  @impl true
  def handle_cast({:enqueue_request, request_handler, response_handler}, state) do
    updated_queue = :queue.in({request_handler, response_handler}, state.request_queue)
    new_queue_size = state.request_queue_size + 1

    {:noreply, %{state | request_queue: updated_queue, request_queue_size: new_queue_size}}
  end

  @impl true
  def handle_info(:pop_from_request_queue, %{request_queue_size: 0} = state) do
    {:noreply, %{state | cooldown: false, send_after_ref: nil}}
  end

  def handle_info(:pop_from_request_queue, state) do
    {{:value, req}, new_request_queue} = :queue.out(state.request_queue)
    req |> leak

    {:noreply,
     %{
       state
       | request_queue: new_request_queue,
         send_after_ref: schedule_timer(state.request_queue_poll_rate),
         request_queue_size: state.request_queue_size - 1
     }}
  end

  def handle_info({ref, _result}, state) do
    Process.demonitor(ref, [:flush])

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end

  defp schedule_timer(queue_poll_rate) do
    Process.send_after(self(), :pop_from_request_queue, queue_poll_rate)
  end

  defp leak({request_handler, response_handler}) do
    start_message = "Request started #{NaiveDateTime.utc_now()}"

    Task.Supervisor.async_nolink(RateLimiter.TaskSupervisor, fn ->
      {req_module, req_function, req_args} = request_handler
      {resp_module, resp_function, resp_args} = response_handler

      response = apply(req_module, req_function, req_args)
      apply(resp_module, resp_function, [response] ++ resp_args)

      Logger.info("#{start_message}\nRequest completed #{NaiveDateTime.utc_now()}")
    end)
  end
end
