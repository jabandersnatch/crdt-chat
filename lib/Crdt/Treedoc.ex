# lib/crdt/treedoc.ex
defmodule Crdt.Treedoc do
  @moduledoc """
  Treedoc CRDT implementation using a single map to store and mark deleted messages.
  """

  defstruct doc: %{}

  @type pos_id :: integer()
  @type msg :: String.t()
  @type t :: %__MODULE__{doc: map()}

  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @spec insert(t(), {pos_id, msg}) :: t()
  def insert(%__MODULE__{doc: doc} = state, {pos_id, msg}) do
    %{state | doc: Map.put(doc, pos_id, msg)}
  end

  @spec delete(t(), pos_id) :: t()
  def delete(%__MODULE__{doc: doc} = state, pos_id) do
    if Map.has_key?(doc, pos_id) do
      %{state | doc: Map.put(doc, pos_id, :deleted)}
    else
      state
    end
  end

  @spec print_all_messages(t()) :: :ok
  def print_all_messages(%__MODULE__{doc: doc}) do
    doc
    |> Enum.each(fn {pos_id, msg} ->
      case msg do
        :deleted -> IO.puts("[#{pos_id}] (deleted)")
        _ -> IO.puts("[#{pos_id}] #{msg}")
      end
    end)
  end

  @spec print_actual(t()) :: :ok
  def print_actual(%__MODULE__{doc: doc}) do
    doc
    |> Enum.reject(fn {_pos_id, msg} -> msg == :deleted end)
    |> Enum.each(fn {pos_id, msg} ->
      IO.puts("[#{pos_id}] #{msg}")
    end)
  end
end
