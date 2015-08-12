--  Functions to aid idiomatic and readable button/hotkey lists

buttons = (tab) ->
	awful.util.table.join unpack for key, funct in pairs tab
		import mods, m from key
		awful.button mods, m, funct

keys = (tab) ->
	keys = {}
	for key, funct in pairs tab
		import mods, k from key
		keys = awful.util.table.join keys,
			awful.key mods, k, funct
	keys

export list = { :buttons, :keys }