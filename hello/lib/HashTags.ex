defmodule Hello.HashTags do
    use Ecto.Schema
    schema "hashtags" do
        field :tags, :string
        field :tweet, :string
        field :handle, :string
      end
  end