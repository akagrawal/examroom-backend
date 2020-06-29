defmodule Examroom.Utils.AuthUtils do
  alias Examroom.Utils.UserUtility
  require Logger
  def user_registered?(%{"userid" => userid}) do
    useridlist = UserUtility.get_user(userid)
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
