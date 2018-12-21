module Layout

using Bukdu # render HTML

function layout(title, script, style, body)
    render(HTML, """
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Bukdu $title</title>
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
