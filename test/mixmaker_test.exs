alias Gears.FileUtil

defmodule MixmakerTest do
	use ExUnit.Case

	test "create a mix project" do
		temp = FileUtil.temp_path("mixmaker_test")
		Mixmaker.create_project(temp, "someapp", "SomeApp", [])
	end
end
