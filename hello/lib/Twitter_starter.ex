defmodule Hello.Starter do
    require Logger
    def start(numNode, numRequest) do
        Logger.info("Simulation started....")
        start = System.monotonic_time(unquote(:millisecond))
        coverge_progress = Task.async(fn -> converge_progress(numNode*numRequest) end)
        Process.register(coverge_progress.pid, :supervisor)
        engineStarter()
        clientStarter(numNode, numRequest)
        Task.await(coverge_progress, 10000000)
        time_spent = System.monotonic_time(unquote(:millisecond)) - start
        Logger.info("Execution time: #{time_spent}")
        :timer.sleep(3000)
      end

    def converge_progress(count)do
        if count > 0 do
          receive do
              {:Converged} -> 
                Logger.info("#{count-1} To finish")
              converge_progress(count-1)
          end
      end
    end
    def engineStarter do
      {:ok, _pid} = Hello.Engine.start_link()
    end

    def startRegistration(numNode)do
      clientLst = Enum.map(1..numNode, fn _x->
      {:ok, pid} = Hello.Client.start_link()
      handleName = "@User" <> inspect(pid)
      Process.register(pid, String.to_atom(handleName))
      handleName
      end)
    
      Enum.each(clientLst, fn x->
        GenServer.cast(Process.whereis(String.to_atom(x)), {:register, x})
            end)
    end

    def subscriber(numNode)do
    clientLst = Enum.map(1..numNode, fn _x->
    {:ok, pid} = Hello.Client.start_link()
    handleName = "@User" <> inspect(pid)
    Process.register(pid, String.to_atom(handleName))
    handleName
    end)
  
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:register, x})
          end)
          
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:subscribe, x, getUniqueLst(List.delete(clientLst, List.first(clientLst)), 2, [])})
      end)
      :timer.sleep(2000)
      GenServer.cast(Process.whereis(String.to_atom(List.first(clientLst))), {:delete, clientLst})
    end

    def clientStarter(numNode, numRequest)do
    clientLst = Enum.map(1..numNode, fn _x->
    {:ok, pid} = Hello.Client.start_link()
    handleName = "@User" <> inspect(pid)
    Process.register(pid, String.to_atom(handleName))
    handleName
    end)
    
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:register, x})
          end)
    if numNode >= 10 do
      Enum.each(getUniqueLst(clientLst, 10, []), fn x->
        GenServer.cast(Process.whereis(String.to_atom(x)), {:changestatus, x, false})
      end)
      :timer.sleep(2000)
    end
    Enum.each(clientLst, fn x->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:subscribe, x, getUniqueLst(clientLst, 2, [])})
      end)
    Enum.each(clientLst, fn x->
      Enum.each(1..numRequest, fn _y ->
      GenServer.cast(Process.whereis(String.to_atom(x)), {:tweet, "This is a sample tweet. #DOS #Project #Tweet", x})
          end)
        end)

  end  

    def getUniqueLst(clientLst, num, lst)do
      if num != 0 do
        sub = Enum.random(clientLst)
        lst = lst ++ getUniqueLst(List.delete(clientLst, sub), num-1, lst) ++ [sub]
      else
        []
      end
    end
end
