defmodule Models.UserData do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_data" do
    field :userid, :string
    field :username, :string
    field :password,  :string
    timestamps()
  end

# APIs
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:userid, :username, :password])
  end

end
