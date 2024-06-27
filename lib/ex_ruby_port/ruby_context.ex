defmodule ExRubyPort.RubyContext do
  alias ExRubyPort.RubyContext
  use TypedStruct

  typedstruct do
    field(:ruby_path, any(), default: System.find_executable("ruby"))
    field(:with_bundle_exec?, boolean(), default: false)
  end

  def set_ruby_path(%RubyContext{} = ctx, path), do: %RubyContext{ctx | ruby_path: path}
  def run_with_bundle_exec(%RubyContext{} = ctx), do: %RubyContext{ctx | with_bundle_exec?: true}

  def run_without_bundle_exec(%RubyContext{} = ctx),
    do: %RubyContext{ctx | with_bundle_exec?: false}

  def is_run_with_bundle_exec?(%RubyContext{} = ctx), do: ctx.with_bundle_exec?
end
