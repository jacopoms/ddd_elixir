defmodule Screenings do
  use GenServer

  @impl true
  def init(screenings) do
    {:ok, screenings}
  end

  def get(screening) do
    GenServer.call(Screenings, {:get, screening})
  end

  @impl true
  def handle_call({:get, screening}, _from, screenings) do
    {:reply, Map.fetch(screenings, screening), screenings}
  end

#   @impl true
#   def handle_cast({:create, name}, names) do
#     if Map.has_key?(names, name) do
#       {:noreply, names}
#     else
#       {:ok, bucket} = KV.Bucket.start_link([])
#       {:noreply, Map.put(names, name, bucket)}
#     end
#   end
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
    GenServer.start_link(Screenings, %{1 => %Screening{seats: [1, 2, 3, 4]}})
    command = %ReserveSeats{customer: 123, seats: [1, 2], screening: 1}

    assert :ok = CommandHandler.handle(command)
  end

  test "" do
    
  end
end
