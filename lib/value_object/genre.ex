defmodule Genre do
  @all_genres [:action, :horror]

  @type t :: %__MODULE__{name: :action | :horror}
  defstruct [:name]

  def of(name) when name in @all_genres, do: %__MODULE__{name: name}
end
