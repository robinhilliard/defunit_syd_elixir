defmodule Unit do

  defmacro core(id, doc) do
    quote do
      @typedoc unquote(doc)
      @type unquote({id, [], nil}) :: float
      @spec number <~ unquote({id, [], nil}) :: unquote({id, [], nil})
      def value <~ unquote(id) do
        value
      end
    end |> Macro.expand(__ENV__) |> Macro.to_string |> IO.puts
  end
  
end