defmodule PhoenixSvgSprites.Sprite do
  @moduledoc false
  use Phoenix.Component
  alias PhoenixSvgSprites.EndpointHelper

  @doc """
  Given an icon string, returns an SVG sprite from the icon sprite sheet.
  Accepts options for SVG title, CSS classes, Tailwind height and width dimensions, and namespace IDs.

  ## Example Usage
  <.sprite icon="dog" dimensions="h-5 w-5" />
  """
  attr(:icon, :string, required: true)
  attr(:title, :string, required: false, default: nil, doc: "The SVG equivalent of an alt tag.")

  attr(:id_prefix, :string,
    default: "",
    doc:
      "A string with which to namespace sprite files and IDs. Must match @id_prefix in Mix.Tasks.PhoenixSvgSprites"
  )

  attr(:class, :string, default: "", doc: "Arbitrary CSS classes")
  attr(:dimensions, :string, default: "h-6 w-6", doc: "Default Tailwind sizing")
  attr(:role, :string, default: "img")
  attr(:rest, :global)

  def sprite(assigns) do
    ~H"""
    <svg
      role={@role}
      xmlns="http://www.w3.org/2000/svg"
      class={[@dimensions, @class, "inline-block"]}
      {@rest}
    >
      <title :if={not is_nil(@title)}>{@title}</title>
      <use href={"#{EndpointHelper.static_path(format_prefix(@id_prefix) <> "sprites.svg#" <> format_prefix(@id_prefix) <> @icon)}"}>
      </use>
    </svg>
    """
  end

  defp format_prefix(""), do: ""
  defp format_prefix(prefix), do: "#{prefix}-"
end
