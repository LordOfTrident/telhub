defmodule Telhub.CLI do
	def send(msg, socket), do:
		:gen_tcp.send(socket, msg)

	@prompt IO.ANSI.bright <> IO.ANSI.yellow <> ">"

	@prompt_reset IO.ANSI.reset <> IO.ANSI.light_black_background

	def prompt(msg), do:
		"#{@prompt_reset} #{msg} #{@prompt} #{IO.ANSI.reset} "

	def msg_prompt(channel, username, user_color), do:
		"#{IO.ANSI.bright <> IO.ANSI.light_cyan <> "#" <> channel  <> @prompt_reset} " <>
		"#{IO.ANSI.bright <> user_color         <> "@" <> username <> @prompt_reset}" |> prompt()

	def notif_joined(username, user_color), do:
		"#{IO.ANSI.bright <> IO.ANSI.light_green}+#{IO.ANSI.reset} User " <>
		"#{IO.ANSI.bright <> user_color <> username <> IO.ANSI.reset} joined\n"

	def notif_left(username, user_color), do:
		"#{IO.ANSI.bright <> IO.ANSI.light_red}-#{IO.ANSI.reset} User " <>
		"#{IO.ANSI.bright <> user_color <> username <> IO.ANSI.reset} left\n"

	def user_message(channel, username, user_color, msg), do:
		"#{IO.ANSI.light_cyan <> "#" <> channel  <> IO.ANSI.reset} " <>
		"#{user_color         <> "@" <> username <> IO.ANSI.reset}: #{msg}\n"

	def user(channel, username, user_color), do:
		"#{user_color         <> "@" <> username <> IO.ANSI.reset} in " <>
		"#{IO.ANSI.light_cyan <> "#" <> channel  <> IO.ANSI.reset}\n"

	def success(msg), do:
		"#{IO.ANSI.light_green <> msg <> IO.ANSI.reset}\n"

	def error(msg), do:
		"#{IO.ANSI.light_red <> msg <> IO.ANSI.reset}\n"

	def highlight(text), do:
		"#{IO.ANSI.bright <> IO.ANSI.magenta_background <> IO.ANSI.light_white <> text}" <>
		IO.ANSI.reset
end
