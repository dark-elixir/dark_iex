defmodule Prompt do
  # import IO.ANSI

  def colors do
    [
      syntax_colors: [
        number: :magenta,
        atom: :cyan,
        string: :green,
        boolean: :magenta,
        nil: :red
      ],
      eval_result: [:green, :bright],
      eval_error: [[:red, :bright, "✘ \n"]],
      eval_info: [:yellow, :bright],
      eval_warning: [:yellow, :bright, "💩"]

      # eval_result: [:green, :bright],
      # eval_error: [:red, :bright],
      # eval_info: [:blue, :bright]
    ]
  end

  def pp(msg, styles) do
    # "#{combine(styles)}#{msg}#{IO.ANSI.reset()}"

    # IO.ANSI.format(styles ++ [msg])
    styles |> Enum.concat([msg]) |> IO.ANSI.format() |> IO.chardata_to_string()
  end

  def combine(styles) do
    styles |> Enum.map(&apply(IO.ANSI, &1, [])) |> Enum.join("")
  end

  #   @colors %{
  #     # prompt: [:blink_slow, :magenta_background, :bright, :underline],
  #     prompt: [:magenta_background, :bright, :underline],
  #     prefix: [:light_black_background, :green],
  #     counter: [:light_black_background, :green],
  #     info: [:light_blue],
  #     last: [:yellow],
  #     alive: [:bright, :yellow, :blink_rapid]
  #   }

  # @templates %{
  #   prefix: "%prefix",
  #   counter: "-%node-(%counter)",
  #   info: "✉ #{queue_length.()}",
  #   last: "➤➤➤",
  #   alive: "⚡"
  # }

  def intro do
    pp("Using global .iex.exs (located in ~/.iex.exs)", [
      # :blink_slow,
      :magenta_background,
      :bright,
      :underline
    ])
  end

  def prompt do
    pp("Using global .iex.exs (located in ~/.iex.exs)", [:magenta_background, :bright, :underline])
  end

  def info, do: pp("✉ #{queue_length()}", [:light_blue])
  # def info, do: pp("✉ ", [:light_blue])
  def last, do: pp("➤➤➤", [:yellow])
  def alive, do: pp("⚡", [:bright, :yellow, :blink_rapid])
  def prefix, do: pp("%prefix", [:light_black_background, :green])
  def counter, do: pp("-%node-(%counter)", [:light_black_background, :green])

  def default_prompt do
    prefix() <> counter() <> " | " <> info() <> " | " <> last()
  end

  def alive_prompt do
    prefix() <> counter() <> " | " <> info() <> " | " <> alive() <> last()
  end

  def whois do
    self()
    |> IO.inspect()

    self()
    |> Process.info()
    |> IO.inspect()

    self()
    |> Process.info()
    |> Keyword.get(:message_queue_len)
    |> IO.inspect()
  end

  # Get queue length for the IEx process
  # This is fun to see while playing with nodes
  def queue_length do
    self()
    |> Process.info()
    |> Keyword.get(:message_queue_len)
  end
end

# Will be using `ANSI`
Application.put_env(:elixir, :ansi_enabled, true)

# Letting people know what iex.exs they are using
IO.puts(Prompt.prompt())

# Configuring IEx
IEx.configure(
  # inspect: [limit: 5_000],

  inspect: [
    limit: :infinity,
    charlists: :as_lists,
    pretty: true,
    binaries: :as_strings,
    printable_limit: :infinity
  ],
  history_size: 100,
  colors: Prompt.colors(),
  default_prompt: Prompt.default_prompt(),
  alive_prompt: Prompt.alive_prompt()
)

#################################################

defmodule IExPhoenix do
  def phx_imports do
    import_if_available(Plug.Conn)
    import_if_available(Phoenix.HTML)
  end

  def ecto_imports do
    import_if_available(Ecto.Query)
    import_if_available(Ecto.Changeset)
  end

  def app_pid?({_app, pid}) when is_pid(pid), do: true
  def app_pid?({_app, :undefined}), do: false
  def app_web?({app, _pid}), do: String.ends_with?("#{app}", "_web")

  def apps_running do
    :application.info()[:running]
    |> Enum.filter(&app_pid?/1)
  end

  def app_web do
    apps_running()
    |> Enum.find(&app_web?/1)
  end

  def ecto_app(app) do
    app
    |> Atom.to_string()
    |> (&Regex.split(~r{_web}, &1)).()
    |> Enum.at(0)
    |> String.to_atom()
  end

  def app_ecto({app_web, pid}) do
    ecto_app = ecto_app(app_web)

    if exists?(ecto_app) do
      {{app, pid}, :running, ecto_app}
    else
      {{app, pid}, :missing, ecto_app}
    end
  end

  def find_application do
    :application.info()
    |> Keyword.get(:running)
    |> Enum.reject(fn {_x, y} ->
      y == :undefined
    end)
    |> Enum.find(fn {x, _y} ->
      x |> Atom.to_string() |> String.match?(~r{_web})
    end)
    |> case do
      {app, pid} ->
        ecto_app = ecto_app(app)

        if exists?(ecto_app) do
          {{app, pid}, :running, ecto_app}
        else
          {{app, pid}, :missing, ecto_app}
        end

      any ->
        any
    end
  end

  def ecto_repo(ecto_app) do
    ecto_app |> Application.get_env(:ecto_repos) |> Enum.at(0)
  end

  def exists?(ecto_app) do
    :application.info()
    |> Keyword.get(:running)
    |> Enum.reject(fn {_x, y} ->
      y == :undefined
    end)
    |> Enum.map(fn {x, _y} -> x end)
    |> Enum.member?(ecto_app)
  end

  def quoted_repo(ecto_app) do
    # Alias Repo
    repo = ecto_repo(ecto_app)

    quote do
      alias unquote(repo), as: Repo
    end
  end

  def start do
    phx_imports()

    case find_application() do
      nil ->
        IO.puts("No Phoenix App found")

      # [phx: {phx, _pid}, ecto: {ecto, _pid}, repo: {repo, _pi}]

      {{app, pid}, :missing, ecto_app} ->
        IO.puts("Phoenix app found: #{app}")
        IO.puts("Ecto app #{ecto_app} doesn't exist or isn't running")

      {{app, pid}, :running, ecto_app} ->
        IO.puts("Phoenix app found: #{app}")
        IO.puts("Ecto app found: #{ecto_app}")
        ecto_imports()
        quoted_repo(ecto_app)
    end
  end
end

#######################################

IExPhoenix.start()
