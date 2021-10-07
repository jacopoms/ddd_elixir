defmodule DddElixir.ValueObject.Duration do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:minutes]

  @primary_key false
  embedded_schema do
    field :minutes, :integer
  end

  def changeset(duration \\ %__MODULE__{}, data), do: cast(duration, data, @fields)
end
