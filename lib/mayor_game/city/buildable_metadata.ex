# updating structs
defmodule MayorGame.City.BuildableMetadata do
  # defaults to nil for keys without values
  defstruct [
    :price,
    :fits,
    :daily_cost,
    :area_required,
    :energy_required,
    :jobs,
    :job_level,
    :education_level,
    :capacity,
    :sprawl,
    :area,
    :energy,
    :pollution,
    :region_energy_multipliers,
    :season_energy_multipliers,
    :upgrades,
    :purchasable_reason,
    purchasable: true
  ]

  @typedoc """
      this makes a type for %BuildableMetadata{} that's callable with MayorGame.City.BuildableMetadata.t()
  """
  @type t :: %__MODULE__{
          price: integer | nil,
          fits: integer | nil,
          daily_cost: integer | nil,
          area_required: integer | nil,
          energy_required: integer | nil,
          jobs: integer | nil,
          job_level: 1..5,
          education_level: 1..5,
          capacity: integer | nil,
          sprawl: integer | nil,
          area: integer | nil,
          energy: integer | nil,
          pollution: integer | nil,
          region_energy_multipliers: map | nil,
          season_energy_multipliers: map | nil,
          upgrades: map() | nil,
          purchasable_reason: list(String.t()) | nil,
          purchasable: boolean
        }
end
