window.parseHex = (hexcolor) ->
  r = parseInt(hexcolor.substr(0, 2), 16)
  g = parseInt(hexcolor.substr(2, 2), 16)
  b = parseInt(hexcolor.substr(4, 2), 16)
  { r: r, g: g, b: b }

window.getHex = (x) ->
  val = Math.floor(x).toString(16)
  val = "0#{val}" if val.length<2
  val

window.getContrastYIQ = (hexcolor) ->
  v = parseHex(hexcolor)
  yiq = ((v.r * 299) + (v.g * 587) + (v.b * 114)) / 1000
  (if (yiq >= 128) then "#111" else "#fff")

window.darken = (hexcolor, amount=.5) ->
  amount = amount/100 if amount > 1
  v = parseHex(hexcolor)
  "#{getHex(v.r * amount)}#{getHex(v.g * amount)}#{getHex(v.b * amount)}"