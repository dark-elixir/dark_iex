defmodule DarkIEx do
  @moduledoc """
  Settings for `IEx.configure/1`.`
  """

  def config do
    []
    |> Enum.concat(inspect())
    |> Enum.concat(colors())
    |> Enum.concat(prompt())
    |> IEx.configure()
  end

  def configure do
    IEx.configure(config())

    require Logger

    Logger.configure(
      # level: :error
      # level: :alert
      level: :emergency
    )
  end

  defp time_remaining(expiration) do
    total_seconds = DateTime.to_unix(expiration) - DateTime.to_unix(DateTime.utc_now())

    hours = div(total_seconds, 3600)
    minutes = div(rem(total_seconds, 3600), 60)
    seconds = rem(total_seconds, 60)

    hours_display =
      if hours > 0 do
        "#{hours}:"
      else
        ""
      end

    minutes_display =
      if hours > 0 and minutes < 10 do
        "0#{minutes}:"
      else
        "#{minutes}:"
      end

    seconds_display =
      if seconds < 10 do
        "0#{seconds}"
      else
        "#{seconds}"
      end

    "#{hours_display}#{minutes_display}#{seconds_display}"
  end

  def run do
    import_file("~/.iex/iex_prompt.exs")
    import_file("~/.iex/iex_colors.exs")
    import_file("~/.iex/iex_inspect.exs")
    import_file("~/.iex/iex_aliases.exs")
    import_file("~/.iex/iex_phoenix.exs")

    Application.put_env(:elixir, :ansi_enabled, true)

    # Notice
    IO.puts(IExPrompt.notice())

    # Greeting
    IO.puts(IExPrompt.greeting())

    IExPhoenix.start()

    require Logger
    require IEx
    import IEx

    # Obeserver CLI
    # https://alembic.com.au/blog/2021-02-05-monitoring-phoenix-liveview-performance?utm_medium=email&utm_source=elixir-radar
    #
    # Add `{:observer_cli, "~> 1.6"}`
    # Run `observer_cli.start()`

    :observer.start()
    # Logger.configure(level: :error)
  end

  def prompt do
    [
      width: 80,
      history_size: 5000,
      # This will display when we enter multi lines of code. I used 4 empty spaces.
      # If you need you can update it with the unicode symbols you like
      continuation_prompt: "    ",
      # alive_continuation_prompt: "",
      alive_prompt: IExPrompt.alive_prompt(),
      default_prompt: IExPrompt.default_prompt()
    ]
  end

  def inspect do
    [
      inspect: [
        pretty: true,
        binaries: :as_strings,
        charlists: :as_lists,
        limit: :infinity,
        printable_limit: :infinity
      ]
    ]
  end

  @doc """
  Source: https://hexdocs.pm/iex/IEx.html#configure/1-colors
  """
  def colors do
    [
      colors: [
        enabled: true,
        ######################################
        # syntax
        ######################################
        syntax_colors: [
          nil: [:magenta, :bright],
          atom: [:light_blue, :bright],
          number: [:blue],
          binary: [:red],
          string: [:green],
          boolean: [:cyan, :bright],
          map: [:light_white, :bright],
          list: [:light_white, :bright],
          tuple: [:light_white, :bright]
        ],
        ######################################
        # evaluation cycle
        ######################################
        eval_interrupt: [:light_yellow, :bright],
        eval_result: [:yellow, :bright],
        # eval_result: [ :green ],
        # eval_error: [:red, :bright, "💩✘ \n"],
        eval_error: [:red, :bright],
        eval_info: [:cyan, :bright],
        stack_info: [:red],
        blame_diff: [:red],
        ######################################
        # ls
        ######################################
        ls_directory: [:blue, :bright],
        ls_device: [:green, :bright],
        ######################################
        # IO.ANSI.Docs
        ######################################
        doc_bold: [:bright],
        doc_code: [:cyan],
        doc_headings: [:yellow],
        doc_metadata: [:yellow],
        doc_quote: [:light_black],
        doc_inline_code: [:cyan],
        doc_table_heading: [:reverse],
        doc_title: [:reverse, :yellow],
        doc_underline: [:underline]
      ]
    ]
  end
end
