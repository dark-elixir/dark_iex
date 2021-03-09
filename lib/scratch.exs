# Will be using `ANSI`
Application.put_env(:elixir, :ansi_enabled, true)

# Get queue length for the IEx process
# This is fun to see while playing with nodes
queue_length = fn ->
  self()
  |> Process.info()
  |> Keyword.get(:message_queue_len)
end

defmodule Prompt do
  # import IO.ANSI

  def p(msg, styles) do
    "#{combine(styles)}#{msg}#{IO.ANSI.reset()}"
  end

  def combine(styles) do
    styles |> Enum.map(&apply(IO.ANSI, &1, [])) |> Enum.join("")
  end

  def intro do
    p("Using global .iex.exs (located in ~/.iex.exs)", [
      # :blink_slow,
      :magenta_background,
      :bright,
      :underline
    ])
  end

  @templates %{
    prefix: "%prefix",
    counter: "-%node-(%counter)",
    info: "✉ #{queue_length.()}",
    last: "➤➤➤",
    alive: "⚡"
  }
  @colors %{
    prefix: [:light_black_background, :green],
    counter: [:light_black_background, :green],
    info: [:light_blue],
    last: [:yellow],
    alive: [:bright, :yellow, :blink_rapid]
  }
  def

  def info(queue_length), do: p("✉ #{queue_length.()}", [:light_blue])
  def last, do: p("➤➤➤", [:yellow])
  def alive, do: p("⚡", [:bright, :yellow, :blink_rapid])
  def prefix, do: p("%prefix", [:light_black_background, :green])
  def counter, do: p("-%node-(%counter)", [:light_black_background, :green])
end

# Letting people know what iex.exs they are using
IO.puts(Prompt.intro())

prefix = Prompt.prefix()
counter = Prompt.counter()
info = Prompt.info(queue_length)
last = Prompt.last()
alive = Prompt.alive()

default_prompt = prefix <> counter <> " | " <> info <> " | " <> last
alive_prompt = prefix <> counter <> " | " <> info <> " | " <> alive <> last

inspect_limit = 5_000
history_size = 100

eval_result = [:green, :bright]
eval_error = [:red, :bright]
eval_info = [:blue, :bright]

# Configuring IEx
IEx.configure(
  inspect: [limit: inspect_limit],
  history_size: history_size,
  colors: [
    eval_result: eval_result,
    eval_error: eval_error,
    eval_info: eval_info
  ],
  default_prompt: default_prompt,
  alive_prompt: alive_prompt
)

# Phoenix Support
import_if_available(Plug.Conn)
import_if_available(Phoenix.HTML)

phoenix_app =
  :application.info()
  |> Keyword.get(:running)
  |> Enum.reject(fn {_x, y} ->
    y == :undefined
  end)
  |> Enum.find(fn {x, _y} ->
    x |> Atom.to_string() |> String.match?(~r{_web})
  end)

# Check if phoenix app is found
case phoenix_app do
  nil ->
    IO.puts("No Phoenix App found")

  {app, _pid} ->
    IO.puts("Phoenix app found: #{app}")

    ecto_app =
      app
      |> Atom.to_string()
      |> (&Regex.split(~r{_web}, &1)).()
      |> Enum.at(0)
      |> String.to_atom()

    exists =
      :application.info()
      |> Keyword.get(:running)
      |> Enum.reject(fn {_x, y} ->
        y == :undefined
      end)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.member?(ecto_app)

    # Check if Ecto app exists or running
    case exists do
      false ->
        IO.puts("Ecto app #{ecto_app} doesn't exist or isn't running")

      true ->
        IO.puts("Ecto app found: #{ecto_app}")

        # Ecto Support
        import_if_available(Ecto.Query)
        import_if_available(Ecto.Changeset)

        # Alias Repo
        repo = ecto_app |> Application.get_env(:ecto_repos) |> Enum.at(0)

        quote do
          alias unquote(repo), as: Repo
        end
    end
end

timestamp = fn ->
  {_date, {hour, minute, _second}} = :calendar.local_time()

  [hour, minute]
  |> Enum.map(&String.pad_leading(Integer.to_string(&1), 2, "0"))
  |> Enum.join(":")
end

IEx.configure(
  colors: [
    syntax_colors: [
      number: :light_yellow,
      atom: :light_cyan,
      string: :light_black,
      boolean: :red,
      nil: [:magenta, :bright]
    ],
    ls_directory: :cyan,
    ls_device: :yellow,
    doc_code: :green,
    doc_inline_code: :magenta,
    doc_headings: [:cyan, :underline],
    doc_title: [:cyan, :bright, :underline]
  ],
  default_prompt:
    "#{IO.ANSI.green()}%prefix#{IO.ANSI.reset()} " <>
      "[#{IO.ANSI.magenta()}#{timestamp.()}#{IO.ANSI.reset()} " <>
      ":: #{IO.ANSI.cyan()}%counter#{IO.ANSI.reset()}] >",
  alive_prompt:
    "#{IO.ANSI.green()}%prefix#{IO.ANSI.reset()} " <>
      "(#{IO.ANSI.yellow()}%node#{IO.ANSI.reset()}) " <>
      "[#{IO.ANSI.magenta()}#{timestamp.()}#{IO.ANSI.reset()} " <>
      ":: #{IO.ANSI.cyan()}%counter#{IO.ANSI.reset()}] >",
  history_size: 50,
  inspect: [
    pretty: true,
    limit: :infinity,
    width: 90
  ],
  width: 90
)

