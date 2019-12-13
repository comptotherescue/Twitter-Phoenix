import Ecto.Changeset
defmodule Hello.Client do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__,[])
    end

    def init(state)do 
        {:ok, state}
    end

    def handle_cast({:register, handleName}, state)do
        GenServer.cast(:E2 ,{:register, handleName, handleName, "UFL", 25, "abc@ufl.edu", "abc"})
        {:noreply, state}
    end

    def handle_cast({:delete, handleLst}, state)do
        Enum.each(handleLst, fn handleName -> 
        GenServer.cast(:E2, {:delete, handleName})
        end)
        {:noreply, state}
    end

    def handle_cast({:hashtags, hashtag, handleName}, state)do
        GenServer.cast(:E2, {:hashtags, hashtag, handleName})
        {:noreply, state}
    end

    def handle_cast({:hashtagsrec, hashlst}, state)do
        IO.inspect hashlst
        {:noreply, state}
    end

    def handle_cast({:tweet, tweet, handleName}, state)do
        IO.puts "In here tweet"
        GenServer.cast(self(), {:changestatus, handleName, true})
        :timer.sleep(100)
        GenServer.cast(self(), {:getMessages, handleName})
        GenServer.cast(:E2, {:tweet, handleName, tweet})
        {:noreply, state}
    end

    def handle_cast({:tweetrec, tweet, handleName}, state)do
         lst = state
         lst = lst ++ [tweet]
         state = lst
        {:noreply, state}
    end

    def handle_cast({:subscribe, handleName, subLst}, state)do
        Enum.each(subLst, fn x ->
            GenServer.cast(:E2, {:subscribe, x, handleName})
        end)
        {:noreply, state}
    end

    def handle_cast({:retweet, handleName}, state)do
        tweet = List.first(state)
        #IO.puts tweet
        if tweet != nil do
            tweet = "Retweet: " <> tweet
            GenServer.cast(:E2, {:retweet, handleName, tweet})
        end
        {:noreply, state}
    end

    def handle_cast({:changestatus, handleName, flag}, state)do
        GenServer.cast(:E2, {:updatestatus, handleName, flag})
        {:noreply, state}
    end

    def handle_cast({:getMessages, handleName}, state)do
        GenServer.cast(:E2, {:getOfflineTweets, handleName})
        {:noreply, state}
    end
end