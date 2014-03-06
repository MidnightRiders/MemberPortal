module ClubsHelper
  def parse_hex(hexcolor)
    r = hexcolor[0,2].to_i(16)
    g = hexcolor[2,2].to_i(16)
    b = hexcolor[4,2].to_i(16)
    { r: r, g: g, b: b }
  end

  def get_hex(x)
    val = (x).to_i.to_s(16)
    val = "0#{val}" if val.length<2
    val
  end

  def get_contrast_yiq(hexcolor)
    v = parse_hex(hexcolor)
    yiq = ((v[:r] * 299) + (v[:g] * 587) + (v[:b] * 114)) / 1000
    (yiq >= 128) ? "111" : "fff"
  end

  def darken(hexcolor, amount = 0.5)
    amount = amount/100 if amount > 1
    v = parse_hex(hexcolor)
    "#{getHex(v.r * amount)}#{getHex(v.g * amount)}#{getHex(v.b * amount)}"
  end
end
