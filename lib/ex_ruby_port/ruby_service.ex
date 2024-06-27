defmodule ExRubyPort.RubyService do
  alias ExRubyPort.RubyContext
  use GenServer

  def start_link(sess, file, params) do
    GenServer.start_link(__MODULE__, %{session: sess, file: file, params: params})
  end

  def invoke(pid, cls, mtd, params, opts \\ %{})

  def invoke(pid, cls, mtd, params, opts) when not is_list(params),
    do: invoke(pid, cls, mtd, [params], opts)

  def invoke(pid, cls, mtd, params, opts) when is_list(params) do
    GenServer.call(pid, {:invoke, cls, mtd, params, opts})
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def init(state) do
    port =
      Port.open(
        {:spawn, build_cmdline(state)},
        # "#{state.session.context.ruby_path} #{Path.expand(state.file)} #{Enum.join(state.params, " ")}"},
        [:binary, :exit_status, {:packet, 4}, :nouse_stdio]
      )

    {:ok, Map.put_new(state, :port, port)}
  end

  def handle_call({:invoke, cls, mtd, params, opts}, _from, state) do
    res = Port.command(state.port, :erlang.term_to_binary({:invoke, cls, mtd, params, opts}))
    IO.puts("invoke res : #{inspect(res)}")

    port = state.port

    res =
      receive do
        {^port, {:data, result}} -> result
      end

    {:reply, :erlang.binary_to_term(res), state}
  end

  defp build_cmdline(%{session: %{context: %RubyContext{} = ctx}} = state) do
    case ctx.with_bundle_exec? do
      true ->
        "bundle exec #{ctx.ruby_path} #{Path.expand(state.file)} #{Enum.join(state.params, " ")}"

      false ->
        "#{ctx.ruby_path} #{Path.expand(state.file)} #{Enum.join(state.params, " ")}"
    end
  end
end
