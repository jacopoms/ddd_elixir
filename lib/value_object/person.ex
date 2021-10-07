defmodule DddElixir.ValueObject.Person do
  use Construct

  structure do
    field :name, :string
    field :year_of_birth, :integer
  end
end
