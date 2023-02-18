defmodule MayorGame.CityCalculator do
  use GenServer, restart: :permanent
  alias MayorGame.City.{Town, Buildable}
  alias MayorGame.{City, CityHelpers, Repo}
  import Ecto.Query

  def start_link(initial_val) do
    IO.puts('start_city_calculator_link')
    # starts link based on this file
    # which triggers init function in module

    # check here if world exists already
    case City.get_world(initial_val) do
      %City.World{} -> IO.puts("world exists already!")
      nil -> City.create_world(%{day: 0, pollution: 0})
    end

    # this calls init function
    GenServer.start_link(__MODULE__, initial_val)
  end

  def init(initial_world) do
    buildables_map = %{
      buildables_flat: Buildable.buildables_flat(),
      buildables_kw_list: Buildable.buildables_kw_list(),
      buildables: Buildable.buildables(),
      buildables_list: Buildable.buildables_list(),
      buildables_ordered: Buildable.buildables_ordered(),
      buildables_ordered_flat: Buildable.buildables_ordered_flat(),
      empty_buildable_map: Buildable.empty_buildable_map()
    }

    in_dev = Application.get_env(:mayor_game, :env) == :dev

    IO.puts('init calculator')
    # initial_val is 1 here, set in application.ex then started with start_link

    game_world = City.get_world!(initial_world)

    # send message :tax to self process after 5000ms
    # calls `handle_info` function
    Process.send_after(self(), :tax, 1000)

    # returns ok tuple when u start
    {:ok, %{world: game_world, buildables_map: buildables_map, in_dev: in_dev}}
  end

  # when :tax is sent
  def handle_info(
        :tax,
        %{world: world, buildables_map: buildables_map, in_dev: in_dev} = _sent_map
      ) do
    cities =
      City.list_cities_preload()
      |> Enum.filter(fn city ->
        city.huts > 0 || city.single_family_homes > 0 || city.apartments > 0 ||
          city.homeless_shelters > 0 || city.micro_apartments > 0 || city.high_rises > 0 ||
          city.megablocks > 0
      end)

    pollution_ceiling = 2_000_000_000 * Random.gammavariate(7.5, 1)

    db_world = City.get_world!(1)

    season =
      cond do
        rem(world.day, 365) < 91 -> :winter
        rem(world.day, 365) < 182 -> :spring
        rem(world.day, 365) < 273 -> :summer
        true -> :fall
      end

    # :eprof.start_profiling([self()])

    leftovers =
      cities
      # |> Flow.from_enumerable(max_demand: 100)
      |> Enum.map(fn city ->
        # result here is a %Town{} with stats calculated
        CityHelpers.calculate_city_stats(
          city,
          db_world,
          pollution_ceiling,
          season,
          buildables_map,
          in_dev,
          false
        )
      end)

    new_world_pollution =
      leftovers
      |> Enum.map(fn city -> city.pollution end)
      |> Enum.sum()

    leftovers
    |> Enum.sort_by(& &1.id)
    |> Enum.chunk_every(20)
    |> Enum.each(fn chunk ->
      Repo.checkout(
        fn ->
          # town_ids = Enum.map(chunk, fn city -> city.id end)
          Enum.each(chunk, fn city ->
            from(t in Town,
              where: t.id == ^city.id,
              update: [
                inc: [
                  treasury: ^city.income - ^city.daily_cost,
                  steel: ^city.new_steel,
                  missiles: ^city.new_missiles,
                  sulfur: ^city.new_sulfur,
                  gold: ^city.new_gold,
                  uranium: ^city.new_uranium,
                  shields: ^city.new_shields
                  # logs—————————
                ],
                set: [
                  pollution: ^city.pollution
                ]
              ]
            )
            |> Repo.update_all([])

            # also update logs here for old deaths
            # and pollution deaths
          end)
        end,
        timeout: 6_000_000
      )
    end)

    updated_pollution =
      if db_world.pollution + new_world_pollution < 0 do
        0
      else
        db_world.pollution + new_world_pollution
      end

    # update World in DB, pull updated_world var out of response
    {:ok, updated_world} =
      City.update_world(db_world, %{
        day: db_world.day + 1,
        pollution: updated_pollution
      })

    # SEND RESULTS TO CLIENTS
    # send val to liveView process that manages front-end; this basically sends to every client.

    IO.puts(
      "day: " <>
        to_string(db_world.day) <>
        " | pollution: " <>
        to_string(db_world.pollution) <> " | —————————————————————————————————————————————"
    )

    MayorGameWeb.Endpoint.broadcast!(
      "cityPubSub",
      "ping",
      updated_world
    )

    # recurse, do it again
    Process.send_after(self(), :tax, 2000)

    # returns this to whatever calls ?
    {:noreply, %{world: updated_world, buildables_map: buildables_map, in_dev: in_dev}}
  end

  def update_logs(log, existing_logs) do
    updated_log = if !is_nil(existing_logs), do: [log | existing_logs], else: [log]

    # updated_log = [log | existing_logs]

    if length(updated_log) > 50 do
      updated_log |> Enum.take(50)
    else
      updated_log
    end
  end
end
