defmodule Hello.Repo.Migrations.CreateIndividuals do
  use Ecto.Migration

  def change do
    create table(:individuals) do
      add :name, :string
      add :email, :string
    

      timestamps()
    end

  end
end
