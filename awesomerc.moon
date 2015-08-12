export awful =         require "awful"
export gears =         require "gears"
export wibox =         require "wibox"
export beautiful =     require "beautiful"
export naughty =       require "naughty"
export menubar =       require "menubar"

awful.rules =   require "awful.rules"

require "awful.autofocus"

require "list"


terminal = "urxvt"
menubar.utils.terminal = "urxvt"


if awesome.startup_errors
	naughty.notify
		preset: naught.config.presets.critical
		title: "Oops, there were errors during startup!"
		text: awesome.startup_errors

do
	in_error = false
	awesome.connect_signal "debug::error", (err) ->
		return if in_error
		in_error = true

		naughty.notify
			preset: naughty.config.presets.critical
			title: "Oops, an error happened!",
			text: tostring err

		in_error = false


beautiful.init "/home/hal/.config/awesome/themes/hal/theme.lua"

modkey = "Mod1"

with awful.layout.suit
	awful.layout.layouts = {
		.floating,          .tile,              .tile.left
		.tile.bottom,       .tile.top,          .fair
		.fair.horizontal,   .spiral,            .spiral.dwindle
		.max,               .max.fullscreen,    .magnifier
		.corner.nw
	}


if beautiful.wallpaper
	for s = 1, screen.count!
		gears.wallpaper.maximized beautiful.wallpaper, s, true

tags = for _ = 1, screen.count!
	awful.tag { 1, 2, 3, 4, 5, 6, 7, 8, 9 },
		s, awful.layout.suit.floating


--  The menu must be available in the parent scope for hotkeys concerning it
mainmenu = awful.menu
	items: {
		{ "restart", awesome.restart },
		{ "quit", awesome.quit }
	}


tagbuttons = list.buttons
	[mods: {      }, m: 1]: awful.tag.viewonly
	[mods: {modkey}, m: 1]: awful.client.movetotag
	[mods: {      }, m: 3]: awful.tag.viewtoggle
	[mods: {modkey}, m: 3]: awful.client.toggletag
	[mods: {      }, m: 4]: (t) -> awful.tag.viewnext awful.tag.getscreen t
	[mods: {      }, m: 5]: (t) -> awful.tag.viewprev awful.tag.getscreen t


taskbuttons = list.buttons
	[mods: {      }, m: 1]: (c) ->
		c.minimized = c == client.focus
		unless c == client.focus
			unless c\isvisible!
				awful.tag.viewonly c.first_tag
			client.focus = c
			c\raise!

	[mods: {      }, m: 3]: ->
		if instance
			instance\hide!
			instance = nil
		else
			instance = awful.menu.clients theme: width: 250

	[mods: {      }, m: 4]: -> awful.client.focus.byidx 1
	[mods: {      }, m: 5]: -> awful.client.focus.byidx -1


--  Similar to the menu, the prompt box is referenced
--  by hotkeys and must be available in the parent scope
promptbox = {}
			  

wiboxes = for s = 1, screen.count!
	
	promptbox[s] = awful.widget.prompt!
	
	with awful.wibox position: "top", screen: s
		\set_widget with wibox.layout.align.horizontal!
			\set_left with wibox.layout.fixed.horizontal!
				\add awful.widget.launcher
					image: beautiful.awesome_icon
					menu: mainmenu
				\add awful.widget.taglist s,
					awful.widget.taglist.filter.all,
					tagbuttons
				\add promptbox[s]

			\set_middle awful.widget.tasklist s,
				awful.widget.tasklist.filter.currenttags,
				taskbuttons
			\set_right with wibox.layout.fixed.horizontal!
				\add awful.widget.textclock!
				\add with awful.widget.layoutbox s
					\buttons list.buttons
						[mods: { }, m: 1]: -> awful.layout.inc( 1)
						[mods: { }, m: 3]: -> awful.layout.inc(-1)
						[mods: { }, m: 4]: -> awful.layout.inc( 1)
						[mods: { }, m: 5]: -> awful.layout.inc(-1)


--  Mouse bindings
root.buttons list.buttons
	[mods: {      }, m: 3]: mainmenu\toggle
	[mods: {      }, m: 4]: awful.tag.viewnext
	[mods: {      }, m: 5]: awful.tag.viewprev


  -- Key bindings


