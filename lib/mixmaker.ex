alias Converge.{DirectoryPresent, FilePresent, All, Context, Runner, SilentReporter}
alias Gears.TableFormatter

defmodule Mixmaker do
	def create_project(path, application_name, module, deps, escript \\ nil) do
		escript_extra = case escript do
			nil -> ""
			_   -> "\n\t\t\tescript:         #{inspect escript},"
		end

		units = [
			%DirectoryPresent{path: path,                      mode: 0o750},
			%DirectoryPresent{path: Path.join(path, "config"), mode: 0o750},
			%DirectoryPresent{path: Path.join(path, "lib"),    mode: 0o750},
			%DirectoryPresent{path: Path.join(path, "test"),   mode: 0o750},
			%FilePresent{path: Path.join(path, ".gitignore"), mode: 0o640, content:
				"""
				/_build
				/cover
				/deps
				/doc
				erl_crash.dump
				*.ez
				/#{application_name}
				"""
			},
			%FilePresent{path: Path.join(path, ".editorconfig"), mode: 0o640, content:
				"""
				root = true

				[*]
				indent_style = tab
				indent_size = 2
				end_of_line = lf
				charset = utf-8
				trim_trailing_whitespace = true
				insert_final_newline = true
				"""
			},
			%FilePresent{path: Path.join(path, "mix.exs"), mode: 0o640, content:
				"""
				defmodule #{inspect module}.Mixfile do
					use Mix.Project

					def project do
						[
							app:             :#{application_name},
							version:         "0.1.0",
							elixir:          "~> 1.4",#{escript_extra}
							build_embedded:  Mix.env == :prod,
							start_permanent: Mix.env == :prod,
							deps:            deps()
						]
					end

					defp deps do
				#{deps_string(deps)}
					end
				end
				"""
			},
			%FilePresent{path: Path.join([path, "test", "test_helper.exs"]), mode: 0o640, content:
				"""
				ExUnit.start()
				"""
			},
			%FilePresent{path: Path.join([path, "test", "#{application_name}_test.exs"]), mode: 0o640, content:
				"""
				defmodule #{inspect module}Test do
					use ExUnit.Case
				end
				"""
			},
			%FilePresent{path: Path.join([path, "lib", "#{application_name}.ex"]), mode: 0o640, content:
				"""
				defmodule #{inspect module} do
				end
				"""
			},
			%FilePresent{path: Path.join([path, "config", "config.exs"]), mode: 0o640, content:
				"""
				use Mix.Config
				"""
			},
		]
		ctx = %Context{run_meet: true, reporter: SilentReporter.new()}
		Runner.converge(%All{units: units}, ctx)
	end

	# This atrocious code is designed to table-format the deps in the deps function like so:
	# {:somedep,  ">= 0.1.0"}
	# {:otherdep, "1.0.0"}
	defp deps_string(deps) do
		case deps do
			[] ->
				"""
				\t\t[]\
				"""
			_  -> 
				table = deps
					|> Enum.map(fn dep ->
							parts = dep
								|> Tuple.to_list
								|> Enum.map(fn part -> inspect(part, pretty: false, limit: -1) end)
							middle = Enum.drop(tl(parts), -1)
							["\t\t\t{#{hd(parts)}," | Enum.map(middle, &("#{&1},"))] ++ ["#{List.last(parts)}},"]
						end)
					|> TableFormatter.format
				"""
				\t\t[
				#{table}\t\t]\
				"""
		end
	end
end
