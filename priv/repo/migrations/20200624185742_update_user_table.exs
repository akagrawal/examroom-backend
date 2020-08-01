defmodule Examroom.Repo.Migrations.UpdateUserTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:user_data) do
      add :email, :string
      add :username, :string
      add :password, :string, size: 20
      timestamps
    end

    create unique_index(:user_data, [:username])
    create unique_index(:user_data, [:email])
  end
end
