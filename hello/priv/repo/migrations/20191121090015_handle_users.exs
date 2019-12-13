defmodule Hello_Repo.Migrations.HandleUsers do
  use Ecto.Migration
  
  def change do
    create table(:user_profile) do
      add :userID, :string, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :age, :integer
      add :email, :string
      add :password, :string
      add :status, :boolean
    end
  end
end
