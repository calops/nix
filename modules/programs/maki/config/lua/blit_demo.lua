-- /blit — render a pixel frame through Buf:blit, maki's cell-based image path.
-- Each character cell carries two vertical pixels: fg paints the top one,
-- bg the bottom one, which is why the cell is "▀" by default.
--
--   /blit            generated test pattern (no dependencies)
--   /blit <path>     a real image, converted to raw RGB with ImageMagick
--
-- Not the kitty graphics protocol: there is no host API to emit raw bytes, so
-- this is what a plugin can do on its own.

local RAW_TMP = "/tmp/maki-blit-demo.rgb"
local MAX_CELL_W = 80
local MAX_CELL_H = 36

local function hsl_to_rgb(h, s, l)
  local function hue(p, q, t)
    if t < 0 then
      t = t + 1
    end
    if t > 1 then
      t = t - 1
    end
    if t < 1 / 6 then
      return p + (q - p) * 6 * t
    end
    if t < 1 / 2 then
      return q
    end
    if t < 2 / 3 then
      return p + (q - p) * (2 / 3 - t) * 6
    end
    return p
  end

  if s == 0 then
    local v = math.floor(l * 255 + 0.5)
    return v, v, v
  end
  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q
  return math.floor(hue(p, q, h + 1 / 3) * 255 + 0.5),
    math.floor(hue(p, q, h) * 255 + 0.5),
    math.floor(hue(p, q, h - 1 / 3) * 255 + 0.5)
end

-- A hue sweep with a brightness falloff, a white ring, and a 1px checker
-- patch so the effective resolution is visible.
local function pattern(x, y, w, h)
  if x < 20 and y < 20 then
    local on = (math.floor(x / 2) + math.floor(y / 2)) % 2 == 0
    local c = on and 255 or 24
    return c, c, c
  end
  local dx = (x + 0.5) / w - 0.5
  local dy = (y + 0.5) / h - 0.5
  local r = math.sqrt(dx * dx + dy * dy)
  if math.abs(r - 0.33) < 0.01 then
    return 255, 255, 255
  end
  local l = 0.74 - 0.42 * math.abs((y + 0.5) / h - 0.5)
  return hsl_to_rgb(x / math.max(w - 1, 1), 1.0, l)
end

local function pattern_buffer(w, h)
  local fb = buffer.create(w * h * 3)
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local r, g, b = pattern(x, y, w, h)
      local i = (y * w + x) * 3
      buffer.writeu8(fb, i, r)
      buffer.writeu8(fb, i + 1, g)
      buffer.writeu8(fb, i + 2, b)
    end
  end
  return fb
end

local function magick_exe()
  if maki.fn.executable("magick") then
    return "magick"
  end
  if maki.fn.executable("convert") then
    return "convert"
  end
  return nil
end

local function file_buffer(path, w, h)
  local exe = magick_exe()
  if not exe then
    return nil, "ImageMagick not found (need `magick` or `convert` on PATH)"
  end
  local job = maki.fn.jobstart({
    exe,
    path,
    "-resize",
    w .. "x" .. h .. "!",
    "-depth",
    "8",
    "rgb:" .. RAW_TMP,
  })
  local res = maki.fn.jobwait(job, 20000)
  if not res then
    maki.fn.jobstop(job)
    return nil, "ImageMagick timed out"
  end
  if res.exit_code ~= 0 then
    local err = (res.stderr or ""):match("^%s*(.-)%s*$")
    return nil, err ~= "" and err or ("ImageMagick exit code " .. tostring(res.exit_code))
  end
  local data, err = maki.fs.read_bytes(RAW_TMP)
  if not data then
    return nil, "cannot read " .. RAW_TMP .. ": " .. tostring(err)
  end
  if buffer.len(data) ~= w * h * 3 then
    return nil, ("expected %d raw bytes, got %d"):format(w * h * 3, buffer.len(data))
  end
  return data
end

local function present(fb, w, h, title)
  local buf = maki.ui.buf()
  buf:blit(fb, w, h)
  local win = maki.ui.open_win(buf, {
    title = title,
    width = w + 2,
    height = math.ceil(h / 2) + 2,
    border = "rounded",
    focus = true,
    needs_input = true,
    footer = { { "q", "close" } },
  })
  while true do
    local ev = win:recv()
    if not ev or ev.type == "close" then
      break
    end
    if ev.type == "key" and (ev.key == "q" or ev.key == "esc" or ev.key == "ctrl+c") then
      break
    end
  end
  win:close()
end

maki.api.register_command({
  name = "/blit",
  description = "Render an image as half-block cells (blit demo)",
  nargs = "?",
  handler = function(opts)
    local size = maki.ui.terminal_size()
    local w = math.min(MAX_CELL_W, size.cols - 8)
    local h = math.min(MAX_CELL_H, size.rows - 8) * 2
    if w < 8 or h < 8 then
      maki.ui.flash("terminal too small for the blit demo")
      return
    end

    local path = (opts.args or ""):match("^%s*(.-)%s*$")
    if path == "" then
      present(pattern_buffer(w, h), w, h, " blit: pattern " .. w .. "x" .. h .. " px ")
      return
    end

    local fb, err = file_buffer(path, w, h)
    if not fb then
      maki.ui.flash("blit: " .. err)
      return
    end
    present(fb, w, h, " blit: " .. path .. " ")
  end,
})
