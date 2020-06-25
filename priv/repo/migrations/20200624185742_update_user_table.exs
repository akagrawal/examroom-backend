defmodule Examroom.Repo.Migrations.UpdateUserTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:user_data) do
      add :userid, :string
      add :username, :string
      add :password, :string, size: 20
      timestamps
    end
  end
end
