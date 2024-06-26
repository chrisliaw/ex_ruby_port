defmodule ExRubyPortTest do
  alias ExRubyPort.RubyService
  alias ExRubyPort.RubyContex
  use ExUnit.Case

  test "Call ruby code as port" do
    {:ok, pid} = ExRubyPort.start_link(%RubyContex{})
    {:ok, res} = ExRubyPort.run(pid, "./test/ruby/hello.rb")
    IO.inspect(res)
    assert(res == "Hello from Ruby!\n")

    {:ok, res2} = ExRubyPort.run(pid, "./test/ruby/hello.rb", ["world"])
    IO.inspect(res2)
    assert(res2 == "Hello World!\n")

    {:ok, spid} = ExRubyPort.start(pid, "./test/ruby/server.rb")
    IO.inspect(spid)

    {:ok, rres} = RubyService.invoke(spid, "RubyTest::RubyServer", "say", ["hello", "world"])
    IO.puts("Elixir side : #{inspect(rres)}")

    {:ok, rres2} = RubyService.invoke(spid, "", "puts", "This is message from Elixir")
    IO.puts("Elixir side : #{inspect(rres2)}")

    {:error, erres} = RubyService.invoke(spid, "", "split", "This is message from Elixir")
    IO.inspect(erres)

    {:ok, rres3} =
      RubyService.invoke(spid, "\"This is message from Elixir to split\"", "split", " ")

    IO.inspect(rres3)

    {:ok, srres1} =
      RubyService.invoke(spid, "RubyTest::SecondClass", "new", [], %{as_var: :jan})

    IO.puts("Elixir side : #{inspect(srres1)}")

    {:ok, srres2} =
      RubyService.invoke(spid, "@jan", "say_some", "January is here")

    IO.puts("Elixir side : #{inspect(srres2)}")

    RubyService.stop(spid)
  end
end
