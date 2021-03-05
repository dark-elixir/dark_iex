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
