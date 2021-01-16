defmodule MayorGame.Repo.Migrations.CreateDetails do
  use Ecto.Migration

  def change do
    create table(:details) do
      add :roads, :integer
      add :schools, :integer
      add :houses, :integer
      add :city, references(:cities, on_delete: :nothing)

      timestamps()
    end

    create index(:details, [:city])
  end
end
