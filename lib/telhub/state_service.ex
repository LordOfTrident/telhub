defmodule Telhub.StateService do
	defmacro __using__(_opts) do
		quote do
			use Agent

			def start_link(_opts), do:
				Agent.start_link(fn -> initial_state() end, name: __MODULE__)

			def all, do:
				Agent.get(__MODULE__, &(&1))

			def create(name, value), do:
				Agent.update(__MODULE__, &(&1 |> Map.put(name, value)))

			def get(name), do:
				all()[name]

			def update(name, func), do:
				Agent.update(__MODULE__, &(&1 |> Map.put(name, func.(&1[name]))))

			def delete(name), do:
				Agent.update(__MODULE__, &(&1 |> Map.delete(name)))
		end
	end
end
