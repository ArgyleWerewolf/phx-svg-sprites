defmodule Mix.Tasks.PhoenixSvgSprites do
  @moduledoc """
  Builds an SVG sprite sheet from source SVG files.

  Usage:
    mix svg_sprite_sheet [options]

  Options:
    --dirs        Comma-separated directories to search for SVGs (default: "assets/svgs")
    --output-dir  Output directory (default: "priv/static/assets/")
    --output-file Output filename (default: "sprites.svg")
    --id-prefix   Prefix for the output filename and SVG IDs (default: "")
    --verbose     Show detailed processing information
  """
  use Mix.Task

  require Logger

  @default_config %{
    dirs: ["assets/svg_sprites"],
    output_dir: "priv/static/assets/",
    output_file: "sprites.svg",
    id_prefix: "",
    verbose: false
  }

  @svg_opening ~s(<?xml version="1.0" encoding="utf-8"?>
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
)
  @svg_closing ~s(</svg>)

  @impl Mix.Task
  def run(args) do
    config = parse_args(args)

    if config.verbose,
      do: Logger.info("Starting SVG sprite sheet generation with config: #{inspect(config)}")

    config
    |> build()
    |> case do
      {:ok, output_path} ->
        Logger.info("Successfully generated SVG sprite sheet at #{output_path}")

      {:error, reason} ->
        Logger.error("Failed to generate SVG sprite sheet: #{reason}")
    end
  end

  @doc """
  Builds the SVG sprite sheet with the given configuration.
  """
  def build(config) do
    config = Map.merge(@default_config, config)

    output_path =
      Path.join([
        config.output_dir,
        prefixed_filename(config.output_file, config.id_prefix)
      ])

    with {:ok, svg_files} <- find_svg_files(config.dirs, config.verbose),
         id_map = build_id_map(svg_files, config.id_prefix),
         xml_content = generate_xml(id_map),
         :ok <- write_file(xml_content, output_path) do
      {:ok, output_path}
    end
  end

  @doc """
  Find SVG files in the specified directories
  """
  def find_svg_files(dirs \\ @default_config.dirs, verbose) do
    svg_files =
      dirs
      |> Enum.flat_map(&list_files_recursive/1)
      |> Enum.filter(&String.ends_with?(&1, ".svg"))
      |> Enum.sort()

    if verbose, do: Logger.debug("Found SVG files: #{inspect(svg_files)}")

    if Enum.empty?(svg_files) do
      {:error, "No SVG files found in the specified location(s): #{Enum.join(dirs)}"}
    else
      {:ok, svg_files}
    end
  end

  defp parse_args(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [
          dirs: :string,
          output_dir: :string,
          output_file: :string,
          id_prefix: :string,
          verbose: :boolean
        ],
        aliases: [v: :verbose]
      )

    %{
      dirs: (opts[:dirs] && String.split(opts[:dirs], ",")) || @default_config.dirs,
      output_dir: opts[:output_dir] || @default_config.output_dir,
      output_file: opts[:output_file] || @default_config.output_file,
      id_prefix: opts[:id_prefix] || @default_config.id_prefix,
      verbose: opts[:verbose] || false
    }
  end

  defp build_id_map(files, ""), do: build_id_map(files, nil)
  defp build_id_map(files, nil), do: Enum.map(files, &{Path.basename(&1, ".svg"), &1})

  defp build_id_map(files, prefix),
    do: Enum.map(files, &{"#{prefix}-#{Path.basename(&1, ".svg")}", &1})

  defp generate_xml(id_map) do
    symbols =
      Enum.map_join(id_map, "\n", &file_to_symbol/1)

    @svg_opening <> symbols <> @svg_closing
  end

  defp file_to_symbol({id, path}) do
    path
    |> File.read!()
    |> String.replace(~r/\s(width|height)="[^"]*"/, "")
    |> String.replace("xmlns=", ~s(id="#{id}" xmlns=))
    |> String.replace("<svg", "<symbol")
    |> String.replace("</svg>", "</symbol>")
  end

  defp write_file(content, path) do
    path
    |> Path.dirname()
    |> File.mkdir_p!()

    case File.write(path, content) do
      :ok -> :ok
      {:error, reason} -> {:error, "Failed to write file: #{reason}"}
    end
  end

  defp list_files_recursive(path) do
    cond do
      File.regular?(path) ->
        [path]

      File.dir?(path) ->
        path
        |> File.ls!()
        |> Enum.flat_map(&list_files_recursive(Path.join(path, &1)))

      true ->
        []
    end
  end

  defp prefixed_filename(filename, ""), do: filename
  defp prefixed_filename(filename, nil), do: filename
  defp prefixed_filename(filename, prefix), do: "#{prefix}-#{filename}"
end
