defmodule Examroom.Repo do
  use(Ecto.Repo, [otp_app: :examroom, adapter: Ecto.Adapters.Postgres])
end
