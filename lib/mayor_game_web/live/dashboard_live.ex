defmodule MayorGameWeb.DashboardLive do
  require Logger

  use Phoenix.LiveView, container: {:div, class: "liveview-container"}
  # don't need this because you get it in DashboardView?
  # use Phoenix.HTML

  alias MayorGame.City
  # alias MayorGame.City.Town
  alias MayorGameWeb.DashboardView
  # alias MayorGame.Repo
  # alias Ecto.Changeset

  def render(assigns) do
    DashboardView.render("show.html", assigns)
  end

  # if user is logged in:
  def mount(_params, %{"current_user" => current_user}, socket) do
    MayorGameWeb.Endpoint.subscribe("cityPubSub")

    {:ok,
     socket
     |> assign(current_user: current_user |> MayorGame.Repo.preload(:town))
     |> assign_cities()}
  end

  # if user is not logged in
  def mount(_params, _session, socket) do
    MayorGameWeb.Endpoint.subscribe("cityPubSub")

    {:ok,
     socket
     |> assign_cities()}
  end

  def handle_info(%{event: "ping", payload: _world}, socket) do
    if Map.has_key?(socket.assigns, :current_user) do
      IO.inspect('pinged in dashboard')

      IO.inspect(
        MayorGame.Auth.get_user!(socket.assigns.current_user.id)
        |> MayorGame.Repo.preload(:town)
      )

      {:noreply,
       socket
       |> assign(
         current_user:
           MayorGame.Auth.get_user!(socket.assigns.current_user.id)
           |> MayorGame.Repo.preload(:town)
       )
       |> assign_cities()}
    else
      {:noreply,
       socket
       |> assign_cities()}
    end
  end

  # def handle_info(%{event: "ping", :payload _world, "current_user" => current_user}, socket) do
  #   {:noreply, socket |> assign_cities()}
  # end

  # this handles different events
  def handle_event(
        "add_citizen",
        %{"name" => content, "userid" => user_id, "city_id" => city_id},
        # pull these variables out of the socket
        assigns = socket
      ) do
    # IO.inspect(get_user(socket, session))

    if socket.assigns.current_user.id == 1 do
      case City.create_citizens(%{
             town_id: city_id,
             money: 5,
             education: 0,
             age: 0,
             has_car: false,
             has_job: false,
             last_moved: socket.assigns.world.day
           }) do
        # pattern match to assign new_citizen to what's returned from City.create_citizens
        {:ok, _updated_citizens} ->
          IO.puts("updated 1 citizen")

        {:error, err} ->
          Logger.error(inspect(err))
      end
    end

    {:noreply, socket |> assign_cities()}
  end

  # Assign all cities as the cities list. Maybe I should figure out a way to only show cities for that user.
  # at some point should sort by number of citizens
  defp assign_cities(socket) do
    cities = City.list_cities() |> Enum.sort_by(& &1.id)
    world = MayorGame.Repo.get!(MayorGame.City.World, 1)

    # cities_preloaded =
    #   Enum.map(cities, fn city ->
    #     MayorGame.Repo.preload(city, :details)
    #   end)

    # should move pollution out of details
    # and maybe citizen count?

    # MayorGame.Repo.preload(city, details: [:pollution])
    socket
    |> assign(:cities, cities)
    |> assign(:world, world)
  end
end
