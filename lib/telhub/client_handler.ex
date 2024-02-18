defmodule Telhub.ClientHandler do
	require Logger

	alias Telhub.User
	alias Telhub.Users
	alias Telhub.Channels
	alias Telhub.CLI
	alias Telhub.BanList

	@password_retries    5
	@max_username_length 20

	@cmd_prefix "/"

	@cmd_users  "users"
	@cmd_join   "join"
	@cmd_msgs   "msgs"
	@cmd_scan   "scan"
	@cmd_latest "latest"
	@cmd_search "search"
	@cmd_clear  "clear"
	@cmd_exit   "exit"
	@cmd_help   "help"

	@cmds %{
		@cmd_users  => {[],                 "List all connected users"},
		@cmd_join   => {["<channel_name>"], "Join the specified channel"},
		@cmd_msgs   => {[],                 "Show all messages in the channel"},
		@cmd_scan   => {["<on/off>"],       "Enable/disable automatic new message recieving"},
		@cmd_latest => {[],                 "Flush and send all latest notifications"},
		@cmd_search => {["text"],           "Search for messages containing the text snippet"},
		@cmd_clear  => {[],                 "Clear the screen"},
		@cmd_exit   => {[],                 "Exit the chat"},
		@cmd_help   => {["[command]"],      "Show the help message or a specific command usage"},
	}

	def new_client(socket, pass) do
		Task.start_link(fn -> handle_new_client(socket, pass) end)
	end

	defp help() do
		cmds = @cmds
			|> Enum.map(fn {cmd, _} -> "  #{help(cmd)}" end)
			|> Enum.join("")

		"Help:
  <...> - Required argument
  [...] - Optional argument

