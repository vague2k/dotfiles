-----------------
---- LAYOUTS ----
-----------------

-- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
hl.config({
  dwindle = {
    preserve_split = true, -- You probably want this
  },
})

-- See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
hl.config({
  master = {
    new_status = "master",
  },
})

-- See https://wiki.hypr.land/configuring/layouts/scrolling-layout/ for more
hl.config({
  scrolling = {
    fullscreen_on_one_column = true,
  },
})
