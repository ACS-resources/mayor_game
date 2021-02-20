defmodule MayorGame.Taxer do
  use GenServer, restart: :permanent
  alias MayorGame.City

  def val(pid) do
    GenServer.call(pid, :val)
  end

  def cities(pid) do
    # call gets stuff back
    GenServer.call(pid, :cities)
  end

  def start_link(_initial_val) do
    # starts link based on this file
    # triggers init function in module

    # ok, for some reason, resetting the ecto repo does not like this being in start_link
    # world = MayorGame.Repo.get!(MayorGame.City.World, 0)

    GenServer.start_link(__MODULE__, 0)
  end

  # when GenServer.call is called:
  def handle_call(:cities, _from, val) do
    cities = City.list_cities()

    # I guess this is where you could do all the citizen switching?
    # would this be where you can also pubsub over to users that are connected?
    # send back to the thingy?
    {:reply, cities, val}
  end

  def handle_call(:val, _from, val) do
    {:reply, val, val}
  end

  def init(initial_val) do
    # send message :tax to self process after 5000ms
    Process.send_after(self(), :tax, 5000)

    # returns ok tuple when u start
    {:ok, initial_val}
  end

  # when tick is sent
  def handle_info(:tax, val) do
    buildables = MayorGame.City.Details.detail_buildables()
    cities = City.list_cities_preload()

    world = MayorGame.Repo.get!(MayorGame.City.World, 1)
    # increment day
    City.update_world(world, %{day: world.day + 1})
    IO.puts("day: " <> to_string(world.day))

    for city <- cities do
      # calculate the ongoing costs for existing buildables
      operating_cost = calculate_daily_cost(city)

      # for each building in housing
      housing_stock =
        Enum.reduce(buildables.housing, 0, fn {building_type, building_options}, acc ->
          # get fits, multiply by number of buildings
          acc + building_options.fits * Map.get(city.detail, building_type)
        end)

      IO.puts(city.title <> " housing_stock: " <> to_string(housing_stock))

      # maybe build list of possible jobs and levels
      # some things are constrained, like jobs, housing.
      # but some aren't, like education (which should cost something) and entertainment
      # also housing and cost
      # and entertainment value and stuff

      # then calculate income to the city
      # if there are citizens
      if List.first(city.citizens) != nil do
        # eventually i could use Stream instead of Enum if cities is loooooong
        tax_income = calculate_taxes(city)

        updated_city_treasury =
          if city.detail.city_treasury + tax_income - operating_cost < 0 do
            0
          else
            city.detail.city_treasury + tax_income - operating_cost
          end

        # check here for if tax_income - operating_cost is less than zero
        case City.update_details(city.detail, %{
               city_treasury: updated_city_treasury
             }) do
          {:ok, _updated_details} ->
            City.update_log(
              city,
              "today's tax income:" <>
                to_string(tax_income) <>
                " operating cost: " <>
                to_string(operating_cost)
            )

          {:error, err} ->
            IO.inspect(err)
        end
      end
    end

    # send info to liveView process that manages frontEnd
    # this basically sends to every client.
    MayorGameWeb.Endpoint.broadcast!(
      "cityPubSub",
      "ping",
      val
    )

    # recurse, do it again
    Process.send_after(self(), :tax, 5000)

    # I guess this is where you could do all the citizen switching?
    # would this be where you can also pubsub over to users that are connected?
    # return noreply and val
    # increment val
    {:noreply, val + 1}
  end

  def calculate_taxes(%MayorGame.City.Info{} = city) do
    # for each citizen
    Enum.reduce(city.citizens, 0, fn citizen, acc ->
      City.update_citizens(citizen, %{age: citizen.age + 1})

      # function to spawn children

      # function to look for other cities

      # kill citizen if over this age
      if citizen.age > 36500, do: City.delete_citizens(citizen)

      1 + citizen.job + acc
    end)
  end

  def calculate_daily_cost(%MayorGame.City.Info{} = city) do
    # for each element in the details struct options
    Enum.reduce(MayorGame.City.Details.detail_buildables(), 0, fn category, acc ->
      {_categoryName, buildings} = category

      acc +
        Enum.reduce(buildings, 0, fn {building_type, building_options}, acc2 ->
          acc2 + building_options.ongoing_price * Map.get(city.detail, building_type)
        end)
    end)
  end
end
