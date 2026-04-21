.pragma library

function normalize(color) {
  if (typeof color !== "string") throw new Error("Invalid color");
  color = color.replace(/^#/, "").toUpperCase();
  if (!/^[0-9A-F]{6}$|^[0-9A-F]{8}$/.test(color)) {
    throw new Error("Only RGB (6) or ARGB (8) hex is allowed");
  }
  return color;
}

function split(color) {
  color = normalize(color);

  if (color.length === 6) {
    return {
      a: 255,
      r: parseInt(color.slice(0, 2), 16),
      g: parseInt(color.slice(2, 4), 16),
      b: parseInt(color.slice(4, 6), 16),
    };
  }

  return {
    a: parseInt(color.slice(0, 2), 16),
    r: parseInt(color.slice(2, 4), 16),
    g: parseInt(color.slice(4, 6), 16),
    b: parseInt(color.slice(6, 8), 16),
  };
}

function clamp(v) {
  return Math.max(0, Math.min(255, v));
}

function toHex({ a, r, g, b }, hasAlpha) {
  const hex = (v) => v.toString(16).padStart(2, "0").toUpperCase();
  return hasAlpha
    ? `${hex(a)}${hex(r)}${hex(g)}${hex(b)}`
    : `${hex(r)}${hex(g)}${hex(b)}`;
}

function darken(color, amount) {
  const hasAlpha = normalize(color).length === 8;
  const c = split(color);
  c.r = clamp(c.r - amount);
  c.g = clamp(c.g - amount);
  c.b = clamp(c.b - amount);
  return toHex(c, hasAlpha);
}

function lighten(color, amount) {
  const hasAlpha = normalize(color).length === 8;
  const c = split(color);
  c.r = clamp(c.r + amount);
  c.g = clamp(c.g + amount);
  c.b = clamp(c.b + amount);
  return toHex(c, hasAlpha);
}

function opacity(color, value) {
  const c = split(color);
  c.a = clamp(Math.round(value * 255));
  return toHex(c, true);
}