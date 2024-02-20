defmodule Telhub.Message do
	defstruct content: nil, author: nil, color: nil
end

defmodule Telhub.Channel do
	alias Telhub.Channel
	alias Telhub.Users
	alias Telhub.Message
	alias Telhub.CLI

	defstruct name: nil, msgs: []

	def send(channel, content, author) do
		color = Users.get(author).color
		msg   = %Message{content: content, author: author, color: color}

		Users.all
		|> Users.not_user(author)
		|> Users.in_channel(channel.name)
		|> Enum.each(fn {name, _} ->
			Users.send_notif(name, CLI.user_message(channel.name, author, color, content, :md))
		end)

		%Channel{channel | msgs: channel.msgs ++ [msg]}
	end
end

defmodule Telhub.Channels do
	use Telhub.StateService

	alias Telhub.Channel

	def default_channel_name, do:
		"general"

	def initial_state, do:
		%{default_channel_name() => %Channel{name: default_channel_name()}}

	def add(name), do:
		create(name, %Channel{name: name})

	def send(name, content, author), do:
		update(name, &(&1 |> Channel.send(content, author)))
end
