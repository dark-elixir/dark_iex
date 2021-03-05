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
