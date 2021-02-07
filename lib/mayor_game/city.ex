defmodule MayorGame.City do
  @moduledoc """
  The City context.
  """

  import Ecto.Query, warn: false
  alias MayorGame.Repo

  alias MayorGame.City.Info

  @doc """
  Returns the list of cities.

  ## Examples

      iex> list_cities()
      [%Info{}, ...]

  """
  def list_cities do
    Repo.all(Info)
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
      {:ok, created_city} ->
        detail = %{
          houses: 0,
          schools: 0,
          roads: 0,
          libraries: 0,
          parks: 0,
          universities: 0,
          airports: 0,
          office_buildings: 0,
          city_treasury: 500,
          info_id: created_city.id
        }

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
  updates log. Expects the info struct & just a single string.

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
    if length(updated_log) > 50 do
      updated_log |> Enum.reverse() |> tl() |> Enum.reverse()
    end

    info
    |> Info.changeset(%{logs: updated_log})
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

  alias MayorGame.City.Citizens

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
    %Citizens{}
    |> Citizens.changeset(attrs)
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

  alias MayorGame.City.Details

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
  def update_details(%Details{} = details, attrs) do
    details
    |> Details.changeset(attrs)
    |> Repo.update()
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
end
