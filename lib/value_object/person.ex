defmodule Person do
  @type t :: %__MODULE__{name: String.t(), year_of_birth: pos_integer()}

  defstruct [:name, :year_of_birth]

  def new(name, year_of_birth) when year_of_birth > 1900 and year_of_birth < 2021 do
    %__MODULE__{name: name, year_of_birth: year_of_birth}
  end
end
