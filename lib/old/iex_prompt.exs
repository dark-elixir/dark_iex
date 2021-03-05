defmodule IExPrompt do
  @unicodes [
    zap: "⚡",
    elixir: "",
    mailbox: "✉",
    ansi_cha: "\e[G"
  ]

  @iex_terms [
    node: "%node",
    prefix: "%prefix",
    counter: "%counter"
  ]

  def phrases do
    [
      iex: [:magenta, unicode(:elixir), :light_green, :bright, " #{iex_term(:prefix)}>"],
      alive: [:bright, :yellow, :blink_rapid, unicode(:zap), :light_black, iex_term(:node), " "],
      counter: ["(#{iex_term(:counter)}) "],
      info: [:light_black, "| ", message_box(), :light_black, " | "],
      greeting: [:green, "❄ Be Productive! ❄"],
      notice: [:magenta, "Using global ~/.iex.exs ", :light_black, "(located in #{File.cwd!()})"]
    ]
  end

  def message_box do
    [
      :light_blue,
      unicode(:mailbox),
      " #{message_queue_len()}",
      :reset
    ]
  end

  def timestamp(datetime \\ NaiveDateTime.local_now()) do
    if Version.compare(System.version(), "1.11.0") in [:gt, :eq] do
      [
        :green,
        Calendar.strftime(datetime, "%y-%m-%d "),
        :light_green,
        Calendar.strftime(datetime, "%I:%M"),
        :light_black,
        Calendar.strftime(datetime, ":%S "),
        :green,
        Calendar.strftime(datetime, "%p"),
        :reset
      ]
    else
      # {_date, {hour, minute, _second}} = :calendar.local_time()
      # [hour, minute]
      # |> Enum.map(&String.pad_leading(Integer.to_string(&1), 2, "0"))
      # |> Enum.join(":")
      [to_string(datetime)]
    end
  end

  def pp(tokens) do
    tokens
    |> List.wrap()
    |> List.flatten()
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
  end

  # Get queue length for the IEx process
  # This is fun to see while playing with nodes
  def message_queue_len do
    Process.info(self())[:message_queue_len]
  end

  def phrase(name) do
    phrases()[name] ++ [:reset]
  end

  def iex_term(name) do
    @iex_terms[name]
  end

  def unicode(name) do
    @unicodes[name]
  end

  def notice do
    """
    \n#{pp([phrase(:notice)])}
    """
  end

  def greeting do
    """
    #{pp([phrase(:greeting)])}
    """
  end

  def default_prompt do
    pp([
      unicode(:ansi_cha),
      phrase(:counter),
      timestamp(),
      phrase(:info),
      phrase(:iex)
    ])
  end

  def alive_prompt do
    pp([
      unicode(:ansi_cha),
      phrase(:counter),
      timestamp(),
      phrase(:info),
      phrase(:alive),
      phrase(:iex)
    ])
  end
end

IEx.configure(
  width: 80,
  history_size: 5000,
  # This will display when we enter multi lines of code. I used 4 empty spaces.
  # If you need you can update it with the unicode symbols you like
  continuation_prompt: "    ",
  # alive_continuation_prompt: "",
  alive_prompt: IExPrompt.alive_prompt(),
  default_prompt: IExPrompt.default_prompt()
)
