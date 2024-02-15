defmodule Telhub do
	@moduledoc false

	use Application

	@impl true
	def start(_type, default_port: default_port) do
		arg = System.argv |> Enum.at(0)

		if arg == "--help" or arg == "-h" do
			IO.puts "Usage: [PORT] [PASSWORD]"
		else
			port     = get_port(default_port)
			pass     = get_pass()
			opts     = [strategy: :one_for_one, name: Telhub.Supervisor]
			children = [
				{Telhub.Users,    []},
				{Telhub.Channels, []},
				{Telhub.Server,   %{port: port, pass: pass}},
			]
			Supervisor.start_link(children, opts)
		end
	end

	defp get_port(default_port) do
		args = System.argv

		if length(args) > 0 do
			{parsed, ""} = args
				|> Enum.at(0)
				|> Integer.parse

			parsed
		else
			default_port
		end
	end

	defp get_pass() do
		args = System.argv

		if length(args) > 1 do
			args |> Enum.at(1)
		else
			nil
		end
	end
end
