module Layout

using Bukdu

function layout(title, script, style, body)
    render(HTML, """
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Bukdu sevenstars$title</title>
  $script
  $style
</head>
<body>
$body
</body>
</html>
""")
end

end # module Layout
