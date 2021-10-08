defmodule DddElixir.ValueObject.MovieTests do
  use ExUnit.Case

  alias DddElixir.ValueObject.Movie
  alias DddElixir.ValueObject.Person

  test "can make a movie" do
    assert {:ok, movie} =
             Movie.make(%{
               title: %{title: "Batman"}
               genre: :action,
               director: %{name: "Christopher Nolan", year_of_birth: 1970},
             })

    assert :action == movie.genre
    assert %Person{name: "Christopher Nolan", year_of_birth: 1970} == movie.director
    assert %Title{title: "Batman"} == movie.title
  end

  test "cannot make a movie without director" do
    assert {:error, errors} =
             Movie.make(%{
               title: %{title: "Batman" },
               genre: :action,
             })

    assert errors == [{:director, {"can't be blank", [validation: :required]}}]
  end

  test "cannot make Batman a romantic movie" do
    assert {:error, errors} =
             Movie.make(%{
               title: %{title: "Batman"},
               genre: :romance,
               director: %{name: "Christopher Nolan", year_of_birth: 1970},
             })

    assert [{:genre, {"is invalid", _}}] = errors
  end
end
