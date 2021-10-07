defmodule DddElixir.ValueObject.Person do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:name, :year_of_birth]

  @primary_key false
  embedded_schema do
    field :name, :string
    field :year_of_birth, :integer
  end

  def changeset(person \\ %__MODULE__{}, data), do: cast(person, data, @fields)
end
