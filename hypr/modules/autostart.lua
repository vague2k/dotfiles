hl.on("hyprland.start", function()
  hl.exec_cmd("qs")
  -- Wallpaper daemon (package: awww)
  hl.exec_cmd("awww-daemon")
  -- Bluetooth pairing agent (package: blueman).
  hl.exec_cmd("blueman-applet")
end)
