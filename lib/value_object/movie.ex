defmodule DddElixir.ValueObject.Movie do
  use Construct
  alias DddElixir.ValueObject.{Duration, Person, Title}
  require DddElixir.Enum.Genre, as: Genre

  structure do
    field :title, Title
    field :length, Duration
    field :genre, Genre
    field :director, Person
    field :cast, {:array, Person}
  end
end
