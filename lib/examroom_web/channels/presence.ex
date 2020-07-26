defmodule ExamroomWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence, otp_app: :examroom,
                        pubsub_server: Examroom.PubSub

@doc """
Overrides the default fetch. Instead of returning the full users list,
we only return the count of open sockets.
This map is what will be returned to the frontend.
"""
def fetch(_topic, entries) do
  %{
    "viewers" => %{"count" => count_presences(entries, "viewers")},
    "users" => %{"count" => count_presences(entries, "users")}
  }
end

defp count_presences(entries, key) do
  case get_in(entries, [key, :metas]) do
    nil -> 0
    metas -> length(metas)
  end
end

end
