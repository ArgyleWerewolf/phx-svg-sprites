defmodule PhoenixSvgSprites.EndpointHelper do
  @default_assets_path "/assets/"

  def static_path(path) do
    case Application.get_env(:phoenix_svg_sprites, :endpoint) do
      nil ->
        @default_assets_path <> path

      endpoint when is_atom(endpoint) ->
        if function_exported?(endpoint, :static_path, 1) do
          endpoint.static_path(path)
        else
          endpoint.static_url() <> @default_assets_path <> path
        end

      endpoint when is_binary(endpoint) ->
        endpoint <> path
    end
  end
end
