defmodule HelloWeb.RoomChannel do
  use HelloWeb, :channel

  def join(channel_name, _params, socket) do
    {:ok, %{channel: channel_name}, socket}
  end

  def handle_in("sign-up", %{"message" => content}, socket) do

    # IO.inspect("RECEIVED "<>content)
    # serverMsg = "Username  "<>content[0]<>"\n"<>"password "<>content[1]
    # broadcast!(socket, "room:lobby:new_message", %{content: serverMsg})
    IO.puts("SIGN IN CONTENT#################################################################")
    IO.inspect(content)
    [userName] = content
   
    client_process = Task.async(fn -> clientProcess(socket, userName) end)
    :timer.sleep(2000)
    IO.inspect(Process.whereis(String.to_atom(userName)))
    GenServer.cast(Process.whereis(String.to_atom(userName)), {:register, userName})
    IO.puts("SIGN IN CONTENT////////////////////////////////////////////////////////////////")
    
    {:reply, :ok, socket}

  end

  def clientProcess(socket, userName) do
    IO.puts("inside*************************************************")
    {:ok, pid} = Hello.Client.start_link(socket)
    IO.inspect pid
    Process.register(pid, String.to_atom(userName))
    :timer.sleep(1000000)
  end

  
  ######################## LOG IN  BELOW

  def handle_in("log-in", %{"message" => content}, socket) do

    # IO.inspect("RECEIVED "<>content)
    # serverMsg = "Username  "<>content[0]<>"\n"<>"password "<>content[1]
    # broadcast!(socket, "room:lobby:new_message", %{content: serverMsg})
    IO.puts("LOG IN CONTENT")
    IO.inspect(content)

    {:reply, :ok, socket}

  end


 ############################ LOGGED IN CODES

 ### SUBSCRIBED TO

 def handle_in("Subscribe-TO", %{"message" => content}, socket) do

  # IO.inspect("RECEIVED "<>content)
  # serverMsg = "Username  "<>content[0]<>"\n"<>"password "<>content[1]
  # broadcast!(socket, "room:lobby:new_message", %{content: serverMsg})
  IO.puts("SUBSCRIBER  LIST")
  IO.inspect(content)
  [userName, sublst] = content
  GenServer.cast(Process.whereis(String.to_atom(userName)), {:subscribe, userName, [sublst]})
  {:reply, :ok, socket}

end


def handle_in("send-Tweet", %{"message" => content}, socket) do

  # IO.inspect("RECEIVED "<>content)
  # serverMsg = "Username  "<>content[0]<>"\n"<>"password "<>content[1]
  # broadcast!(socket, "room:lobby:new_message", %{content: serverMsg})
  IO.puts("TWEET DATA")
  IO.inspect(content)
  IO.inspect(socket)
  [userName, tweet] = content
  GenServer.cast(Process.whereis(String.to_atom(userName)), {:tweet, tweet, userName})
  {:reply, :ok, socket}

end


def handle_in("fetch-Tweet", %{"message" => content}, socket) do

  IO.puts("FETCH DATA FOR USERS")
  IO.inspect(content)

   ### function return variable "response"
   response = %{"user1" => ["u1_tweet1", "u2_tweet2" ], "user2" => ["tweet1"]}
   #testResp = "it kinda workd"

   broadcast!(socket, "fetch-Tweet",  response)

  {:reply, :ok, socket}

end




end