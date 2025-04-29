defmodule Mix.Tasks.PhoenixSvgSpritesTest do
  use ExUnit.Case, async: false
  alias Mix.Tasks.PhoenixSvgSprites

  @test_svg_content """
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24">
    <path d="M12 2L1 12h3v9h6v-6h4v6h6v-9h3L12 2z"/>
  </svg>
  """

  setup do
    tmp_dir = System.tmp_dir!()
    test_dir = Path.join(tmp_dir, "test_svgs_#{System.unique_integer([:positive])}")
    File.mkdir_p!(test_dir)

    subdir = Path.join(test_dir, "subdir")
    File.mkdir_p!(subdir)
    File.write!(Path.join(test_dir, "icon1.svg"), @test_svg_content)
    File.write!(Path.join(test_dir, "icon2.svg"), @test_svg_content)
    File.write!(Path.join(subdir, "icon3.svg"), @test_svg_content)

    empty_dir = Path.join(test_dir, "empty_dir")
    File.mkdir_p!(empty_dir)

    on_exit(fn ->
      File.rm_rf!(test_dir)
    end)

    %{test_dir: test_dir, empty_dir: empty_dir}
  end

  describe "run/1" do
    test "generates sprite sheet with default config", %{test_dir: test_dir} do
      output_dir = Path.join(test_dir, "output")
      output_file = Path.join(output_dir, "sprites.svg")

      args = ["--dirs", test_dir, "--output-dir", output_dir]

      PhoenixSvgSprites.run(args)

      assert File.exists?(output_file)
      content = File.read!(output_file)
      assert content =~ ~s(<symbol id="icon1")
      assert content =~ ~s(<symbol id="icon2")
      assert content =~ ~s(<symbol id="icon3")
      refute content =~ ~s(width="24")
      refute content =~ ~s(height="24")
    end

    test "applies id prefix when specified", %{test_dir: test_dir} do
      output_dir = Path.join(test_dir, "output")
      args = ["--dirs", test_dir, "--output-dir", output_dir, "--id-prefix", "test"]

      PhoenixSvgSprites.run(args)

      content = File.read!(Path.join(output_dir, "test-sprites.svg"))
      assert content =~ ~s(<symbol id="test-icon1")
    end

    test "returns error when no SVG files found", %{test_dir: test_dir, empty_dir: empty_dir} do
      output_dir = Path.join(test_dir, "output")
      output_file = Path.join(output_dir, "sprites.svg")
      args = ["--dirs", empty_dir]

      PhoenixSvgSprites.run(args)

      refute File.exists?(output_file)
    end
  end

  describe "build/1" do
    test "returns error when input directory doesn't exist", %{test_dir: test_dir} do
      non_existent_dir = Path.join(test_dir, "nonexistent")

      expected_error = "No SVG files found in the specified location(s): #{non_existent_dir}"

      assert {:error, ^expected_error} =
               PhoenixSvgSprites.build(%{dirs: [non_existent_dir]})
    end

    test "creates output directory if it doesn't exist", %{test_dir: test_dir} do
      output_dir = Path.join(test_dir, "new_output")
      output_file = Path.join(output_dir, "sprites.svg")

      refute File.exists?(output_dir)

      assert {:ok, ^output_file} =
               PhoenixSvgSprites.build(%{
                 dirs: [test_dir],
                 output_dir: output_dir
               })

      assert File.exists?(output_file)
    end
  end

  describe "find_svg_files/2" do
    test "finds SVG files recursively", %{test_dir: test_dir} do
      assert {:ok, files} = PhoenixSvgSprites.find_svg_files([test_dir], false)
      assert length(files) == 3
      assert Enum.any?(files, &String.ends_with?(&1, "icon1.svg"))
      assert Enum.any?(files, &String.ends_with?(&1, "subdir/icon3.svg"))
    end

    test "returns error when no SVG files found", %{empty_dir: empty_dir} do
      assert {:error, msg} = PhoenixSvgSprites.find_svg_files([empty_dir], false)
      assert msg =~ "No SVG files found"
    end
  end
end
