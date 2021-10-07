defmodule DddElixir.ValueObject.Movie do
  use Ecto.Schema
  import Ecto.Changeset

  alias DddElixir.ValueObject.{Duration, Person, Title}

  @fields [:genre]
  @embedded_fields [:title, :length, :director, :cast]

  @primary_key false
  embedded_schema do
    embeds_one :title, Title
    embeds_one :length, Duration
    field :genre, Ecto.Enum, values: [:adventure, :action, :sci_fy]
    embeds_one :director, Person
    embeds_many :cast, Person
  end

  def make(data) do
    case changeset(data) do
      %{valid?: true} = cset -> {:ok, apply_changes(cset)}
      %{valid?: false, errors: errors} -> {:error, errors}
    end
  end

  def changeset(movie \\ %__MODULE__{}, data) do
    cset = cast(movie, data, @fields)
    cset = Enum.reduce(@embedded_fields, cset, fn field, cset -> cast_embed(cset, field) end)
    validate_required(cset, @fields ++ @embedded_fields)
  end
end
