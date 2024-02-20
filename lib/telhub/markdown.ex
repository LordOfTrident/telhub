defmodule Telhub.Markdown do
	@attrs %{
		"**" => %{attr: IO.ANSI.bright,                 start: "",  end: "",  in_link: true},
		"*"  => %{attr: IO.ANSI.italic,                 start: "",  end: "",  in_link: true},
		"_"  => %{attr: IO.ANSI.italic,                 start: "",  end: "",  in_link: false},
		"`"  => %{attr: IO.ANSI.light_black_background, start: " ", end: " ", in_link: true},
		"__" => %{attr: IO.ANSI.underline,              start: "",  end: "",  in_link: false},
		"~~" => %{attr: IO.ANSI.crossed_out,            start: "",  end: "",  in_link: true},
	}

	@link_attr  IO.ANSI.underline <> IO.ANSI.light_blue
	@separators [" ", "\t", "|", "{", "}", "(", ")", "[", "]"]

	def apply(text), do:
		markdown(text, initial_state(), false, "")

	defp initial_state, do:
		@attrs |> Enum.reduce(%{}, fn {a, _}, acc -> Map.merge(acc, %{a => false}) end)

	defp reset_seqs(state) do
		IO.ANSI.reset <> (state
			|> Enum.filter(fn {_, enabled} -> enabled end)
			|> Enum.map(fn {attr, _} -> @attrs[attr].attr end)
			|> Enum.join(""))
	end

	defp markdown("\\" <> <<ch::binary-size(1)>> <> rest, state, link, output), do:
		markdown(rest, state, link, output <> ch)

	for {a, %{in_link: in_link}} <- @attrs |> Enum.sort(fn {key1, _}, {key2, _} ->
		String.length(key1) > String.length(key2) # Sort by length so "**" comes before "*"
	end) do
		defp markdown(unquote(a) <> rest, state, link, output) when not link or unquote(in_link) do
			state = %{state | unquote(a) => not state[unquote(a)]}
			markdown(rest, state, false, output <>
			         (if state[unquote(a)], do: @attrs[unquote(a)].attr <> @attrs[unquote(a)].start,
			         else: @attrs[unquote(a)].end <> reset_seqs(state)))
		end
	end

	defp markdown("", _state, _link, output), do:
		output <> IO.ANSI.reset

	for protocol <- ["https://", "http://"] do
		defp markdown(unquote(protocol) <> rest, state, _link, output), do:
			markdown(rest, state, true, output <> @link_attr <> unquote(protocol))
	end

	# Making sure reset attributes from highlighting etc. wont break the markdown
	defp markdown("\e[0m" <> rest, state, link, output), do:
		markdown(rest, state, link, output <> "\e[0m" <> reset_seqs(state))

	defp markdown(<<ch::binary-size(1)>> <> rest, state, link, output) when ch in @separators, do:
		markdown(rest, state, false, output <> (if link, do: reset_seqs(state), else: "") <> ch)

	defp markdown(<<ch::binary-size(1)>> <> rest, state, link, output), do:
		markdown(rest, state, link, output <> ch)
end
