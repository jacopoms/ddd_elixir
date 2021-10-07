defmodule DddElixir.Enum do
  use EnumType

  defenum Genre do
    value(Action, "action")
    value(Adventure, "adventure")
    value(SciFi, "sci-fi")

    def cast(genre) when is_atom(genre), do: cast(Atom.to_string(genre))
    def cast("action"), do: {:ok, Action}
    def cast("adventure"), do: {:ok, Adventure}
    def cast("sci-fi"), do: {:ok, SciFi}
    def cast(_), do: :error
  end
end
