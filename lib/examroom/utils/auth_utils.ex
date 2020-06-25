defmodule Examroom.Utils.AuthUtils do
  import Ecto.Query
  alias Examroom.Repo
  alias Models.UserData
  require Logger
  def user_registered?(%{"userid" => userid}) do
    useridlist =
      UserData
      |> where([u], u.userid==^userid)
      |> select([u], [u.userid])
      |> Repo.all
      case useridlist do
        [_userid] ->
          true
        [] ->
          false
        _ ->
          {:error, "multiple users with same id"}
      end
  end
  def user_registered?(_user_details), do: {:error, :does_not_exist}
end
