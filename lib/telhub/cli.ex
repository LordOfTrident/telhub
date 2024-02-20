defmodule Telhub.CLI do
	alias Telhub.Markdown

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

	def message_content(msg, :md), do:
		(Markdown.apply(msg) |> String.trim) <> "\n"

	def message_content(msg, :no_md), do:
		(msg |> String.trim) <> "\n"

	def user_message(channel, username, user_color, msg, md_flag), do:
		"#{IO.ANSI.light_cyan <> "#" <> channel  <> IO.ANSI.reset} " <>
		"#{user_color         <> "@" <> username <> IO.ANSI.reset}: " <>
		message_content(msg, md_flag)

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

	def highlight_snippet(rest, snippet), do:
		highlight_snippet(rest, snippet, "", :binary.match(rest, snippet))

	defp highlight_snippet(rest, _snippet, output, :nomatch), do:
		output <> rest

	defp highlight_snippet(rest, snippet, output, {start, _}) do
		output = output <> (rest |> String.slice(0, start)) <> highlight(snippet)
		rest   = (rest |> String.slice(start + String.length(snippet), String.length(rest)))
		highlight_snippet(rest, snippet, output, :binary.match(rest, snippet))
	end

	def apply_markdown_to_input(msg, channel, username, color), do:
		IO.ANSI.cursor_up <> IO.ANSI.clear_line <>
		msg_prompt(channel, username, color) <> message_content(msg, :md)
end
