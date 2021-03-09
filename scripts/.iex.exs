import_file("scripts/iex_prompt.exs")
import_file("scripts/iex_colors.exs")
import_file("scripts/iex_inspect.exs")
import_file("scripts/iex_aliases.exs")
import_file("scripts/iex_phoenix.exs")

defmodule DarkIEx do
  # Obeserver CLI
  # https://alembic.com.au/blog/2021-02-05-monitoring-phoenix-liveview-performance?utm_medium=email&utm_source=elixir-radar
  #
  # Add `{:observer_cli, "~> 1.6"}`
  # Run `observer_cli.start()`

  def start do
    # Notice
    IO.puts(IExPrompt.notice())

    # Greeting
    # IO.puts(IExPrompt.greeting())

    IExPhoenix.start()

    # Observer
    :observer.start()

    # Log levels
    # require Logger
    # Logger.configure(level: :error)
  end
end

require IEx
import IEx

DarkIEx.start()
h()
