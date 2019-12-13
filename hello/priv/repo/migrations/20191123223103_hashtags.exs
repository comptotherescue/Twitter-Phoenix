defmodule Hello_Repo.Migrations.Hashtags do
  use Ecto.Migration

  def change do
    create table(:hashtags) do
      add :tags, :string
      add :tweet, :string
      add :handle, :string
    end
  end
end
