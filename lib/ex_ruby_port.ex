defmodule ExRubyPort do
  alias ExRubyPort.RubyService
  alias ExRubyPort.RubySession
  alias ExRubyPort.RubyContex
  use GenServer

  def start_link(opts \\ %RubyContex{}) do
    GenServer.start_link(__MODULE__, opts)
  end

  def run(pid, file, params \\ []) do
    GenServer.call(pid, {:run, file, params})
  catch
    :exit, {:timeout, _} -> {:ok, ""}
  end

  def start(pid, file, params \\ []) do
    GenServer.call(pid, {:new_session, file, params})
  end

  def init(opts) do
    {:ok, %{context: opts}}
  end

  def handle_call({:run, file, params}, _from, state) do
    {:ok, spid} = RubySession.start_link(state)
    res = GenServer.call(spid, {:run, file, params})
    GenServer.stop(spid)
    {:reply, res, state}
  end

  def handle_call({:new_session, file, params}, _from, state) do
    {:ok, spid} = RubyService.start_link(state, file, params)
    {:reply, {:ok, spid}, state}
  end
end