Commands:
#{cmds}"
	end

	defp help(cmd) do
		{args, desc} = @cmds[cmd]
		args = args
			|> Enum.map(&(" " <> IO.ANSI.magenta <> IO.ANSI.bright <> &1 <> IO.ANSI.reset))
			|> Enum.join("")

		"#{@cmd_prefix <> IO.ANSI.blue <> IO.ANSI.bright <> cmd <> IO.ANSI.reset <> args} - #{desc}\n"
	end

	defp prompt_password(_, nil, _), do:
		:ok

	defp prompt_password(socket, _, 0) do
		BanList.add(socket |> socket_ip)

		CLI.error("You ran out of password retries.") |> CLI.send(socket)
		:gen_tcp.close(socket)
		:closed
	end

	defp prompt_password(socket, pass, retries) do
		CLI.prompt("(#{retries}) Enter the server password") |> CLI.send(socket)
		case read_line(socket) do
			:closed -> :closed
			input   ->
				if input == pass do
					:ok
				else
					CLI.error("Incorrect password") |> CLI.send(socket)
					prompt_password(socket, pass, retries - 1)
				end
		end
	end

	defp prompt_password(socket, pass) do
		if BanList.get(socket |> socket_ip) == :banned do
			CLI.error("You have been banned from the server.") |> CLI.send(socket)
			:gen_tcp.close(socket)
			:closed
		else
			prompt_password(socket, pass, @password_retries)
		end
	end

	defp handle_new_client(socket, pass) do
		ip = socket |> socket_ip
		Logger.info("Connection from #{ip}")

		case prompt_password(socket, pass) do
			:ok ->
				CLI.send("\n#{IO.ANSI.bright}Welcome to Telhub!#{IO.ANSI.reset}\n", socket)
				create_new_user(socket)

			:closed ->
				Logger.info("Connection from #{ip} cancelled")
		end
	end

	defp create_new_user(socket) do
		ip = socket |> socket_ip

		case prompt_registration(socket) do
			{:exists, name} ->
				Logger.info("Failed to register user from #{ip}")

				CLI.error("User \"#{name}\" already exists, try again") |> CLI.send(socket)

				create_new_user(socket)

			:closed -> Logger.info("Connection from #{ip} closed at registration")

			user ->
				Logger.info("Registered user \"#{user.name}\" from #{ip}")

				CLI.success("Successfully registered as \"#{user.name}\"") <>
				"Type \"#{@cmd_prefix <> @cmd_help}\" to show help\n\n" |> CLI.send(socket)

				Users.all
				|> Users.not_user(user.name)
				|> Enum.each(fn {name, _} ->
					Users.send_notif(name, CLI.notif_joined(user.name, user.color))
				end)

				serve(user)
		end
	end

	defp valid_username?(username), do:
		Regex.match?(~r/^[a-zA-Z0-9\-_\.]+$/, username) and
		String.length(username) <= @max_username_length

	defp prompt_registration(socket) do
		CLI.prompt("Enter your username") |> CLI.send(socket)
		case read_line(socket) do
			:closed  -> :closed
			username ->
				if valid_username?(username) do
					Users.add(username, socket)
				else
					CLI.error("Usernames can be max #{@max_username_length} characters long and " <>
					          "can only contain letters, digits, \"-\", \"_\" or \".\". ")
					|> CLI.send(socket)
					prompt_registration(socket)
				end
		end
	end

	defp closed(user) do
		Logger.info("Connection from #{user.ip} (user \"#{user.name}\") closed")
		Users.delete(user.name)
	end

	defp serve(user) do
		CLI.msg_prompt(user.channel_name, user.name, user.color) |> CLI.send(user.socket)

		input = read_line(user.socket)
		cond do
			input == :error ->
				CLI.error("Recieved an error during input") |> CLI.send(user.socket)
				serve(Users.get(user.name))

			input == :closed -> closed(user)

			input |> String.printable? ->
				case input |> process(user) do
					:closed -> closed(user)
					_ ->       serve(Users.get(user.name))
				end

			true ->
				CLI.error("Recieved non-printable characters in input") |> CLI.send(user.socket)
				serve(Users.get(user.name))
		end
	end

	defp read_line(socket) do
		case :gen_tcp.recv(socket, 0) do
			{:ok,     data}      -> data |> String.trim
			{:error,  :closed}   -> :closed
			{:error,  _}         -> :error
		end
	end

	defp process(:closed, _user), do:
		:closed

	defp process(@cmd_prefix <> rest, user), do:
		rest |> String.split(" ") |> process_cmd(user)

	defp process("", _user), do:
		nil # IO.ANSI.cursor_up <> "\r" |> CLI.send(user.socket)

	defp process(msg, user), do:
		user |> User.send(msg)

	defp process_cmd([@cmd_users], user) do
		Users.all
		|> Enum.map(fn {_, user} ->
			CLI.user(user.channel_name, user.name, user.color)
		end)
		|> Enum.join("")
		|> CLI.send(user.socket)
	end

	defp process_cmd([@cmd_join, channel_name], user) do
		if Channels.get(channel_name) == nil do
			Channels.add(channel_name)
		end

		Users.switch_channel(user.name, channel_name)

		CLI.success("Switched to channel \"#{channel_name}\"") |> CLI.send(user.socket)
	end

	defp process_cmd([@cmd_msgs], user) do
		Channels.get(user.channel_name).msgs
		|> Enum.map(fn msg ->
			CLI.user_message(user.channel_name, msg.author, msg.color, msg.content)
		end)
		|> Enum.join("")
		|> CLI.send(user.socket)
	end

	defp process_cmd([@cmd_scan, state], user) do
		bool = state == "on"

		CLI.success("Scanning #{if bool, do: "enabled", else: "disabled"}") |> CLI.send(user.socket)
		Users.set_scan(user.name, bool)
	end

	defp process_cmd([@cmd_latest], user) do
		Users.flush_notifs(user.name)
	end

	defp process_cmd([@cmd_search, text], user) do
		Channels.get(user.channel_name).msgs
		|> Enum.filter(fn msg -> String.contains?(msg.content, text) end)
		|> Enum.map(fn msg ->
			{idx, len} = :binary.match(msg.content, text)

			content =
				(msg.content |> String.slice(0, idx)) <>
				CLI.highlight(msg.content |> String.slice(idx, len)) <>
				(msg.content |> String.slice(idx + len, String.length(msg.content)))

			CLI.user_message(user.channel_name, msg.author, msg.color, content)
		end)
		|> Enum.join("")
		|> CLI.send(user.socket)
	end

	defp process_cmd([@cmd_clear], user) do
		IO.ANSI.clear <> IO.ANSI.cursor(1, 1) |> CLI.send(user.socket)
	end

	defp process_cmd([@cmd_exit], user) do
		CLI.success("Exited.") |> CLI.send(user.socket)

		Users.all
		|> Users.not_user(user.name)
		|> Enum.each(fn {name, _} ->
			Users.send_notif(name, CLI.notif_left(user.name, user.color))
		end)

		:gen_tcp.close(user.socket)
		:closed
	end

	defp process_cmd([@cmd_help], user) do
		help() |> CLI.send(user.socket)
	end

	defp process_cmd([@cmd_help, cmd], user) do
		if @cmds[cmd] == nil do
			CLI.error("Unknown command #{cmd}") |> CLI.send(user.socket)
		else
			help(cmd) |> CLI.send(user.socket)
		end
	end

	defp process_cmd(invalid, user) do
		cmd = invalid |> Enum.at(0)

		cond do
			cmd == nil -> "Expected a command after \"/\""

			@cmds[cmd] != nil ->
				"\"#{cmd}\" recieved invalid amount of arguments, " <>
				"try \"#{@cmd_prefix <> @cmd_help} #{cmd}\""

			true -> "Unknown command #{cmd}"
		end
		|> CLI.error |> CLI.send(user.socket)
	end

	def socket_ip(socket) do
		{:ok, {ip, _}} = :inet.peername(socket)
		ip |> Tuple.to_list |> Enum.join(".")
	end
end