globalkeys = list.keys
	[mods: {modkey           }, k: "Left"  ]: awful.tag.viewprev
	[mods: {modkey           }, k: "Right" ]: awful.tag.viewnext
	[mods: {modkey           }, k: "Escape"]: awful.tag.history.restore

	[mods: {modkey           }, k: "j"     ]: ->
		awful.client.focus.byidx 1

	[mods: {modkey           }, k: "k"     ]: ->
		awful.client.focus.byidx -1

	[mods: {modkey           }, k: "w"     ]: mainmenu\show
	[mods: {modkey, "Shift"  }, k: "j"     ]: -> awful.client.swap.byidx 1
	[mods: {modkey, "Shift"  }, k: "k"     ]: -> awful.client.swap.byidx -1
	[mods: {modkey, "Control"}, k: "j"     ]: -> awful.screen.focus_relative 1
	[mods: {modkey, "Control"}, k: "k"     ]: -> awful.screen.focus_relative -1
	[mods: {modkey           }, k: "u"     ]: awful.client.urgent.jumpto
	[mods: {modkey           }, k: "Tab"   ]: ->
		awful.client.focus.history.previous!
		if client.focus
			client.focus\raise!

	[mods: {modkey           }, k: "Return"]: -> awful.util.spawn terminal
	[mods: {modkey, "Control"}, k: "r"     ]: awesome.restart
	[mods: {modkey, "Shift"  }, k: "q"     ]: awesome.quit

	[mods: {modkey           }, k: "l"     ]: -> awful.tag.incmwfact 0.05
	[mods: {modkey           }, k: "h"     ]: -> awful.tag.incmwfact -0.05
	[mods: {modkey, "Shift"  }, k: "h"     ]: -> awful.tag.incnmaster 1
	[mods: {modkey, "Shift"  }, k: "l"     ]: -> awful.tag.incnmaster -1
	[mods: {modkey, "Control"}, k: "h"     ]: -> awful.tag.incncol 1
	[mods: {modkey, "Control"}, k: "l"     ]: -> awful.tag.incncol -1
	[mods: {modkey           }, k: "space" ]: -> awful.layout.inc 1
	[mods: {modkey, "Shift"  }, k: "space" ]: -> awful.layout.inc -1

	[mods: {modkey, "Control"}, k: "n"     ]: ->
		c = awful.client.restore! -- Focus restored client
		if c
			client.focus = c
			c\raise!

	[mods: {modkey           }, k: "r"     ]: ->
		promptbox[awful.screen.focused!]\run!

	[mods: {modkey           }, k: "x"     ]: ->
		awful.prompt.run prompt: "Run Lua code: ",
			mypromptbox[awful.screen.focused!].widget,
			awful.util.eval,
			_,
			(awful.util.getdir "cache") .. "/history_eval"

	[mods: {modkey           }, k: "p"     ]: menubar.show


for i = 1, 9
	globalkeys = awful.util.table.join globalkeys, list.keys

		--  View tag only.
		[mods: {modkey                    }, k: "#" .. i + 9]: ->
			tag = (awful.tag.gettags awful.screen.focused!)[i]
			awful.tag.viewonly tag if tag

		--  Toggle tag.
		[mods: {modkey, "Control"         }, k: "#" .. i + 9]: ->
			tag = (awful.tag.gettags awful.screen.focused!)[i]
			awful.tag.viewtoggle tag if tag

		--  Move client to tag.
		[mods: {modkey, "Shift"           }, k: "#" .. i + 9]: ->
			if client.focus
				tag = (awful.tag.gettags client.focus.screen)[i]
				awful.client.movetotag(tag) if tag

		--  Toggle tag.
		[mods: {modkey, "Control", "Shift"}, k: "#" .. i + 9]: ->
			if client.focus
				tag = (awful.tag.gettags client.focus.screen)[i]
				awful.client.toggletag(tag) if tag


root.keys globalkeys


clientkeys = list.keys
	[mods: { modkey, "Shift"   }, k: "c"     ]: (c) -> c\kill!
	[mods: { modkey, "Control" }, k: "space" ]: awful.client.floating.toggle
	[mods: { modkey,           }, k: "o"     ]: awful.client.movetoscreen
	[mods: { modkey,           }, k: "t"     ]: (c) -> c.ontop = not c.ontop
	[mods: { modkey,           }, k: "n"     ]: (c) -> c.minimized = true

	[mods: { modkey, "Control" }, k: "Return"]: (c) ->
		c\swap awful.client.getmaster!

	[mods: { modkey,           }, k: "m"     ]: (c) -> with c
		.maximized = not .maximized
		\raise!

	[mods: { modkey,           }, k: "f"     ]: (c) -> with c
		.fullscreen = not .fullscreen
		\raise!


clientbuttons = list.buttons
	[mods: {      }, m: 1]: (c) ->
		client.focus = c
		c\raise!
	[mods: {modkey}, m: 1]: awful.mouse.client.move
	[mods: {modkey}, m: 3]: awful.mouse.client.resize


awful.rules.rules = {
	{ rule: {}  --  All clients will match this rule.
		properties:
			border_width:  beautiful.border_width
			border_color:  beautiful.border_normal
			focus:         awful.client.focus.filter
			raise:         true
			keys:          clientkeys
			buttons:       clientbuttons },
	{ rule: (class: "MPlayer"),  properties: (floating: true)  },
	{ rule: (class: "pinentry"), properties: (floating: true)  },
	{ rule: (class: "gimp"),     properties: (floating: true)  },
--  { rule: (class: "Firefox"),  properties: (tag: tags[1][2]) }
}


client.connect_signal "manage", (c) ->
	with c.size_hints
		if not awesome.startup then
			if not .user_position and not .program_position
				awful.placement.no_overlap c
				awful.placement.no_offscreen c
		elseif not .user_position and not .program_position
			awful.placement.no_offscreen c


client.connect_signal "mouse::enter", (c) ->
	test = (awful.layout.get c.screen) ~= awful.layout.suit.magnifier
	test and= awful.client.focus.filter c
	client.focus = c if test

client.connect_signal "focus", (c) ->
	c.border_color = beautiful.border_focus

client.connect_signal "unfocus", (c) ->
	c.border_color = beautiful.border_normal