# https://github.com/megalithic/dotfiles/blob/a0ee5fda3f4231674da0e60238452b9a2424ec3d/misc/.iex.exs

Application.put_env(:elixir, :ansi_enabled, true)

# Get queue length for the IEx process
# This is fun to see while playing with nodes
queue_length = fn ->
  self()
  |> Process.info()
  |> Keyword.get(:message_queue_len)
end

prefix =
  IO.ANSI.black_background() <>
    IO.ANSI.green() <>
    "%prefix" <>
    IO.ANSI.reset()

counter =
  IO.ANSI.black_background() <>
    IO.ANSI.green() <>
    "-%node-(%counter)" <>
    IO.ANSI.reset()

# IO.ANSI.light_black_background() <>
info = IO.ANSI.light_black() <> "\uf6ef #{queue_length.()}" <> IO.ANSI.reset()

last = IO.ANSI.normal() <> "\uf460" <> IO.ANSI.reset()
# last = IO.ANSI.normal() <> "\uf054" <> IO.ANSI.reset()
# last = IO.ANSI.faint() <> "\uf101 \uf460 \uf63d \uf710" <> IO.ANSI.reset()

alive =
  IO.ANSI.bright() <>
    IO.ANSI.yellow() <>
    IO.ANSI.blink_rapid() <>
    "\ue315 " <>
    IO.ANSI.reset()

default_prompt = prefix <> counter <> IO.ANSI.black() <> "│" <> IO.ANSI.reset() <> info <> last

alive_prompt =
  prefix <>
    counter <>
    IO.ANSI.black() <>
    "│" <> IO.ANSI.reset() <> info <> IO.ANSI.black() <> "│" <> IO.ANSI.reset() <> alive <> last

history_size = 100

eval_result = [:green, :bright]
eval_error = [[:red, :bright, "\ue3bf ERROR - "]]
eval_info = [:blue, :bright]

defmodule IExHelpers do
  def whats_this?(term) when is_nil(term), do: "Type: Nil"
  def whats_this?(term) when is_binary(term), do: "Type: Binary"
  def whats_this?(term) when is_boolean(term), do: "Type: Boolean"
  def whats_this?(term) when is_atom(term), do: "Type: Atom"
  def whats_this?(_term), do: "Type: Unknown"
  def logger_debug(), do: Logger.configure(level: :debug)
  def logger_error(), do: Logger.configure(level: :error)
  def logger_warn(), do: Logger.configure(level: :warn)
  def logger_info(), do: Logger.configure(level: :info)
end

# Configuring IEx
IEx.configure(
  inspect: [limit: :infinity, pretty: true, charlists: :as_lists],
  history_size: history_size,
  colors: [
    eval_result: eval_result,
    eval_error: eval_error,
    eval_info: eval_info
  ],
  default_prompt: default_prompt,
  alive_prompt: alive_prompt
)

# Phoenix Support
import_if_available(Plug.Conn)
import_if_available(Phoenix.HTML)

phoenix_app =
  :application.info()
  |> Keyword.get(:running)
  |> Enum.reject(fn {_x, y} ->
    y == :undefined
  end)
  |> Enum.find(fn {x, _y} ->
    x |> Atom.to_string() |> String.match?(~r{_web})
  end)

# Check if phoenix app is found
case phoenix_app do
  nil ->
    IO.puts(
      IO.ANSI.light_black() <>
        IO.ANSI.faint() <> IO.ANSI.italic() <> "\uf05a  No Phoenix App found"
    )

  {app, _pid} ->
    IO.puts("\uf05a  Phoenix app found: #{app}")

    ecto_app =
      app
      |> Atom.to_string()
      |> (&Regex.split(~r{_web}, &1)).()
      |> Enum.at(0)
      |> String.to_atom()

    exists =
      :application.info()
      |> Keyword.get(:running)
      |> Enum.reject(fn {_x, y} ->
        y == :undefined
      end)
      |> Enum.map(fn {x, _y} -> x end)
      |> Enum.member?(ecto_app)

    # Check if Ecto app exists or running
    case exists do
      false ->
        IO.puts(
          IO.ANSI.light_black() <>
            IO.ANSI.faint() <>
            IO.ANSI.italic() <> "\uf05a  Ecto app #{ecto_app} doesn't exist or isn't running"
        )

      true ->
        IO.puts(
          IO.ANSI.light_black() <>
            IO.ANSI.faint() <> IO.ANSI.italic() <> "\uf05a  Ecto app found: #{ecto_app}"
        )

        # Ecto Support
        import_if_available(Ecto.Query)
        import_if_available(Ecto.Changeset)

        # Alias Repo
        repo = ecto_app |> Application.get_env(:ecto_repos) |> Enum.at(0)

        quote do
          alias unquote(repo), as: Repo
        end
    end
end

defmodule App do
  def restart do
    Application.stop(:collected_live)
    Application.stop(:collected_live_web)
    recompile()
    Application.ensure_all_started(:collected_live)
    Application.ensure_all_started(:collected_live_web)
  end
end
