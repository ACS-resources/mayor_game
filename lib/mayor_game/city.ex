defmodule MayorGame.City do
  @moduledoc """
  The City context.
  """

  import Ecto.Query, warn: false
  alias MayorGame.Repo

  alias MayorGame.City.{Details, Info, Citizens, World, Buildable}

  @doc """
  Returns the list of cities.

  ## Examples

      iex> list_cities()
      [%Info{}, ...]

  """
  def list_cities do
    Repo.all(Info)
  end

  def list_cities_preload do
    Repo.all(Info) |> Repo.preload([:citizens, :user, :detail])
  end

  @doc """
  Gets a single info.

  Raises `Ecto.NoResultsError` if the Info does not exist.

  ## Examples

      iex> get_info!(123)
      %Info{}

      iex> get_info!(456)
      ** (Ecto.NoResultsError)

  """
  def get_info!(id), do: Repo.get!(Info, id)

  def get_info_by_title!(title), do: Repo.get_by!(Info, title: title)

  @doc """
  Creates a info. which is a city

  ## Examples

      iex> create_info(%{field: value})
      {:ok, %Info{}}

      iex> create_info(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_info(attrs \\ %{}) do
    %Info{}
    |> Info.changeset(attrs)
    |> Repo.insert()
  end

  # hmm. I should probably figure out a way to make this return the city, not the details.
  # currently this returns the %Details struct
  def create_city(attrs \\ %{}) do
    case create_info(attrs) do
      # if city built successfully, automatically build Details with it's id
      # update this so these fields are automatically generated
      {:ok, created_city} ->
        buildables = Map.new(Details.buildables_list(), fn buildable -> {buildable, []} end)

        detail = Map.merge(buildables, %{city_treasury: 500, info_id: created_city.id})

        # and create a detail in the DB, tied to this city
        case create_details(detail) do
          {:ok, _} ->
            # return the city created
            {:ok, created_city}

          {:error, err} ->
            {:error, err}
        end

      {:error, err} ->
        {:error, err}
    end
  end

  # ok so i think this is the closest thing I need to update the log
  @doc """
  Updates a info.

  ## Examples

      iex> update_info(info, %{field: new_value})
      {:ok, %Info{}}

      iex> update_info(info, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_info(%Info{} = info, attrs) do
    info
    |> Info.changeset(attrs)
    |> Repo.update()
  end

  # might not need to type guard here because DB does it; but
  @doc """
  updates log. Expects the info(city) struct & a single string.

  ## Examples
      iex> update_log(info, "string to add to log")
      {:ok, %Info{}}

      iex> update_info(info, bad_value)
      {:error, %Ecto.Changeset{}}
  """
  def update_log(%Info{} = info, log_item) do
    # add new item to head of list
    updated_log = [log_item | info.logs]

    # if list is longer than 50, remove last item
    limited_log =
      if length(updated_log) > 50 do
        updated_log |> Enum.reverse() |> tl() |> Enum.reverse()
      else
        updated_log
      end

    info
    |> Info.changeset(%{logs: limited_log})
    |> Repo.update()
  end

  @doc """
  Deletes a info.

  ## Examples

      iex> delete_info(info)
      {:ok, %Info{}}

      iex> delete_info(info)
      {:error, %Ecto.Changeset{}}

  """
  def delete_info(%Info{} = info) do
    Repo.delete(info)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking info changes.

  ## Examples

      iex> change_info(info)
      %Ecto.Changeset{data: %Info{}}

  """
  def change_info(%Info{} = info, attrs \\ %{}) do
    Info.changeset(info, attrs)
  end

  # ###############################################
  # CITIZENS CITIZENS CITIZENS CITIZENS CITIZENS CITIZENS
  # ###############################################

  @doc """
  Returns the list of citizens.

  ## Examples

      iex> list_citizens()
      [%Citizens{}, ...]

  """
  def list_citizens do
    Repo.all(Citizens)
  end

  def list_citizens_preload do
    Repo.all(Citizens) |> Repo.preload([:info])
  end

  @doc """
  Gets a single citizens.

  Raises `Ecto.NoResultsError` if the Citizens does not exist.

  ## Examples

      iex> get_citizens!(123)
      %Citizens{}

      iex> get_citizens!(456)
      ** (Ecto.NoResultsError)

  """
  def get_citizens!(id), do: Repo.get!(Citizens, id)

  @doc """
  Creates a citizens.

  ## Examples

      iex> create_citizens(%{field: value})
      {:ok, %Citizens{}}

      iex> create_citizens(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_citizens(attrs \\ %{}) do
    # this makes a map with random values that add up to 1
    random_preferences =
      Enum.reduce(Citizens.decision_factors(), %{preference_map: %{}, room_taken: 0}, fn x, acc ->
        value =
          if x == List.last(Citizens.decision_factors()),
            do: (1 - acc.room_taken) |> Float.round(2),
            else: (:rand.uniform() * (1 - acc.room_taken)) |> Float.round(2)

        %{
          preference_map: Map.put(acc.preference_map, to_string(x), value),
          room_taken: acc.room_taken + value
        }
      end)

    IO.inspect(random_preferences.preference_map)

    # Map.new(Citizens.decision_factors(), fn x ->
    #   {to_string(x), :rand.uniform() |> Float.round(2)}
    # end)

    attrs_plus_preferences = Map.put(attrs, :preferences, random_preferences.preference_map)

    %Citizens{}
    |> Citizens.changeset(attrs_plus_preferences)
    |> Repo.insert()
  end

  @doc """
  Updates a citizens.

  ## Examples

      iex> update_citizens(citizens, %{field: new_value})
      {:ok, %Citizens{}}

      iex> update_citizens(citizens, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_citizens(%Citizens{} = citizens, attrs) do
    citizens
    |> Citizens.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a citizens.

  ## Examples

      iex> delete_citizens(citizens)
      {:ok, %Citizens{}}

      iex> delete_citizens(citizens)
      {:error, %Ecto.Changeset{}}

  """
  def delete_citizens(%Citizens{} = citizens) do
    Repo.delete(citizens)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking citizens changes.

  ## Examples

      iex> change_citizens(citizens)
      %Ecto.Changeset{data: %Citizens{}}

  """
  def change_citizens(%Citizens{} = citizens, attrs \\ %{}) do
    Citizens.changeset(citizens, attrs)
  end

  # ###############################################
  # DETAILS DETAILS DETAILS DETAILS DETAILS DETAILS DETAILS
  # ###############################################

  @doc """
  Returns the list of details.

  ## Examples

      iex> list_details()
      [%Details{}, ...]

  """
  def list_details do
    Repo.all(Details)
  end

  @doc """
  Gets a single details.

  Raises `Ecto.NoResultsError` if the Details does not exist.

  ## Examples

      iex> get_details!(123)
      %Details{}

      iex> get_details!(456)
      ** (Ecto.NoResultsError)

  """
  def get_details!(id), do: Repo.get!(Details, id)

  @doc """
  Creates a details.

  ## Examples

      iex> create_details(%{field: value})
      {:ok, %Details{}}

      iex> create_details(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_details(attrs \\ %{}) do
    %Details{}
    |> Details.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a details.

  ## Examples

      iex> update_details(details, %{field: new_value})
      {:ok, %Details{}}

      iex> update_details(details, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_details(%Details{} = details, attrs \\ %{}) do
    details
    |> Details.changeset(attrs)
    |> Repo.update()
  end

  # ###############################################
  # BUILDABLES
  # ###############################################

  @doc """
  purchase 1 of a given building
  expects (details, :atom of building, pric)

  ## Examples

      iex> purchase_buildable(details, :schools, 300)
      {:ok, %Details{}}

  """
  def purchase_buildable(%Details{} = details, field_to_purchase, purchase_price) do
    # price = purchase_price

    # how many building are there rn
    # IO.inspect(details[field_to_purchase])
    # {:ok, current_value} = Map.fetch(details, field_to_purchase)

    detail_attrs = %{city_treasury: details.city_treasury - purchase_price}

    buildable_attrs = %{enabled: true, reason: [], upgrades: %{}}

    uhhh =
      details
      |> Ecto.build_assoc(field_to_purchase, buildable_attrs)

    IO.inspect(uhhh, label: "built assoc in purchase flow")

    # Map.update!(details, field_to_purchase, &(&1 + 1))

    # insert adds an id when inserted into DB?
    purchase =
      details
      |> Details.changeset(detail_attrs)
      |> Ecto.Changeset.validate_number(:city_treasury, greater_than: 0)
      |> Repo.update()

    case purchase do
      {:ok, _result} -> Repo.insert(uhhh)
      {:error} -> IO.puts("uh oh, purchase error inside purchase_buildabble")
      _ -> "Catch all"
    end

    # %Buildable{}
    # |> Buildable.changeset(buildable_attrs)
    # |> Ecto.Changeset.put_assoc(:details, details)
    # |> Repo.insert()
  end

  @doc """
  remove 1 of a given building
  expects (details, :atom of building, building id)

  ## Examples

      iex> purchase_details(details, :schools, id##)
      {:ok, %Details{}}

  """
  def demolish_buildable(%Details{} = details, buildable_to_demolish, buildable_id) do
    # how many building are there rn
    # {:ok, current_value} = Map.fetch(details, buildable_to_demolish)

    # updated_list =
    #   current_value
    #   |> Enum.reject(fn buildable -> buildable.id == buildable_id end)

    buildable_to_demolish_atom = String.to_existing_atom(buildable_to_demolish)

    # posts = Repo.all(from p in Details, where: p.id == buildable_id)

    # this works
    # get_assoc = Repo.all(Ecto.assoc(details, buildable_to_demolish_atom))

    buildable_to_delete =
      Repo.get_by!(Ecto.assoc(details, buildable_to_demolish_atom), id: buildable_id)

    # Ecto.get_meta(user, :prefix)

    # buildable_to_delete =
    #   Repo.get_by!({buildable_to_demolish, Buildable},
    #     details_id: details.id,
    #     id: buildable_id
    #   )

    Repo.delete(buildable_to_delete)

    # attrs = %{buildable_to_demolish => updated_list}

    # Map.update!(details, field_to_purchase, &(&1 + 1))

    # Ecto.Changeset.put_change(:addresses, addresses)

    # details
    # # |> Details.changeset(attrs)
    # |> Ecto.Changeset.change()
    # |> Ecto.Changeset.put_change(buildable_to_demolish, updated_list)
    # |> Repo.update()
  end

  def update_buildable(
        %Details{} = details,
        buildable_to_update,
        buildable_id,
        attrs_to_update \\ %{}
      ) do
    # detail = Repo.get!(Details, detail.id)
    # {:ok, current_value} = Map.fetch(detail, buildable_to_update)
    # IO.inspect(current_value, label: "current_value")

    buildable_to_update_atom =
      if is_atom(buildable_to_update),
        do: buildable_to_update,
        else: String.to_existing_atom(buildable_to_update)

    buildable_to_change =
      Repo.get_by!(Ecto.assoc(details, buildable_to_update_atom), id: buildable_id)

    # ok, this is right
    # updated_list =
    #   current_value
    #   |> Enum.map(fn buildable ->
    #     if buildable.id == buildable_id,
    #       do: buildable |> struct(attrs_to_update),
    #       else: buildable
    #   end)

    # IO.inspect(updated_list, label: "updated_list")

    # attrs =
    #   Map.new([
    #     {field_to_update, updated_list},
    #     {:city_treasury, detail.city_treasury}
    #   ])

    # IO.inspect(attrs)

    # details_changeset =
    #   Map.get(detail, field_to_update)
    #   |> Ecto.Changeset.change(updated_list)

    # changeset =
    #   detail
    #   |> Ecto.Changeset.change()
    #   |> Ecto.Changeset.put_embed(field_to_update, details_changeset)

    # buildable_changeset = Ecto.Changeset.change(Map.get(detail, field_to_update), updated_list)

    # IO.inspect(buildable_changeset, label: "inside update_buildable")

    # Map.update!(details, field_to_purchase, &(&1 + 1))

    # Ecto.Changeset.put_change(:addresses, addresses)

    # changeset = Details.changeset(detail, %{field_to_update => updated_list})

    # changeset =
    #   detail
    #   |> Ecto.Changeset.change()
    #   |> Ecto.Changeset.put_embed(field_to_update, updated_list)

    # IO.inspect(changeset, label: "changeset")
    # results =
    #   changeset
    #   |> Repo.update!()

    # detail
    # |> Details.changeset(attrs)
    # |> Ecto.Changeset.validate_number(:city_treasury, greater_than: 0)
    results =
      buildable_to_change
      |> Buildable.changeset(attrs_to_update)
      |> Repo.update()

    IO.inspect(results, label: "results")
  end

  @doc """
  Deletes a details.

  ## Examples

      iex> delete_details(details)
      {:ok, %Details{}}

      iex> delete_details(details)
      {:error, %Ecto.Changeset{}}

  """
  def delete_details(%Details{} = details) do
    Repo.delete(details)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking details changes.

  ## Examples

      iex> change_details(details)
      %Ecto.Changeset{data: %Details{}}

  """
  def change_details(%Details{} = details, attrs \\ %{}) do
    Details.changeset(details, attrs)
  end

  # WORLD

  def create_world(attrs \\ %{}) do
    %World{}
    |> World.changeset(attrs)
    |> Repo.insert()
  end

  def update_world(%World{} = world, attrs \\ %{}) do
    world
    |> World.changeset(attrs)
    |> Repo.update()
  end
end
