# Commands
defmodule ReserveSeats do
  defstruct [:screening_id, :customer, :seats, :issued_time]
end

# Events
defmodule ScreeningCreated do
  defstruct [:aggregate_id, :seats, :show_time]
end

defmodule SeatsReserved do
  defstruct [:aggregate_id, :customer, :seats]
end

# Aggregates
defmodule Screening do
  defstruct [:screening_id, :seats, :show_time]

  def execute(
        %__MODULE__{seats: available_seats, screening_id: id, show_time: show_time},
        %ReserveSeats{seats: desired_seats, customer: customer, issued_time: issued_time}
      ) do
    with {_, true} <- {:seats_available?, all_seats_available?(available_seats, desired_seats)},
         {_, false} <- {:too_late?, too_late?(show_time, issued_time)} do
      {:ok, %SeatsReserved{aggregate_id: id, seats: desired_seats, customer: customer}}
    else
      {:seats_available?, false} -> {:error, :seats_not_available}
      {:too_late?, true} -> {:error, :too_late}
    end
  end

  def apply(%__MODULE__{}, %ScreeningCreated{
        aggregate_id: id,
        seats: seats,
        show_time: time
      }) do
    %__MODULE__{screening_id: id, seats: seats, show_time: time}
  end

  def apply(%__MODULE__{seats: available_seats} = aggregate, %SeatsReserved{seats: seats_reserved}) do
    %__MODULE__{aggregate | seats: available_seats -- seats_reserved}
  end

  defp all_seats_available?(available_seats, desired_seats) do
    Enum.all?(desired_seats, fn s -> Enum.member?(available_seats, s) end)
  end

  defp too_late?(show_time, cmd_time) do
    DateTime.diff(show_time, cmd_time, :second) < 15 * 60
  end
end

# Infrastructure
defmodule EventStore do
  use GenServer

  # Public API

  def start_link(events) do
    GenServer.start_link(__MODULE__, events, name: __MODULE__)
  end

  def get_by_aggregate_id(aggregate_id) do
    GenServer.call(__MODULE__, {:get_by_aggregate_id, aggregate_id})
  end

  def publish(event) do
    GenServer.call(__MODULE__, {:publish, event})
  end

  # Callback functions

  @impl true
  def init(events) do
    {:ok, events}
  end

  @impl true
  def handle_call({:get_by_aggregate_id, aggregate_id}, _from, events) do
    {:reply, Enum.filter(events, fn %{aggregate_id: id} -> id == aggregate_id end), events}
  end

  def handle_call({:publish, event}, _from, events) do
    {:reply, :ok, events ++ [event]}
  end
end

defmodule CommandHandler do
  # This comes with a high risk of race conditions, which is only tolerable for a POC and is very easy to avoid and fix.
  # Two possible solutions would be:
  # - turning this module into a process (GenServer) to ensure transactional integrity (not very efficient, only 1 command at a time)
  # - making every instance of an aggregate a process (nice Elixir flex, also acts as a sort of cache for the aggregate, processes can be killed or frozen to save memory)
  #
  # For the purpose of this exercise, none of the above is worth implementing, not beacuse it would be too complex,
  # but rather because I do not want to waste time explainig Marco the infrastructural code...

  def handle(%ReserveSeats{screening_id: aggregate_id} = command) do
    aggregate = rehydrate_aggregate(Screening, aggregate_id)

    case Screening.execute(aggregate, command) do
      {:ok, event} -> EventStore.publish(event)
      error -> error
    end
  end

  defp rehydrate_aggregate(aggregate_module, aggregate_id) do
    aggregate_id
    |> EventStore.get_by_aggregate_id()
    |> Enum.reduce(
      struct(aggregate_module),
      fn event, aggregate -> aggregate_module.apply(aggregate, event) end
    )
  end
end

defmodule DDDElixir.CommandHandlerTest do
  use ExUnit.Case

  test "can reserve free seats" do
    given([
      %ScreeningCreated{
        aggregate_id: 1,
        seats: [1, 2, 3, 4, 5, 6],
        show_time: DateTime.add(DateTime.utc_now(), 60 * 60)
      }
    ])

    command = %ReserveSeats{
      customer: 123,
      seats: [1, 2],
      screening_id: 1,
      issued_time: DateTime.utc_now()
    }

    assert :ok = CommandHandler.handle(command)
  end

  test "cannot reserve nonexisting seats" do
    given([
      %ScreeningCreated{
        aggregate_id: 1,
        seats: [1, 2, 3, 4, 5, 6],
        show_time: DateTime.add(DateTime.utc_now(), 60 * 60)
      }
    ])

    command = %ReserveSeats{
      customer: 123,
      seats: [42],
      screening_id: 1,
      issued_time: DateTime.utc_now()
    }

    assert {:error, :seats_not_available} = CommandHandler.handle(command)
  end

  test "cannot reserve already taken seats" do
    given([
      %ScreeningCreated{
        aggregate_id: 1,
        seats: [1, 2, 3, 4, 5, 6],
        show_time: DateTime.add(DateTime.utc_now(), 60 * 60)
      },
      %SeatsReserved{aggregate_id: 1, seats: [1, 2, 3]}
    ])

    command = %ReserveSeats{
      customer: 123,
      seats: [1, 2],
      screening_id: 1,
      issued_time: DateTime.utc_now()
    }

    assert {:error, :seats_not_available} = CommandHandler.handle(command)
  end

  test "cannot reserve later than 15 minutes before the show" do
    given([
      %ScreeningCreated{
        aggregate_id: 1,
        seats: [1, 2, 3, 4, 5, 6],
        show_time: DateTime.add(DateTime.utc_now(), 5 * 60)
      }
    ])

    command = %ReserveSeats{
      customer: 123,
      seats: [1, 2],
      screening_id: 1,
      issued_time: DateTime.utc_now()
    }

    assert {:error, :too_late} = CommandHandler.handle(command)
  end

  defp given(events) do
    {:ok, _} = EventStore.start_link(events)
  end
end
