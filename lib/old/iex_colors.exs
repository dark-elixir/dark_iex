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
)
