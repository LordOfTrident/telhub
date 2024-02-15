defmodule Telhub.User do
	alias Telhub.User
	alias Telhub.Channels
	alias Telhub.CLI

	defstruct name:         nil,
	          socket:       nil,
	          ip:           nil,
	          color:        nil,
	          scan:         false,
	          notifs:       [],
	          channel_name: Channels.default_channel_name

	def switch_channel(user, channel_name), do:
		%User{user | channel_name: channel_name}

	def set_scan(user, state) do
		user = user |> User.flush_notifs
		%User{user | scan: state}
	end

	def flush_notifs(user) do
		user.notifs
		|> Enum.join("")
		|> CLI.send(user.socket)

		%User{user | notifs: []}
	end

	def send_notif(user, notif) do
		user = %User{user | notifs: user.notifs ++ [notif]}

		if user.scan do
			IO.ANSI.clear_line <> "\r" |> CLI.send(user.socket)
			user = user |> User.flush_notifs
			CLI.msg_prompt(user.channel_name, user.name, user.color) |> CLI.send(user.socket)

			user
		else
			user
		end
	end

	def send(user, msg), do:
		Channels.send(user.channel_name, msg, user.name)
end

defmodule Telhub.Users do
	use Telhub.StateService

	alias Telhub.User
	alias Telhub.ClientHandler

	def initial_state, do:
		%{}

	@user_colors [
		IO.ANSI.light_red,
		IO.ANSI.light_yellow,
		IO.ANSI.light_green,
		IO.ANSI.light_blue,
		IO.ANSI.light_magenta,
		IO.ANSI.light_white,
	]

	def add(name, socket) do
		if get(name) == nil do
			user = %User{
				name:   name,
				color:  Enum.random(@user_colors),
				socket: socket,
				ip:     socket |> ClientHandler.socket_ip
			}
			create(name, user)
			user
		else
			{:exists, name}
		end
	end

	def switch_channel(name, channel_name), do:
		update(name, &(&1 |> User.switch_channel(channel_name)))

	def set_scan(name, state), do:
		update(name, &(&1 |> User.set_scan(state)))

	def flush_notifs(name), do:
		update(name, &(&1 |> User.flush_notifs))

	def send_notif(name, notif), do:
		update(name, &(&1 |> User.send_notif(notif)))

	def in_channel(all, channel_name), do:
		all |> Enum.filter(fn {_, %{channel_name: user_channel}} ->
			user_channel == channel_name
		end)

	def not_user(all, username), do:
		all |> Enum.filter(fn {name, _} -> name != username end)
end
