defmodule IExPhoenix do
  def phx_imports do
    import_if_available(Plug.Conn)
    import_if_available(Phoenix.HTML)
  end

  def ecto_imports do
    import_if_available(Ecto.Query)
    import_if_available(Ecto.Changeset)
  end

  def app_web?({app, _pid}), do: String.ends_with?("#{app}", "_web")

  def apps_running do
    :application.info()[:running]
  end

  def apps_active do
    apps_running()
    |> Enum.filter(fn {_app, pid} -> is_pid(pid) end)
  end

  def find_app(name) do
    apps_active()
    |> Enum.find(fn {app, _pid} -> app == name end)
  end

  def discover_phx_apps do
    apps_active()
    |> Enum.filter(fn {app, _pid} -> String.ends_with?("#{app}", "_web") end)
    |> case do
      [{app, pid}] -> discover_ecto_app({app, pid})
      any -> any
    end
  end

  def discover_ecto_app({app, pid}) do
    ecto_app = "#{app}" |> String.replace_trailing("_web") |> String.to_atom()

    case find_app(ecto_app) do
      {ecto_app, ecto_pid} -> {{app, pid}, {ecto_app, ecto_pid}}
      _ -> {{app, pid}, {ecto_app, :undefined}}
    end
  end

  def ecto_repo(ecto_app) do
    ecto_app |> Application.get_env(:ecto_repos) |> Enum.at(0)
  end

  def quoted_repo(repo) do
    quote do
      alias unquote(repo), as: Repo
    end
  end

  def start do
    case discover_phx_apps() do
      {{app, _pid}, {ecto_app, pid}} when is_pid(pid) ->
        IO.puts("Phoenix app found: #{app}")
        phx_imports()

        IO.puts("Ecto app found: #{ecto_app}")
        ecto_imports()

        repo = ecto_repo(ecto_app)
        IO.puts("Aliasing Repo: #{repo}")
        quoted_repo(repo)

        IO.puts("")

      {{app, _pid}, {ecto_app, _}} ->
        IO.puts("Phoenix app found: #{app}")
        phx_imports()

        IO.puts("Ecto app #{ecto_app} doesn't exist or isn't running")
        IO.puts("")

      _ ->
        IO.puts("No Phoenix App found")
        IO.puts("")
    end
  end
end
