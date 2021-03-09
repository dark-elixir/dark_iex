Application.put_env(:elixir, :ansi_enabled, true)

IEx.configure(
  # https://hexdocs.pm/iex/IEx.html#configure/1-colors
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
    blame_diff: [:red],
    eval_error: [:red, :bright],
    # eval_error: [:red, :bright, "💩✘ \n"],
    eval_info: [:cyan, :bright],
    eval_interrupt: [:light_yellow, :bright],
    eval_result: [:yellow, :bright],
    stack_info: [:red],
    ######################################
    # ls
    ######################################
    ls_device: [:green, :bright],
    ls_directory: [:blue, :bright],
    ######################################
    # IO.ANSI.Docs
    ######################################
    doc_bold: [:bright],
    doc_code: [:cyan],
    doc_headings: [:yellow],
    doc_inline_code: [:cyan],
    doc_metadata: [:yellow],
    doc_quote: [:light_black],
    doc_table_heading: [:reverse],
    doc_title: [:reverse, :yellow],
    doc_underline: [:underline]
  ]
)
