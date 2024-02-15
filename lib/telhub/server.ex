defmodule Telhub.Server do
	use GenServer
	require Logger

	alias Telhub.ClientHandler

	def start_link(data), do:
		GenServer.start_link(__MODULE__, data, name: __MODULE__)

	def init(%{port: port, pass: pass}), do:
		Task.start_link(fn -> listen(port, pass) end)

	def listen(port, pass) do
		{:ok, socket} = :gen_tcp.listen(port, [
			:binary,
			packet:    :line,
			active:    false,
			reuseaddr: true,
		])

		Logger.info("Accepting connections on port #{port}")
		accept(socket, pass)
	end

	defp accept(socket, pass) do
		{:ok, client} = :gen_tcp.accept(socket)
		ClientHandler.new_client(client, pass)
		accept(socket, pass)
	end
end
