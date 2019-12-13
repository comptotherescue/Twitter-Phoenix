
import Ecto.Query
defmodule Hello.Engine do
    use GenServer
    def start_link() do
        GenServer.start_link(__MODULE__,"")
    end
    def init(state)do 
        Process.register(self(), :E2)
        {:ok, state}
    end

    def handle_cast({:register, handleName, first_name, last_name, age, email, pass}, state) do
        query = from u in "user_profile", where: u.userID == ^handleName, select: u.status
        lst = Hello.Repo.all(query)
        IO.inspect lst
        if lst == [] do
            user = %Hello.HandleUsers{userID: handleName, first_name: first_name, last_name: last_name,
                     age: age, email: email, password: pass, status: true}
            Hello.Repo.insert(user)
        end
        {:noreply, state}
    end

    def handle_cast({:delete, handleName}, state) do
        {num, _} = from(x in "user_profile", where: x.userID == ^handleName) |> Hello.Repo.delete_all
        {:noreply, state}
    end

    def handle_cast({:subscribe, handleName, tofollow}, state)do
        subscriber = %Hello.Subscribers{userID: tofollow, follower: handleName}
        Hello.Repo.insert(subscriber)
        {:noreply, state}
    end

    def handle_cast({:getOfflineTweets, handleName}, state)do
        query = from u in "user", where: u.userID == ^handleName and u.read == 0, select: u.tweets
        lst = Hello.Repo.all(query)
        if lst != [] do
            query2 = from u in "user_profile", where: u.userID == ^handleName, select: u.status
            lst2 = Hello.Repo.all(query2)
            if lst2 != [] do
                if List.first(lst2) == true do
                    Enum.each(lst, fn x->
                        GenServer.cast(Process.whereis(String.to_atom(handleName)),{:tweetrec, x, handleName})
                    end)
                    IO.puts "Online again, sending recorded tweets #{lst}"
                    from(u in "user", where: u.userID == ^handleName, select: u.userID)
                    |> Hello.Repo.update_all(set: [read: 1])
                    end
                end
            end
        {:noreply, state}
    end

    def handle_cast({:tweet, handleName, tweet}, state)do
        #IO.puts handleName
        rec = %Hello.User{userID: handleName, tweets: tweet, read: 1}
        Hello.Repo.insert(rec)
        mentionLst = parseTweet(tweet, handleName)
        query = from(u in "subscribers", where: u.userID == ^handleName, select: u.follower)
        lst =  Hello.Repo.all(query)
        tweetfun(lst, tweet, handleName)
        if mentionLst != []do
            tweet = "Mentioned by: " <> handleName <> " Tweet: " <> tweet
            tweetfun(mentionLst, tweet, handleName) 
        end
        send(Process.whereis(:supervisor),{:Converged})
        {:noreply, state}
    end

    def handle_cast({:retweet, handleName, tweet}, state)do
        rec = %Hello.User{userID: handleName, tweets: tweet, read: 1}
        Hello.Repo.insert(rec)
        query = from(u in "subscribers", where: u.userID == ^handleName, select: u.follower)
        lst = Hello.Repo.all(query)
        tweetfun(lst, tweet, handleName)
        {:noreply, state}
    end

    def handle_cast({:hashtags, hashtag, handleName}, state)do
        query = from(u in "hashtags", where: u.tags == ^hashtag, select: {u.tweet, u.handle})
        lst = Hello.Repo.all(query)
        GenServer.cast(Process.whereis(String.to_atom(handleName)),{:hashtagsrec, lst})
        {:noreply, state}
    end
    
    def handle_cast({:updatestatus, handleName, flag}, state)do
        from(u in "user_profile", where: u.userID == ^handleName, select: u.userID)
        |> Hello.Repo.update_all(set: [status: flag])
        {:noreply, state}
    end

    def tweetfun(lst, tweet, handleName)do
        Enum.each(lst, fn x -> 
            query2 = from u in "user_profile", where: u.userID == ^x, select: u.status
            lst = Hello.Repo.all(query2)
            if lst != [] do
                if List.first(lst) == true do
                    record = %Hello.User{userID: x, tweets: tweet, read: 1}
                    Hello.Repo.insert(record)
                    GenServer.cast(Process.whereis(String.to_atom(x)),{:tweetrec, tweet, handleName})
                else
                    record = %Hello.User{userID: x, tweets: tweet, read: 0}
                    Hello.Repo.insert(record)
                end
        end
        end)
    end

    def parseTweet(tweetStr, handleName) do
        wordLst = String.split(tweetStr, " ")
        mentionLst = Enum.reduce(wordLst,[],fn(x, acc)-> 
            if String.at(x, 0) == "#" do
                tag = %Hello.HashTags{tags: x, tweet: tweetStr, handle: handleName}
                Hello.Repo.insert(tag)
            end
            if String.at(x, 0) == "@"do 
                 acc ++ [x]
            else
                acc
            end
            
        end)
        mentionLst
    end
end