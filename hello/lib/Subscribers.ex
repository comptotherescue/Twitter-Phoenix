defmodule Hello.Subscribers do
    use Ecto.Schema
    
    schema "subscribers" do
        field :userID, :string
        field :follower, :string
      end
  end