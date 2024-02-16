defmodule Telhub.BanList do
	use Telhub.StateService

	def initial_state, do:
		%{}

	def add(ip), do:
		create(ip, :banned)
end
