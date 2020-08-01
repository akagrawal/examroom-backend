defmodule Examroom.Utils.UserUtility do
  import Ecto.Query
  alias Examroom.Repo
  alias Models.UserData
  require Logger

  def get_user(username) do
    UserData
    |> where([u], u.username == ^username)
    |> select([u], u)
    |> Repo.all()
  end

  def add_user(user_details) do
    changeset =
      %UserData{}
      |> UserData.changeset(user_details)

    Logger.info("#{inspect(changeset)}")
    repo_response = Repo.insert(changeset)
    Logger.info("........#{inspect(repo_response)}")

    response =
      case repo_response do
        {:ok, record} ->
          Logger.info("#{inspect(record)}")
          {:ok, %{msg: "user registered successfully"}}

        {:error, %{errors: [{:email, _}]}} ->
          {:error, %{msg: "email already taken"}}

        {:error, %{errors: [{:username, _}]}} ->
          {:error, %{msg: "username already taken"}}

        {:error, reason} ->
          Logger.info("#{inspect(reason)}")
          {:error, %{msg: reason}}
      end

    response
  end

  def register_user(user_details = %{"username" => username}) do
    case get_user(username) do
      [] ->
        add_user(user_details)

      [_userlist] ->
        {:error, %{msg: "user already exists"}}
    end
  end

  def register_user(_user_details) do
    {:error, %{msg: "invalid entry"}}
  end
end
