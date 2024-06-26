defmodule ExRubyPort.RubySession do
  alias ExRubyPort.RubySession
  use GenServer

  use TypedStruct

  typedstruct do
    field(:context, any())
  end

  def set_context(sess, ctx), do: %RubySession{sess | context: ctx}

  def start_link(opts) do
    sess =
      %RubySession{}
      |> RubySession.set_context(opts[:context])

    GenServer.start_link(__MODULE__, sess)
  end

  def init(%RubySession{} = sess) do
    {:ok, sess}
  end

  def handle_call({:run, file, params}, _from, state) do
    port =
      Port.open(
        {:spawn, "#{state.context.ruby_path} #{Path.expand(file)} #{Enum.join(params, " ")}"},
        [
          :binary,
          :exit_status
        ]
      )

    res =
      receive do
        {^port, {:data, result}} -> result
      end

    Port.close(port)

    {:reply, {:ok, res}, state}
  end
end
