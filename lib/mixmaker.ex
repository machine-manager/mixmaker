alias Converge.{DirectoryPresent, FilePresent, All, Context, Runner, TerminalReporter}

defmodule Mixmaker do
	def create_project(path, application_name, module_name, deps) do
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
				defmodule #{module_name}.Mixfile do
					use Mix.Project

					def project do
						[
							app:             :#{application_name},
							version:         "0.1.0",
							elixir:          "~> 1.4",
							build_embedded:  Mix.env == :prod,
							start_permanent: Mix.env == :prod,
							deps:            deps()
						]
					end

					defp deps do
						#{deps}
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
				defmodule #{module_name}Test do
					use ExUnit.Case
				end
				"""
			},
			%FilePresent{path: Path.join([path, "lib", "#{application_name}.ex"]), mode: 0o640, content:
				"""
				defmodule #{module_name} do
				end
				"""
			},
			%FilePresent{path: Path.join([path, "config", "config.exs"]), mode: 0o640, content:
				"""
				use Mix.Config
				"""
			},
		]
		ctx = %Context{run_meet: true, reporter: TerminalReporter.new()}
		Runner.converge(%All{units: units}, ctx)
	end
end
