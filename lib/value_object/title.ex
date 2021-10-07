defmodule DddElixir.ValueObject.Title do
  use Construct

  structure do
    field :title, :string
    field :language, :string
  end
end
