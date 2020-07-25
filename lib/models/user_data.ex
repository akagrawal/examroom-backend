defmodule Models.UserData do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_data" do
    field :username, :string
    field :email, :string
    field :password,  :string
    timestamps()
  end

# APIs
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> unique_constraint(:username, name: :user_data_username_index )
    |> unique_constraint(:email, name: :user_data_email_index )
  end

end
