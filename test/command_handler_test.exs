defmodule Screenings do
  use GenServer

  @impl true
  def init(screenings) do
    {:ok, screenings}
  end

  def start_link(screenings) do
    GenServer.start_link(__MODULE__, screenings, name: __MODULE__)
  end

  def get(screening) do
    GenServer.call(__MODULE__, {:get, screening})
  end

  @impl true
  def handle_call({:get, screening}, _from, screenings) do
    {:reply, Map.fetch(screenings, screening), screenings}
  end
end

defmodule ReserveSeats do
  defstruct [:customer, :seats, :screening]
end

defmodule Screening do
  defstruct [:seats]

  def reserve(screening, seats) do
    :ok
  end
end

defmodule CommandHandler do
  def handle(%ReserveSeats{} = command) do
    screening = Screenings.get(command.screening)

    case Screening.reserve(screening, command.seats) do
      :ok -> :ok
      _ -> :error
    end
  end
end

defmodule DDDElixir.CommandHandlerTest do
  use ExUnit.Case

  test "customer reservation works" do
    Screenings.start_link(%{1 => %Screening{seats: [1, 2, 3, 4]}})
    command = %ReserveSeats{customer: 123, seats: [1, 2], screening: 1}

    assert :ok = CommandHandler.handle(command)
  end

  test "" do
    
  end
end
