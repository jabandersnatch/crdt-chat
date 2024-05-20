defmodule Chatroom.Chat do
  @moduledoc """
  Chat module for sending and receiving messages across nodes using Treedoc CRDT.
  """

  alias Crdt.Treedoc

  def start_link(_) do
    Agent.start_link(fn -> Treedoc.new() end, name: :treedoc)
  end

  def send_message(recipient, message, :insert) do
    spawn_task(__MODULE__, :insert, recipient, [message])
  end
  
  def send_message(recipient, message, :delete) do
    spawn_task(__MODULE__, :delete, recipient, [message])
  end

  def insert({pos_id, message}) do
    IO.puts("Inserting message: #{message}")
    Agent.update(:treedoc, &Treedoc.insert(&1, {pos_id, message}))
  end

  def delete(pos_id) do
    IO.puts("Deleting message at position ID: #{pos_id}")
    Agent.update(:treedoc, &Treedoc.delete(&1, pos_id))
  end

  def print_all_messages() do
    Agent.get(:treedoc, &Treedoc.print_all_messages(&1))
  end

  def print_actual() do
    Agent.get(:treedoc, &Treedoc.print_actual(&1))
  end

  def spawn_task(module, fun, recipient, args) do
    recipient
    |> remote_supervisor()
    |> Task.Supervisor.async(module, fun, args)
    |> Task.await()
  end

  defp remote_supervisor(recipient) do
    {Chatroom.TaskSupervisor, recipient}
  end

  def join_chatroom() do
    start_link(:ok)
    IO.puts("Welcome to the chatroom")
    IO.puts("You can insert, delete, print_all_messages and print_actual")

    loop()
  end

  defp loop() do
    IO.puts("Select the operation you want to perform:")
    IO.puts("1. Insert")
    IO.puts("2. Delete")
    IO.puts("3. Print all messages")
    IO.puts("4. Print actual")
    IO.puts("5. Exit")

    operation = IO.gets("Enter the operation you want to perform: ") |> String.trim()

    case operation do
      "1" ->
        message = IO.gets("Enter the message: ") |> String.trim()
        pos_id = :os.system_time()
        insert({pos_id, message})
        Node.list()
        |> Enum.each(fn recipient ->
          send_message(recipient, {pos_id, message}, :insert)
    end)
        IO.puts("Message inserted.")
        loop()

      "2" ->
        pos_id = IO.gets("Enter the position ID to delete: ") |> String.trim() |> String.to_integer()
        delete(pos_id)
        Node.list()
        |> Enum.each(fn recipient ->
          send_message(recipient, pos_id, :delete)
    end)
        IO.puts("Message deleted.")
        loop()

      "3" ->
        print_all_messages()
        loop()

      "4" ->
        print_actual()
        loop()

      "5" ->
        IO.puts("Exiting chatroom.")
        :ok

      _ ->
        IO.puts("Invalid operation. Please try again.")
        loop()
    end
  end
end
