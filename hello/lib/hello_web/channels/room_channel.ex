
import Ecto.Query
defmodule HelloWeb.RoomChannel do
  use HelloWeb, :channel

  def join(channel_name, _params, socket) do
    {:ok, %{channel: channel_name}, socket}
  end

  def handle_in("register", %{"message" => content}, socket) do
    [userName, pass] = content
    user = %Hello.HandleUsers{userID: userName, first_name: userName, last_name: "None",
                     age: 25, email: "@ufl.edu", password: pass, status: true}
            Hello.Repo.insert(user)
    
    {:reply, :ok, socket}

  end

  def clientProcess( userName) do
    {:ok, pid} = Hello.Client.start_link()
    Process.register(pid, String.to_atom(userName))
    :timer.sleep(1000000)
  end

  

  def handle_in("log-in", %{"message" => content}, socket) do
    [userName, password] = content
    query = from u in "user_profile", where: u.userID == ^userName , select: u.password
     lst = Hello.Repo.all(query)
    if lst == [password]do
      from(u in "user_profile", where: u.userID == ^userName, select: u.userID)
                    |> Hello.Repo.update_all(set: [status: true])
      push(socket, "Log-in",  %{"status"=>1})
      {:reply, :ok, socket}
    else
      push(socket, "Log-in",  %{"status"=>0})
      {:reply, :error, socket}
    end

  end


 def handle_in("Subscribe-TO", %{"message" => content}, socket) do

  [userName, sublst] = content
  if is_nil(Process.whereis(String.to_atom(userName)))do
    client_process = Task.async(fn -> clientProcess(userName) end)
    :timer.sleep(2000)
  end
  GenServer.cast(Process.whereis(String.to_atom(userName)), {:subscribe, userName, [sublst]})
  {:reply, :ok, socket}

end


def handle_in("send-Tweet", %{"message" => content}, socket) do

  [userName, tweet] = content
  if is_nil(Process.whereis(String.to_atom(userName)))do
    client_process = Task.async(fn -> clientProcess(userName) end)
    :timer.sleep(2000)
  end
  GenServer.cast(Process.whereis(String.to_atom(userName)), {:tweet, tweet, userName})
  :timer.sleep(1000)
  {:reply, :ok, socket}

end


def handle_in("re-Tweet", %{"message" => content}, socket) do
  [userName] = content
  if is_nil(Process.whereis(String.to_atom(userName)))do
    client_process = Task.async(fn -> clientProcess(userName) end)
    :timer.sleep(2000)
  end
  GenServer.cast(Process.whereis(String.to_atom(userName)), {:retweet, userName})
  {:reply, :ok, socket}

end

def handle_in("logout", %{"message" => content}, socket) do
  [userName] = content
  from(u in "user_profile", where: u.userID == ^userName, select: u.userID)
  |> Hello.Repo.update_all(set: [status: false])
  {:reply, :ok, socket}

end


def handle_in("delete", %{"message" => content}, socket) do
  [userName] = content
  {num, _} = from(x in "user_profile", where: x.userID == ^userName) |> Hello.Repo.delete_all
  {num, _} = from(x in "user", where: x.userID == ^userName) |> Hello.Repo.delete_all
  {num, _} = from(x in "subscribers", where: x.userID == ^userName) |> Hello.Repo.delete_all
  
  {:reply, :ok, socket}

end

def handle_in("fetch-hash", %{"message" => content}, socket) do
  [hashtag] = content
   query = from u in "hashtags", where: u.tags == ^hashtag, select: [u.handle,u.tweet]
   lst = Hello.Repo.all(query)


   push(socket, "fetch-hash",  %{"Tweets"=>lst})

  {:reply, :ok, socket}

end

def handle_in("fetch-Tweet", %{"message" => content}, socket) do
  [userName] = content
   ### function return variable "response"
   query = from u in "user", where: u.userID == ^userName and not is_nil(u.from), select: [u.from,u.tweets]
   lst = Hello.Repo.all(query)
   from(u in "user", where: u.userID == ^userName, select: u.userID)
                    |> Hello.Repo.update_all(set: [read: 1])
  

   push(socket, "fetch-Tweet",  %{"Tweets"=>lst})

  {:reply, :ok, socket}

end




end
