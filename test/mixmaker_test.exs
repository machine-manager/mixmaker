alias Gears.FileUtil

defmodule MixmakerTest do
	use ExUnit.Case

	test "create a mix project" do
		temp = FileUtil.temp_path("mixmaker_test")
		Mixmaker.create_project(temp, "someapp", "SomeApp", [{:somedep, ">= 0.1.0"}, {:otherdep, "1.0.0"}])
	end

	test "create a mix project with an escript" do
		temp = FileUtil.temp_path("mixmaker_test")
		Mixmaker.create_project(temp, "someapp", "SomeApp", [{:somedep, ">= 0.1.0"}, {:otherdep, "1.0.0"}], escript: [main_module: SomeApp])
	end
end
