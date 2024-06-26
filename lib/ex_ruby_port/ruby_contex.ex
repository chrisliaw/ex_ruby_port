defmodule ExRubyPort.RubyContex do
  use TypedStruct

  typedstruct do
    field(:ruby_path, any(), default: System.find_executable("ruby"))
  end
end
