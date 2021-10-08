defmodule Movie do
  @type t :: %__MODULE__{title: String.t(), genre: Genre.t(), director: Person.t()}
  defstruct [:title, :genre, :director]
end
