defmodule Mixmaker.Mixfile do
	use Mix.Project

	def project do
		[
			app:             :mixmaker,
			version:         "0.1.0",
			elixir:          "~> 1.4",
			build_embedded:  Mix.env == :prod,
			start_permanent: Mix.env == :prod,
			deps:            deps()
		]
	end

	defp deps do
		[
			{:converge, ">= 0.1.0"},
			{:gears,    ">= 0.1.0"},
		]
	end
end
