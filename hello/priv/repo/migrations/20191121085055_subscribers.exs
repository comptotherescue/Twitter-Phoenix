defmodule Hello_Repo.Migrations.Subscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :userID, :string
      add :follower, :string
  end

  end
end
