defmodule DddElixir.ValueObject.Title do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:title, :language]

  @primary_key false
  embedded_schema do
    field :title, :string
    field :language, :string
  end

  def changeset(title \\ %__MODULE__{}, data), do: cast(title, data, @fields)
end
