defmodule Hello.User do
    use Ecto.Schema
  
    schema "user" do
      field :userID, :string
      field :tweets, :string
      field :from, :string
      field :read, :integer
    end


    def changeset(user, params \\ %{}) do
        user
        |> Ecto.Changeset.cast(params, [:userID, :tweets, :read])
        |> Ecto.Changeset.validate_required([:userID, :tweets, :read])

      end
  end