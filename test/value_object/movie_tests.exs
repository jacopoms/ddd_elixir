defmodule DddElixir.ValueObject.MovieTests do
  use ExUnit.Case

  alias DddElixir.ValueObject.Duration
  alias DddElixir.ValueObject.Movie
  alias DddElixir.ValueObject.Person
  alias DddElixir.ValueObject.Title

  require DddElixir.Enum.Genre, as: Genre

  test "can make a movie" do
    assert {:ok, movie} =
             Movie.make(%{
               title: %{title: "Batman", language: "english"},
               length: %{minutes: 125},
               genre: "action",
               director: %{name: "Christopher Nolan", year_of_birth: 1970},
               cast: []
             })

    assert Genre.Action == movie.genre
    assert %Duration{minutes: 125} == movie.length
    assert %Person{name: "Christopher Nolan", year_of_birth: 1970} == movie.director
    assert %Title{title: "Batman", language: "english"} == movie.title
    assert [] == movie.cast
  end

  test "cannot make a movie without director" do
    assert {:error, errors} =
             Movie.make(%{
               title: %{title: "Batman", language: "english"},
               length: %{minutes: 125},
               genre: "action",
               cast: []
             })

    assert errors == %{director: :missing}
  end

  test "cannot make Batman a romantic movie" do
    assert {:error, errors} =
             Movie.make(%{
               title: %{title: "Batman", language: "english"},
               length: %{minutes: 125},
               genre: "romance",
               director: %{name: "Christopher Nolan", year_of_birth: 1970},
               cast: []
             })

    assert errors == %{genre: :invalid}
  end
end
