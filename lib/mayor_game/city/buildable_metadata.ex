# updating structs
defmodule MayorGame.City.BuildableMetadata do
  use Accessible

  # defaults to nil for keys without values
  defstruct [
    :regions,
    :size,
    :category,
    :level,
    :title,
    :price,
    :building_reqs,
    :jobs,
    :education_level,
    :capacity,
    :requires,
    :produces,
    :stores,
    :multipliers,
    reason: [],
    enabled: false
  ]

  @typedoc """
      this makes a type for %BuildableMetadata{} that's callable with MayorGame.City.BuildableMetadata.t()
  """
  @type t :: %__MODULE__{
          regions: list(atom),
          size: integer,
          category: atom,
          level: integer,
          title: atom,
          price: integer | nil,
          building_reqs: map | nil,
          jobs: integer | nil,
          education_level: 1..5,
          capacity: integer | nil,
          produces: map | nil,
          stores: map | nil,
          requires: map | nil,
          multipliers: map | nil,
          enabled: boolean,
          reason: list(String.t())
        }
end
