defmodule MayorGame.Repo.Migrations.CreateAuthUsers do
  use Ecto.Migration

  def change do
    create table(:auth_users) do
      add :nickname, :string, null: false

      timestamps()
    end

    # make usernames unique
    create unique_index(:auth_users, [:nickname])
  end
end
