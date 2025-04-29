defmodule PhoenixSvgSprites.Live.SvgSpriteTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias PhoenixSvgSprites.Sprite

  @test_svg_content """
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24">
    <path d="M12 2L1 12h3v9h6v-6h4v6h6v-9h3L12 2z"/>
  </svg>
  """

  setup do
    tmp_dir = System.tmp_dir!()
    test_dir = Path.join(tmp_dir, "test_svgs_#{System.unique_integer([:positive])}")
    File.mkdir_p!(test_dir)
    File.write!(Path.join(test_dir, "icon1.svg"), @test_svg_content)
    File.write!(Path.join(test_dir, "icon2.svg"), @test_svg_content)

    on_exit(fn ->
      File.rm_rf!(test_dir)
    end)

    %{test_dir: test_dir}
  end

  describe "svg_sprite/1" do
    test "renders basic SVG sprite" do
      html = render_component(&Sprite.sprite/1, icon: "icon1")

      assert html =~ ~s(<svg)
      assert html =~ ~s(<use href="/assets/sprites.svg#icon1">)
    end

    test "renders SVG sprite with title and custom class" do
      html =
        render_component(&Sprite.sprite/1, icon: "icon1", title: "foo", class: "bar")

      assert html =~ ~s(<svg)
      assert html =~ ~s(<use href="/assets/sprites.svg#icon1">)
      assert html =~ ~s(<title>foo</title>)
      assert html =~ ~s(class="h-6 w-6 bar inline-block")
    end

    test "renders SVG sprite with aribtary attributes" do
      html =
        render_component(&Sprite.sprite/1, icon: "icon1", height: "48", width: "48")
        |> IO.inspect()

      assert html =~ ~s(<svg)
      assert html =~ ~s(width="48" height="48")
    end
  end
end
