------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/

-- DP-2 (Acer VG240Y P, 1920x1080), primary anchored at 0x0.
hl.monitor({
  output = "DP-2",
  mode = "preferred",
  position = "0x0",
  scale = 1,
})

-- DP-1 (Acer K242HYL, 1920x1080), stacked above primary
hl.monitor({
  output = "DP-1",
  mode = "preferred",
  position = "0x-1080",
  scale = 1,
})

-- HDMI-A-1 (VIZIO M50QXM-K01, 3840x2160), left of primary
hl.monitor({
  output = "HDMI-A-1",
  mode = "preferred",
  position = "-3840x0",
  disabled = true, -- just my tv, and annoying to have tbh i dont even use it like that
  scale = 1,
})

-- Fallback for any other display (applied last).
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})
