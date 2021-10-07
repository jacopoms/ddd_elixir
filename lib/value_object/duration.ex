defmodule DddElixir.ValueObject.Duration do
  use Construct

  structure do
    field :minutes, :integer
  end
end
