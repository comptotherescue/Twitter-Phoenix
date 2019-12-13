defmodule Hello.HandleUsers do
    use Ecto.Schema
    
    @primary_key {:userID, :string, autogenerate: false}
    schema "user_profile" do
        field :first_name, :string
        field :last_name, :string
        field :age, :integer
        field :email, :string
        field :password, :string
        field :status, :boolean
      end
  end