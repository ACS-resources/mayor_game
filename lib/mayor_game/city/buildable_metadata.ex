# updating structs
defmodule MayorGame.City.BuildableMetadata do
  use Accessible

  # defaults to nil for keys without values
  defstruct [
    :priority,
    :title,
    :price,
    :fits,
    :job_level,
    :job_priority,
    :education_level,
    :capacity,
    :purchasable_reason,
    :requires,
    :produces,
    :multipliers,
    reason: [],
    enabled: false,
    purchasable: true
  ]

  @typedoc """
      this makes a type for %BuildableMetadata{} that's callable with MayorGame.City.BuildableMetadata.t()
  """
  @type t :: %__MODULE__{
          priority: integer,
          title: atom,
          price: integer | nil,
          fits: integer | nil,
          job_level: 1..5,
          job_priority: 1..5,
          education_level: 1..5,
          capacity: integer | nil,
          purchasable_reason: list(String.t()) | nil,
          purchasable: boolean,
          produces: map | nil,
          requires: map | nil,
          multipliers: map | nil,
          enabled: boolean,
          reason: list(String.t())
        }
end
