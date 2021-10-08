defmodule Screenings do
  use GenServer

  # Public API

  def start_link(screenings) do
    GenServer.start_link(__MODULE__, screenings, name: __MODULE__)
  end

  def get(screening_id) do
    GenServer.call(__MODULE__, {:get, screening_id})
  end

  def reserve(screening_id, seats) do
    GenServer.call(__MODULE__, {:reserve, screening_id, seats})
  end

  # Callback functions

  @impl true
  def init(screenings) do
    {:ok, screenings}
  end

  @impl true
  def handle_call({:get, screening_id}, _from, screenings) do
    {:reply, Map.fetch(screenings, screening_id), screenings}
  end

  def handle_call({:reserve, screening_id, seats}, _from, screenings) do
    # TODO: this could fail, make this a with?
    {:ok, screening} = Map.fetch(screenings, screening_id)

    case Screening.reserve(screening, seats) do
      {:ok, new_screening} ->
        {:reply, :ok, %{screenings | screening_id => new_screening}}

      :error ->
        {:reply, :error, screenings}
    end
  end
end

defmodule ReserveSeats do
  defstruct [:customer, :seats, :screening_id]
end

defmodule Screening do
  defstruct [:seats]

  def reserve(%{seats: available_seats} = screening, desired_seats) do
    case all_seats_available?(available_seats, desired_seats) do
      true ->
        {:ok, %{screening | seats: available_seats -- desired_seats}}

      false ->
        :error
    end
  end

  defp all_seats_available?(available_seats, desired_seats) do
    Enum.all?(desired_seats, fn s -> Enum.member?(available_seats, s) end)
  end
end

defmodule CommandHandler do
  def handle(%ReserveSeats{} = command) do
    Screenings.reserve(command.screening_id, command.seats)
  end
end

defmodule DDDElixir.CommandHandlerTest do
  use ExUnit.Case

  test "can reserve free seats" do
    Screenings.start_link(%{1 => %Screening{seats: [1, 2, 3, 4]}})
    command = %ReserveSeats{customer: 123, seats: [1, 2], screening_id: 1}

    assert :ok = CommandHandler.handle(command)
  end

  test "cannot reserve nonexisting seats" do
    Screenings.start_link(%{1 => %Screening{seats: [3, 4, 5, 6]}})
    command = %ReserveSeats{customer: 123, seats: [1, 2], screening_id: 1}

    assert :error = CommandHandler.handle(command)
  end

  test "cannot reserve already taken seats" do
    Screenings.start_link(%{1 => %Screening{seats: [1, 2, 3, 4, 5, 6]}})

    command = %ReserveSeats{customer: 123, seats: [1, 2], screening_id: 1}
    assert :ok = CommandHandler.handle(command)

    command = %ReserveSeats{customer: 456, seats: [1, 2], screening_id: 1}
    assert :error = CommandHandler.handle(command)
  end
end
