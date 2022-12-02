window.parseHex = function(hexcolor) {
  var b, g, r;
  r = parseInt(hexcolor.substr(0, 2), 16);
  g = parseInt(hexcolor.substr(2, 2), 16);
  b = parseInt(hexcolor.substr(4, 2), 16);
  return {
    r: r,
    g: g,
    b: b
  };
};

window.getHex = function(x) {
  var val;
  val = Math.floor(x).toString(16);
  if (val.length < 2) {
    val = "0" + val;
  }
  return val;
};

window.getContrastYIQ = function(hexcolor) {
  var v, yiq;
  v = parseHex(hexcolor);
  yiq = ((v.r * 299) + (v.g * 587) + (v.b * 114)) / 1000;
  if (yiq >= 128) {
    return "#111";
  } else {
    return "#fff";
  }
};

window.darken = function(hexcolor, amount) {
  var v;
  if (amount == null) {
    amount = .5;
  }
  if (amount > 1) {
    amount = amount / 100;
  }
  v = parseHex(hexcolor);
  return "" + (getHex(v.r * amount)) + (getHex(v.g * amount)) + (getHex(v.b * amount));
};
