
--[[
=head1 NAME

applets.TouchSkin.TouchSkinApplet - The touch skin for the Squeezebox Touch

=head1 DESCRIPTION

This applet implements the Touch skin for the Squeezebox Touch

=head1 FUNCTIONS

Applet related methods are described in L<jive.Applet>. 
SqueezeboxSkin overrides the following methods:

=cut
--]]


-- stuff we use
local ipairs, pairs, setmetatable, type = ipairs, pairs, setmetatable, type

local oo                     = require("loop.simple")

local Applet                 = require("jive.Applet")
local Audio                  = require("jive.ui.Audio")
local Font                   = require("jive.ui.Font")
local Framework              = require("jive.ui.Framework")
local Icon                   = require("jive.ui.Icon")
local Label                  = require("jive.ui.Label")
local RadioButton            = require("jive.ui.RadioButton")
local RadioGroup             = require("jive.ui.RadioGroup")
local SimpleMenu             = require("jive.ui.SimpleMenu")
local Surface                = require("jive.ui.Surface")
local Textarea               = require("jive.ui.Textarea")
local Tile                   = require("jive.ui.Tile")
local Window                 = require("jive.ui.Window")

local table                  = require("jive.utils.table")
local debug                  = require("jive.utils.debug")
local autotable              = require("jive.utils.autotable")

local log = require("jive.utils.log").logger("ui")

local EVENT_ACTION           = jive.ui.EVENT_ACTION
local EVENT_CONSUME          = jive.ui.EVENT_CONSUME
local EVENT_WINDOW_POP       = jive.ui.EVENT_WINDOW_POP
local LAYER_FRAME            = jive.ui.LAYER_FRAME
local LAYER_CONTENT_ON_STAGE = jive.ui.LAYER_CONTENT_ON_STAGE

local LAYOUT_NORTH           = jive.ui.LAYOUT_NORTH
local LAYOUT_EAST            = jive.ui.LAYOUT_EAST
local LAYOUT_SOUTH           = jive.ui.LAYOUT_SOUTH
local LAYOUT_WEST            = jive.ui.LAYOUT_WEST
local LAYOUT_CENTER          = jive.ui.LAYOUT_CENTER
local LAYOUT_NONE            = jive.ui.LAYOUT_NONE

local WH_FILL                = jive.ui.WH_FILL

local jiveMain               = jiveMain
local appletManager          = appletManager


module(...)
oo.class(_M, Applet)


-- Define useful variables for this skin
local imgpath = "applets/Fab4Skin/images/"
local sndpath = "applets/Fab4Skin/sounds/"
local fontpath = "fonts/"
local FONT_NAME = "FreeSans"
local BOLD_PREFIX = "Bold"


function init(self)
	self.images = {}
end


-- reuse images instead of loading them twice
-- FIXME can be removed after Bug 10001 is fixed
local function _loadImage(self, file)
	if not self.images[file] then
		self.images[file] = Surface:loadImage(imgpath .. file)
	end

	return self.images[file]
end


-- define a local function to make it easier to create icons.
local function _icon(x, y, img)
	local var = {}
	var.x = x
	var.y = y
	var.img = _loadImage(self, img)
	var.layer = LAYER_FRAME
	var.position = LAYOUT_SOUTH

	return var
end

-- define a local function that makes it easier to set fonts
local function _font(fontSize)
	return Font:load(fontpath .. FONT_NAME .. ".ttf", fontSize)
end

-- define a local function that makes it easier to set bold fonts
local function _boldfont(fontSize)
	return Font:load(fontpath .. FONT_NAME .. BOLD_PREFIX .. ".ttf", fontSize)
end

-- defines a new style that inherrits from an existing style
local function _uses(parent, value)
	local style = {}
	setmetatable(style, { __index = parent })
	for k,v in pairs(value or {}) do
		if type(v) == "table" and type(parent[k]) == "table" then
			-- recursively inherrit from parent style
			style[k] = _uses(parent[k], v)
		else
			style[k] = v
		end
	end

	return style
end


-- skin
-- The meta arranges for this to be called to skin Jive.
function skin(self, s)
	Framework:setVideoMode(480, 272, 0, false)

	local screenWidth, screenHeight = Framework:getScreenSize()

	--init lastInputType so selected item style is not shown on skin load
	Framework.mostRecentInputType = "mouse"

	-- Images and Tiles
	local titleBox                = Tile:loadImage( imgpath .. "Titlebar/titlebar.png" )
	local fiveItemSelectionBox    = Tile:loadImage( imgpath .. "5_line_lists/menu_sel_box_5line.png")
	local fiveItemPressedBox      = Tile:loadImage( imgpath .. "5_line_lists/menu_sel_box_5line_press.png")
	local threeItemSelectionBox   = Tile:loadImage( imgpath .. "3_line_lists/menu_sel_box_3line.png")
	local threeItemPressedBox     = Tile:loadImage( imgpath .. "3_line_lists/menu_sel_box_3line_press.png")
	local keyboardPressedBox      = Tile:loadImage( imgpath .. "Buttons/keyboard_button_press.png")

	local backButton              = Tile:loadImage( imgpath .. "Icons/icon_back_button_tb.png")
	local helpButton              = Tile:loadImage( imgpath .. "Buttons/button_help_tb.png")
	local nowPlayingButton        = Tile:loadImage( imgpath .. "Icons/icon_nplay_button_tb.png")
	local textinputBackground     = 
		Tile:loadTiles({
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box.png",
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_tl.png",
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_t.png",
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_tr.png",
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_r.png",
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_br.png",
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_b.png",
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_bl.png",
				 imgpath .. "Text_Entry/Keyboard_Touch/text_entry_titlebar_box_l.png",
				})

	local buttonBox =
		Tile:loadTiles({
					nil, 
					imgpath .. "Text_Entry/Keyboard_Touch/button_qwerty_tl.png",
					imgpath .. "Text_Entry/Keyboard_Touch/button_qwerty_t.png",
					imgpath .. "Text_Entry/Keyboard_Touch/button_qwerty_tr.png",
					imgpath .. "Text_Entry/Keyboard_Touch/button_qwerty_r.png",
					imgpath .. "Text_Entry/Keyboard_Touch/button_qwerty_br.png",
					imgpath .. "Text_Entry/Keyboard_Touch/button_qwerty_b.png",
					imgpath .. "Text_Entry/Keyboard_Touch/button_qwerty_bl.png",
					imgpath .. "Text_Entry/Keyboard_Touch/button_qwerty_l.png",
				})

	local pressedTitlebarButtonBox =
		Tile:loadTiles({
					imgpath .. "Buttons/button_titlebar_press.png",
					imgpath .. "Buttons/button_titlebar_tl_press.png",
					imgpath .. "Buttons/button_titlebar_t_press.png",
					imgpath .. "Buttons/button_titlebar_tr_press.png",
					imgpath .. "Buttons/button_titlebar_r_press.png",
					imgpath .. "Buttons/button_titlebar_br_press.png",
					imgpath .. "Buttons/button_titlebar_b_press.png",
					imgpath .. "Buttons/button_titlebar_bl_press.png",
					imgpath .. "Buttons/button_titlebar_l_press.png",
				})

	local titlebarButtonBox =
		Tile:loadTiles({
					imgpath .. "Buttons/button_titlebar.png",
					imgpath .. "Buttons/button_titlebar_tl.png",
					imgpath .. "Buttons/button_titlebar_t.png",
					imgpath .. "Buttons/button_titlebar_tr.png",
					imgpath .. "Buttons/button_titlebar_r.png",
					imgpath .. "Buttons/button_titlebar_br.png",
					imgpath .. "Buttons/button_titlebar_b.png",
					imgpath .. "Buttons/button_titlebar_bl.png",
					imgpath .. "Buttons/button_titlebar_l.png",
				})

-- FIXME: do these need updating for Fab4Skin?
	local helpBox = 
		Tile:loadTiles({
				       imgpath .. "Popup_Menu/helpbox.png",
				       imgpath .. "Popup_Menu/helpbox_tl.png",
				       imgpath .. "Popup_Menu/helpbox_t.png",
				       imgpath .. "Popup_Menu/helpbox_tr.png",
				       imgpath .. "Popup_Menu/helpbox_r.png",
				       imgpath .. "Popup_Menu/helpbox_br.png",
				       imgpath .. "Popup_Menu/helpbox_b.png",
				       imgpath .. "Popup_Menu/helpbox_bl.png",
				       imgpath .. "Popup_Menu/helpbox_l.png",
			       })

	local scrollBackground =
		Tile:loadVTiles({
					imgpath .. "Scroll_Bar/scrollbar_bkgrd_tch_t.png",
					imgpath .. "Scroll_Bar/scrollbar_bkgrd_tch.png",
					imgpath .. "Scroll_Bar/scrollbar_bkgrd_tch_b.png",
				})

	local scrollBar = 
		Tile:loadVTiles({
					imgpath .. "Scroll_Bar/scrollbar_body_t.png",
					imgpath .. "Scroll_Bar/scrollbar_body.png",
					imgpath .. "Scroll_Bar/scrollbar_body_b.png",
			       })

	local sliderBackground = 
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_bkgrd_l.png",
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_bkgrd.png",
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_bkgrd_r.png",
			       })

	local sliderBar = 
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_fill_l.png",
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_fill.png",
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_fill_r.png",
			       })

	local volumeBar =
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_fill_l.png",
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_fill.png",
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_fill_r.png",
			       })

	local volumeBackground =
		Tile:loadHTiles({
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_bkgrd_l.png",
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_bkgrd.png",
					imgpath .. "Song_Progress_Bar/SP_Bar_Remote/rem_progbar_bkgrd_r.png",
				})

	local popupMask = Tile:fillColor(0x000000e5)

	local textinputCursor = Tile:loadImage(imgpath .. "Text_Entry/Keyboard_Touch/tch_cursor.png")

	local THUMB_SIZE = self:getSettings().THUMB_SIZE
	
	local TITLE_PADDING  = 0
	local CHECK_PADDING  = { 2, 0, 6, 0 }
	local CHECKBOX_RADIO_PADDING  = { 2, 8, 8, 0 }

	--FIXME: paddings here need tweaking for Fab4Skin
	local MENU_ALBUMITEM_PADDING = { 8, 1, 8, 1 }
	local MENU_ALBUMITEM_TEXT_PADDING = { 16, 6, 9, 19 }
	local MENU_PLAYLISTITEM_TEXT_PADDING = { 16, 1, 9, 1 }

	local MENU_CURRENTALBUM_TEXT_PADDING = { 6, 20, 0, 10 }
	local TEXTAREA_PADDING = { 50, 20, 50, 20 }

	local TEXT_COLOR = { 0xE7, 0xE7, 0xE7 }
	local TEXT_COLOR_BLACK = { 0x00, 0x00, 0x00 }
	local TEXT_SH_COLOR = { 0x37, 0x37, 0x37 }

	local SELECT_COLOR = { 0xE7, 0xE7, 0xE7 }
	local SELECT_SH_COLOR = { }

	local TITLE_FONT_SIZE = 20
	local ALBUMMENU_FONT_SIZE = 18
	local ALBUMMENU_SMALL_FONT_SIZE = 14
	local TEXTMENU_FONT_SIZE = 20
	local POPUP_TEXT_SIZE_1 = 34
	local POPUP_TEXT_SIZE_2 = 26
	local TRACK_FONT_SIZE = 18
	local TEXTAREA_FONT_SIZE = 18
	local CENTERED_TEXTAREA_FONT_SIZE = 28
	local TEXTINPUT_FONT_SIZE = 20
	local TEXTINPUT_SELECTED_FONT_SIZE = 28
	local HELP_FONT_SIZE = 18
	local UPDATE_SUBTEXT_SIZE = 20

	local ITEM_ICON_ALIGN   = 'center'
	local THREE_ITEM_HEIGHT = 72
	local FIVE_ITEM_HEIGHT = 45
	local TITLE_BUTTON_WIDTH = 76
	local TITLE_BUTTON_HEIGHT = 47
	local TITLE_BUTTON_PADDING = { 4, 0, 4, 0 }

	local smallSpinny = {
		img = _loadImage(self, "Alerts/wifi_connecting_sm.png"),
		frameRate = 8,
		frameWidth = 26,
		padding = { 0, 0, 8, 0 },
		h = WH_FILL,
	}
	local largeSpinny = {
		img = _loadImage(self, "Alerts/wifi_connecting.png"),
		position = LAYOUT_CENTER,
		w = WH_FILL,
		align = "center",
		frameRate = 8,
		frameWidth = 120,
		padding = { 0, 0, 0, 10 }
	}
	-- convenience method for removing a button from the window
	local noButton = { 
		img = false, 
		bgImg = false, 
		w = 0 
	}

	local playArrow = { 
		img = _loadImage(self, "Icons/selection_play_3line_on.png"),
	}
	local addArrow  = { 
		img = _loadImage(self, "Icons/selection_add_3line_off.png"),
	}


	---- REVIEWED BELOW THIS LINE ----

--------- CONSTANTS ---------

	local _progressBackground = Tile:loadImage(imgpath .. "Alerts/alert_progress_bar_bkgrd.png")

	local _progressBar = Tile:loadHTiles({
		nil,
		imgpath .. "Alerts/alert_progress_bar_body.png",
		imgpath .. "Alerts/progress_bar_line.png",
	})



--------- DEFINES ---------

	local _buttonMenu = {
		padding = 0,
		w = WH_FILL,
		itemHeight = THREE_ITEM_HEIGHT,
	}

	local _buttonItem = {
		order = { "text", "arrow" },
		padding = 0,
		bgImg = threeItemSelectionBox,
		text = {
		w = WH_FILL,
		h = WH_FILL,
		padding = { 8, 0, 0, 0 },
		align = "left",
		font = _boldfont(34),
		fg = SELECT_COLOR,
		sh = SELECT_SH_COLOR,
		},
		arrow = {
			img     = _loadImage(self, "Icons/selection_right_3line_off.png"), 
			w       = 37,
			h       = WH_FILL,
			padding = { 0, 0, 8, 0}
		}
	}


--------- DEFAULT WIDGET STYLES ---------
	--
	-- These are the default styles for the widgets 

	s.window = {
		w = screenWidth,
		h = screenHeight,
	}

	s.popup = _uses(s.window, {
		border = { 25, 0, 25, 0 },
		maskImg = popupMask,
	})

	s.title = {
		h = 47,
		border = 0,
		position = LAYOUT_NORTH,
		bgImg = titleBox,
		order = { "lbutton", "text", "rbutton" },
		text = {
			w = WH_FILL,
			padding = TITLE_PADDING,
			align = "center",
			font = _boldfont(TITLE_FONT_SIZE),
			fg = TEXT_COLOR,
		}
	}

	s.menu = {
		position = LAYOUT_CENTER,
		padding = { 0, 0, 0, 0 },
		itemHeight = 45,
		fg = {0xbb, 0xbb, 0xbb },
		font = _boldfont(250),
	}

	s.item = {
		order = { "text", "arrow" },
		padding = { 4, 0, 0, 0 },
		text = {
			padding = { 6, 5, 2, 5 },
			align = "left",
			w = WH_FILL,
			h = WH_FILL,
			font = _boldfont(TEXTMENU_FONT_SIZE),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
		arrow = {
	      		align = ITEM_ICON_ALIGN,
	      		img = _loadImage(self, "Icons/selection_right_5line.png")
		},
	}

	s.itemPlay = _uses(s.item, { 
		arrow = playArrow 
	})
	s.itemAdd = _uses(s.item, { 
		arrow = addArrow 
	})

	-- Checkbox
        s.checkbox = {}
        s.checkbox.imgOn = _loadImage(self, "Icons/checkbox_on.png")
        s.checkbox.imgOff = _loadImage(self, "Icons/checkbox_off.png")


        -- Radio button
        s.radio = {}
        s.radio.imgOn = _loadImage(self, "Icons/radiobutton_on.png")
        s.radio.imgOff = _loadImage(self, "Icons/radiobutton_off.png")

	s.itemChoice = _uses(s.item, {
		order  = { 'text', 'icon' },
		icon = {
			align = 'right',
			font = _boldfont(TEXTMENU_FONT_SIZE),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
		},
	})
	s.itemChecked = _uses(s.item, {
		order = { "text", "check", "arrow" },
		check = {
			align = ITEM_ICON_ALIGN,
			padding = CHECK_PADDING,
			img = _loadImage(self, "Icons/icon_check_5line.png")
	      	}
	})

	s.itemNoArrow = _uses(s.item, {
		order = { 'icon', 'text' },
	})
	s.itemCheckedNoArrow = _uses(s.item, {
		order = { 'icon', 'text', 'check' },
	})

	s.selected = {
		item               = _uses(s.item),
		itemPlay           = _uses(s.itemPlay),
		itemAdd            = _uses(s.itemAdd),
		itemChecked        = _uses(s.itemChecked),
		itemNoArrow        = _uses(s.itemNoArrow),
		itemCheckedNoArrow = _uses(s.itemCheckedNoArrow),
		itemChoice         = _uses(s.itemChoice),
	}

	s.pressed = {
		item = _uses(s.item, {
			bgImg = fiveItemPressedBox,
		}),
		itemChecked = _uses(s.itemChecked, {
			bgImg = fiveItemPressedBox,
		}),
		itemPlay = _uses(s.itemPlay, {
			bgImg = fiveItemPressedBox,
		}),
		itemAdd = _uses(s.itemAdd, {
			bgImg = fiveItemPressedBox,
		}),
		itemNoArrow = _uses(s.itemNoArrow, {
			bgImg = fiveItemPressedBox,
		}),
		itemCheckedNoArrow = _uses(s.itemCheckedNoArrow, {
			bgImg = fiveItemPressedBox,
		}),
		itemChoice = _uses(s.itemChoice, {
			bgImg = fiveItemPressedBox,
		}),
	}

	s.locked = {
		item = _uses(s.pressed.item, {
			arrow = smallSpinny
		}),
		itemChecked = _uses(s.pressed.itemChecked, {
			arrow = smallSpinny
		}),
		itemPlay = _uses(s.pressed.itemPlay, {
			arrow = smallSpinny
		}),
		itemAdd = _uses(s.pressed.itemAdd, {
			arrow = smallSpinny
		}),
		itemNoArrow = _uses(s.itemNoArrow, {
			arrow = smallSpinny
		}),
		itemCheckedNoArrow = _uses(s.itemCheckedNoArrow, {
			arrow = smallSpinny
		}),
	}

	s.helptext = {
		w = screenWidth - 6,
		position = LAYOUT_SOUTH,
		padding = 12,
		font = _font(HELP_FONT_SIZE),
		fg = TEXT_COLOR,
		bgImg = helpBox,
		align = "left",
		scrollbar = {
			w = 0,
		},
	}

	s.scrollbar = {
		w = 34,
		border = 0,
		padding = { 0, 24, 0, 24 },
		horizontal = 0,
		bgImg = scrollBackground,
		img = scrollBar,
		layer = LAYER_CONTENT_ON_STAGE,
	}

	s.text = {
		w = screenWidth,
		padding = TEXTAREA_PADDING,
		font = _boldfont(TEXTAREA_FONT_SIZE),
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
		align = "left",
	}

	s.slider = {
		w = WH_FILL,
		border = 5,
		horizontal = 1,
		bgImg = sliderBackground,
		img = sliderBar,
	}

	s.slider_group = {
		w = WH_FILL,
		border = { 0, 5, 0, 10 },
		order = { "min", "slider", "max" },
	}


--------- SPECIAL WIDGETS ---------


	-- text input
	s.textinput = {
		h = 35,
		border = { 8, 0, 8, 0 },
		padding = { 6, 0, 6, 0 },
		font = _boldfont(TEXTINPUT_FONT_SIZE),
		cursorFont = _boldfont(TEXTINPUT_SELECTED_FONT_SIZE),
		wheelFont = _boldfont(TEXTINPUT_FONT_SIZE),
		charHeight = TEXTINPUT_SELECTED_FONT_SIZE + 10,
		fg = TEXT_COLOR_BLACK,
		wh = { 0x55, 0x55, 0x55 },
		bgImg = textinputBackground,
		cursorImg = textinputCursor,
--		enterImg = Tile:loadImage(imgpath .. "Icons/selection_right_5line.png"),
	}

	-- keyboard
	-- XXXX pressed button states?
	s.keyboard = {
		w = WH_FILL,
		h = WH_FILL,
		border = { 8, 0, 8, 0 },
	}

	s.keyboard.button = {
        	padding = 0,
		w = 45,
		h= 45,
        	font = _boldfont(18),
        	fg = TEXT_COLOR,
        	bgImg = buttonBox,
        	align = 'center',
	}

	s.keyboard.shift = _uses(s.keyboard.button, {
		bgImg = fiveItemSelectionBox, padding = 2, w = 75, h = 35
	})
	s.keyboard.space = _uses(s.keyboard.shift, {
		padding = 2, w = 100, h = 35
	})
	s.keyboard.back = _uses(s.keyboard.button, {
		img = _loadImage(self, "Icons/Mini/left_arrow.png")
	})
	s.keyboard.qwertyLower = _uses(s.keyboard.button, {
		img = _loadImage(self, "Icons/icon_shift_off.png")
	})
	s.keyboard.qwertyUpper = _uses(s.keyboard.button, {
		img = _loadImage(self, "Icons/icon_shift_on.png")
	})

	s.keyboard.enter = _uses(s.keyboard.shift, {
		img = _loadImage(self, "Icons/Mini/right_arrow.png")
	})
	s.keyboard.search = _uses(s.keyboard.button, {
		img = _loadImage(self, "Icons/Mini/icon_search.png")
	})

	s.keyboard.pressed = {
		button = _uses(s.keyboard.button, {
			bgImg = keyboardPressedBox
		}),
		enter = _uses(s.keyboard.enter, {
			bgImg = keyboardPressedBox
		}),
		search = _uses(s.keyboard.search, {
			bgImg = keyboardPressedBox
		}),
		back = _uses(s.keyboard.back, {
			bgImg = keyboardPressedBox
		}),
		shift = _uses(s.keyboard.shift, {
			bgImg = keyboardPressedBox
		}),
		space = _uses(s.keyboard.space, {
			bgImg = keyboardPressedBox
		}),
	}
	s.keyboard.pushed = _uses(s.keyboard.pressed.shift)
	s.keyboard.pressed.pushed = _uses(s.keyboard.pressed.shift)

--------- WINDOW STYLES ---------
	--
	-- These styles override the default styles for a specific window

	-- setup window
	s.setuplist = _uses(s.window)


	-- window with one option in "button" style
	s.onebutton = _uses(s.setuplist)
	s.onebutton.menu = _uses(_buttonMenu, {
			position = LAYOUT_SOUTH,
			h = THREE_ITEM_HEIGHT
	})

	s.onebutton.menu.item = {
		order = { "text", "arrow" },
		padding = 0,
		bgImg = threeItemSelectionBox,
		text = {
			w = WH_FILL,
			h = WH_FILL,
			padding = { 8, 0, 0, 0 },
			align = "left",
			font = _boldfont(34),
			fg = TEXT_COLOR,
			sh = TEXT_SH_COLOR,
			arrow = {
				img = _loadImage(self, "Icons/selection_right_3line_off.png"), 
				w = 37,
				h = WH_FILL,
				padding = { 0, 0, 8, 0},
			}
		}
	}

	s.onebutton.menu.selected = {
		item = _uses(s.onebutton.menu.item)
	}
	s.onebutton.menu.pressed = {
		item = _uses(s.onebutton.menu.item, { 
				bgImg = threeItemPressedBox 
		})
	}

	s.onebutton.text = {
		w = screenWidth,
		position = LAYOUT_NORTH,
		padding = { 16, 72, 35, 2 },
		font = _font(36),
		lineHeight = 40,
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
	}


	-- window with multiple options in "button" style
	s.buttonlist = _uses(s.window)

	s.buttonlist.title = _uses(s.title, {
		h = 55
	})

	s.buttonlist.menu = {
		padding = 0,
		w = WH_FILL,
		itemHeight = THREE_ITEM_HEIGHT,
	}

	s.buttonlist.menu.item = _uses(_buttonItem, {
		order = { "icon", "text", "arrow" },
		icon  = s.buttonicon,
	})

	s.buttonlist.menu.itemChecked = _uses(_buttonItem, {
		order = { 'icon', 'text', 'check', 'arrow' },
		check = {
			img     = _loadImage(self, "Icons/icon_check_3line.png"), 
			w       = 37,
			h       = WH_FILL,
			padding = { 2, 0, 18, 10 },
		}
	})

	s.buttonlist.menu.selected = {
		item = _uses(s.buttonlist.menu.item),
		itemChecked = _uses(s.buttonlist.menu.itemChecked),
	}
	s.buttonlist.menu.pressed = {
		item = _uses(s.buttonlist.menu.item, { 
			bgImg = threeItemPressedBox 
		}),
		itemChecked = _uses(s.buttonlist.menu.itemChecked, { 
			bgImg = threeItemPressedBox 
		}),
	}

	-- popup "spinny" window
	s.waiting = _uses(s.popup)

	s.waiting.text = {
		border = { 15, 0, 15, 20 },
		font = _boldfont(POPUP_TEXT_SIZE_1),
		fg = TEXT_COLOR,
		lineHeight = POPUP_TEXT_SIZE_1 + 8,
		sh = TEXT_SH_COLOR,
		align = "top",
		position = LAYOUT_NORTH,
		h = (POPUP_TEXT_SIZE_1 + 8 ) * 2,
	}

	s.waiting.subtext = {
		padding = { 0, 0, 0, 26 },
		font = _boldfont(POPUP_TEXT_SIZE_2),
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
		align = "bottom",
		position = LAYOUT_SOUTH,
		h = 40,
	}

	-- input window (including keyboard)
	-- XXX: needs layout
	s.input = _uses(s.window)

	-- error window
	-- XXX: needs layout
	s.error = _uses(s.window)

	-- update window
	s.update = _uses(s.popup)

	s.update.text = {
		border = { 15, 0, 15, 20 },
		font = _boldfont(POPUP_TEXT_SIZE_1),
		fg = TEXT_COLOR,
		lineHeight = POPUP_TEXT_SIZE_1 + 8,
		sh = TEXT_SH_COLOR,
		align = "top",
		position = LAYOUT_NORTH,
		h = (POPUP_TEXT_SIZE_1 + 8) * 2,
	}

	s.update.subtext = {
		padding = { 0, 0, 0, 30 },
		font = _font(UPDATE_SUBTEXT_SIZE),
		fg = TEXT_COLOR,
		sh = TEXT_SH_COLOR,
		align = "bottom",
		position = LAYOUT_SOUTH,
		h = 40,
	}

	s.update.progress = {
		border = 10,
		position = LAYOUT_SOUTH,
		horizontal = 1,
		bgImg = _progressBackground,
		img = _progressBar,
	}

	-- typical text list window
	-- XXXX todo
	s.text_list = _uses(s.window)

	-- icon_list window
	s.icon_list = _uses(s.window, {
		menu = {
			item = {
				order = { "icon", "text", "arrow" },
				padding = MENU_ALBUMITEM_PADDING,
				text = {
					w = WH_FILL,
					h = WH_FILL,
					padding = MENU_ALBUMITEM_TEXT_PADDING,
					font = _font(ALBUMMENU_SMALL_FONT_SIZE),
					line = {
						{
							font = _boldfont(ALBUMMENU_FONT_SIZE),
							height = ALBUMMENU_FONT_SIZE + 2
						}
					},
					fg = TEXT_COLOR,
					sh = TEXT_SH_COLOR,
				},
				icon = {
					w = THUMB_SIZE,
					h = THUMB_SIZE,
				},
				arrow = {
				      align = ITEM_ICON_ALIGN,
					w = 30,
					padding = { 8, 1, 8, 1 },
				      img = _loadImage(self, "Icons/selection_right_5line.png")
				},
			},
		},
	})


	s.icon_list.menu.itemChecked = _uses(s.icon_list.menu.item, {
		order = { 'icon', 'text', 'check', 'arrow' },
		check = {
			align = ITEM_ICON_ALIGN,
			padding = CHECK_PADDING,
			img = _loadImage(self, "Icons/icon_check_5line.png")
		},
	})
	s.icon_list.menu.itemPlay = _uses(s.icon_list.menu.item, { 
		arrow = playArrow, 
	})
	s.icon_list.menu.itemAdd  = _uses(s.icon_list.menu.item, { 
		arrow = addArrow,
	})
	s.icon_list.menu.itemNoArrow = _uses(s.icon_list.menu.item, {
		order = { 'icon', 'text' },
	})
	s.icon_list.menu.itemCheckedNoArrow = _uses(s.icon_list.menu.itemChecked, {
		order = { 'icon', 'text', 'check' },
	})

	s.icon_list.menu.selected = {
                item               = _uses(s.icon_list.menu.item),
                itemChecked        = _uses(s.icon_list.menu.itemChecked),
		itemPlay           = _uses(s.icon_list.menu.itemPlay),
		itemAdd            = _uses(s.icon_list.menu.itemAdd),
		itemNoArrow        = _uses(s.icon_list.menu.itemNoArrow),
		itemCheckedNoArrow = _uses(s.icon_list.menu.itemCheckedNoArrow),
        }
        s.icon_list.menu.pressed = {
                item = _uses(s.icon_list.menu.item, { 
			bgImg = threeItemPressedBox 
		}),
                itemChecked = _uses(s.icon_list.menu.itemChecked, { 
			bgImg = threeItemPressedBox 
		}),
                itemPlay = _uses(s.icon_list.menu.itemPlay, { 
			bgImg = threeItemPressedBox 
		}),
                itemAdd = _uses(s.icon_list.menu.itemAdd, { 
			bgImg = threeItemPressedBox 
		}),
                itemNoArrow = _uses(s.icon_list.menu.itemNoArrow, { 
			bgImg = threeItemPressedBox 
		}),
                itemCheckedNoArrow = _uses(s.icon_list.menu.itemCheckedNoArrow, { 
			bgImg = threeItemPressedBox 
		}),
        }
	s.icon_list.menu.locked = {
		item = _uses(s.icon_list.menu.pressed.item, {
			arrow = smallSpinny
		}),
		itemChecked = _uses(s.icon_list.menu.pressed.itemChecked, {
			arrow = smallSpinny
		}),
		itemPlay = _uses(s.icon_list.menu.pressed.itemPlay, {
			arrow = smallSpinny
		}),
		itemAdd = _uses(s.icon_list.menu.pressed.itemAdd, {
			arrow = smallSpinny
		}),
	}


	-- information window
	s.information = _uses(s.window)


	-- help window (likely the same as information)
	s.help = _uses(s.window)


	--tracklist window
	-- XXXX todo
	-- identical to text_list but has icon in upper left of titlebar
	s.tracklist = _uses(s.text_list)

	s.tracklist.title = _uses(s.title, {
		order = { 'lbutton', 'icon', 'text', 'rbutton' },		
		icon  = {
			w = THUMB_SIZE,
			h = WH_FILL,
			padding = { 8, 1, 8, 1 },
		},
	})

	--playlist window
	-- identical to icon_list but with some different formatting on the text
	s.playlist = _uses(s.icon_list, {
		menu = {
			item = {
				text = {
					padding = MENU_PLAYLISTITEM_TEXT_PADDING,
					line = {
						{
							font = _boldfont(ALBUMMENU_FONT_SIZE),
							height = ALBUMMENU_FONT_SIZE
						},
						{
							height = ALBUMMENU_SMALL_FONT_SIZE + 2
						},
						{
							height = ALBUMMENU_SMALL_FONT_SIZE + 2
						},
					},	
				},
			},
		},
	})
	s.playlist.menu.itemChecked = _uses(s.playlist.menu.item, {
		order = { 'icon', 'text', 'check', 'arrow' },
		check = {
			align = ITEM_ICON_ALIGN,
			padding = CHECK_PADDING,
			img = _loadImage(self, "Icons/icon_check_5line.png")
		},
	})
	s.playlist.menu.selected = {
                item = _uses(s.playlist.menu.item),
                itemChecked = _uses(s.playlist.menu.itemChecked),
        }
        s.playlist.menu.pressed = {
                item = _uses(s.playlist.menu.item, { bgImg = threeItemPressedBox }),
                itemChecked = _uses(s.playlist.menu.itemChecked, { bgImg = threeItemPressedBox }),
        }
	s.playlist.menu.locked = {
		item = _uses(s.playlist.menu.pressed.item, {
			arrow = smallSpinny
		}),
		itemChecked = _uses(s.playlist.menu.pressed.itemChecked, {
			arrow = smallSpinny
		}),
	}


	-- toast popup
	s.toast = {
		x = 0,
		y = screenHeight - 93,
		w = screenWidth,
		h = 93,
		bgImg = helpBox,
		group = {
			padding = 10,
			order = { 'icon', 'text' },
			text = { 
				padding = { 10, 12, 12, 12 } ,
				align = 'top-left',
				w = WH_FILL,
				h = WH_FILL,
				font = _font(HELP_FONT_SIZE),
			},
			icon = { 
				align = 'top-left', 
				border = { 12, 12, 0, 0 },
				img = _loadImage(self, "Icons/menu_album_noartwork_64.png"),
				h = WH_FILL,
				w = 64,
			}
		}
	}

	-- slider popup (volume/scanner)
	s.slider_popup = {
		x = 50,
		y = screenHeight - 100,
		w = screenWidth - 100,
		h = 100,
		bgImg = helpBox,
		title = {
		      border = 10,
		      fg = TEXT_COLOR,
		      font = FONT_BOLD_15px,
		      align = "center",
		      bgImg = false,
		},
		text = _uses(s.text),
		slider_group = {
			w = WH_FILL,
			border = { 0, 5, 0, 10 },
			order = { "min", "slider", "max" },
		},
	}


--------- SLIDERS ---------

	s.volume_slider = _uses(s.slider, {
		img = volumeBar,
		bgImg = volumeBackground,
	})

--------- BUTTONS ---------


	-- XXXX could use a factory function
	local _button = {
		bgImg = titlebarButtonBox,
		w = TITLE_BUTTON_WIDTH,
		h = TITLE_BUTTON_HEIGHT,
		align = 'center',
		border = TITLE_BUTTON_PADDING,
	}
	local _pressed_button = _uses(_button, {
		bgImg = pressedTitlebarButtonBox,
	})


	-- invisible button
	s.button_none = _uses(_button, {
		bgImg    = false
	})

	s.button_back = _uses(_button, {
		img      = backButton,
	})
	s.pressed.button_back = _uses(_pressed_button, {
		img      = backButton,
	})

	s.button_go_now_playing = _uses(_button, {
		img      = nowPlayingButton,
	})
	s.pressed.button_go_now_playing = _uses(_pressed_button, {
		img      = nowPlayingButton,
	})

	s.button_help = _uses(_button, {
		img = helpButton,
	})
	s.pressed.button_help = _uses(_pressed_button, {
		img      = helpButton,
	})

	s.button_volume_min = {
		img = _loadImage(self, "Icons/volume_speaker_l.png"),
		border = { 5, 0, 5, 0 },
	}

	s.button_volume_max = {
		img = _loadImage(self, "Icons/volume_speaker_r.png"),
		border = { 5, 0, 5, 0 },
	}


	local _buttonicon = {
		w = 72,
		h = WH_FILL,
		padding = { 8, 4, 0, 4 },
		img = false
	}

	s.region_US = _uses(_buttonicon, { 
		img = _loadImage(self, "Icons/icon_region_americas_64.png")
	})
	s.region_XX = _uses(_buttonicon, { 
		img = _loadImage(self, "Icons/icon_region_other_64.png")
	})
	s.wlan = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/icon_wireless_64.png")
	})
	s.wired = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/icon_ethernet_64.png")
	})


--------- ICONS --------

	-- icons used for 'waiting' and 'update' windows
	local _icon = {
		w = WH_FILL,
		align = "center",
		position = LAYOUT_CENTER,
		padding = { 0, 0, 0, 10 }
	}

	-- icon for albums with no artwork
	s.icon_no_artwork = {
		img = _loadImage(self, "Icons/menu_album_noartwork_43.png"),
		w   = THUMB_SIZE,
		h   = THUMB_SIZE,
	}

	s.iconConnecting = _uses(_icon, {
		img = _loadImage(self, "Alerts/wifi_connecting.png"),
		frameRate = 8,
		frameWidth = 120,
	})

	s.iconConnected = _uses(_icon, {
		img = _loadImage(self, "Alerts/connecting_success_icon.png"),
	})

	s.iconSoftwareUpdate = _uses(_icon, {
		img = _loadImage(self, "Icons/icon_firmware_update_100.png"),
	})

	s.iconPower = _uses(_icon, {
		img = _loadImage(self, "Alerts/popup_shutdown_icon.png"),
	})

	s.iconLocked = _uses(_icon, {
		img = _loadImage(self, "Alerts/popup_locked_icon.png"),
	})

	s.iconAlarm = _uses(_icon, {
		img = _loadImage(self, "Alerts/popup_alarm_icon.png"),
	})


	-- button icons, on left of menus
	local _buttonicon = {
		w = 72,
		h = WH_FILL,
		padding = { 8, 4, 0, 4 },
	}

	s.player_transporter = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/transporter.png"),
	})
	s.player_squeezebox = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/squeezebox.png"),
	})
	s.player_squeezebox2 = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/squeezebox.png"),
	})
	s.player_squeezebox3 = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/squeezebox3.png"),
	})
	s.player_boom = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/boom.png"),
	})
	s.player_slimp3 = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/slimp3.png"),
	})
	s.player_softsqueeze = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/softsqueeze.png"),
	})
	s.player_controller = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/controller.png"),
	})
	s.player_receiver = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/receiver.png"),
	})
	s.player_squeezeplay = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/squeezeplay.png"),
	})
	s.player_http = _uses(_buttonicon, {
		img = _loadImage(self, "Icons/Players/http.png"),
	})


	-- indicator icons, on right of menus
	local _indicator = {
		align = "right",
	}

	s.wirelessLevel1 = _uses(_indicator, {
		img = _loadImage(self, "Icons/icon_wireless_1_shadow.png")
	})

	s.wirelessLevel2 = _uses(_indicator, {
		img = _loadImage(self, "Icons/icon_wireless_2_shadow.png")
	})

	s.wirelessLevel3 = _uses(_indicator, {
		img = _loadImage(self, "Icons/icon_wireless_3_shadow.png")
	})

	s.wirelessLevel4 = _uses(_indicator, {
		img = _loadImage(self, "Icons/icon_wireless_4_shadow.png")
	})


--------- ICONBAR ---------

	-- time (hidden off screen)
	s.iconTime = {
		x = screenWidth + 10,
		y = screenHeight + 10,
		layer = LAYER_FRAME,
		position = LAYOUT_NONE,
	}



--------- LEGACY STYLES TO KEEP SLIMBROWSER GOING --------
if true then

	-- XXXX todo

	-- BEGIN NowPlaying skin code
	-- this skin is established in two forms,
	-- one for the Screensaver windowStyle (ss), one for the browse windowStyle (browse)
	-- a lot of it can be recycled from one to the other

	local NP_TRACK_FONT_SIZE = 26

	-- Title
	s.ssnptitle = _uses(s.title, {
		rbutton  = {
			font    = _font(14),
			fg      = TEXT_COLOR,
			bgImg   = titlebarButtonBox,
			w       = TITLE_BUTTON_WIDTH,
			h       = TITLE_BUTTON_HEIGHT,
			padding =  TITLE_BUTTON_PADDING,
			padding = { 10, 0, 10, 0},
			align   = 'center',
		}
	})

	-- nptitle style is the same for all windowStyles
	s.browsenptitle = _uses(s.ssnptitle)
	s.largenptitle  = _uses(s.ssnptitle)


	-- pressed styles
	s.ssnptitle.pressed = _uses(s.ssnptitle, {
		lbutton = {
			bgImg = pressedTitlebarButtonBox,
		},
		rbutton = {
			bgImg = pressedTitlebarButtonBox,
		},
	})

	s.browsenptitle.pressed = _uses(s.ssnptitle.pressed)
	s.largenptitle.pressed = _uses(s.ssnptitle.pressed)

	-- Song
	s.ssnptrack = {
		border = { 4, 0, 4, 0 },
		position = LAYOUT_WEST,
		text = {
			w = WH_FILL,
			padding = { 220, 52, 20, 10 },
			align = "left",
        		font = _font(NP_TRACK_FONT_SIZE),
			lineHeight = NP_TRACK_FONT_SIZE + 4,
			fg = TEXT_COLOR,
        		line = {{
				font = _boldfont(NP_TRACK_FONT_SIZE),
				height = NP_TRACK_FONT_SIZE + 4,
				}},
		},
	}

	-- nptrack is identical between all windowStyles
	s.browsenptrack = _uses(s.ssnptrack)
	s.largenptrack  = _uses(s.ssnptrack)

	-- Artwork
	local ARTWORK_SIZE    = self:getSettings().nowPlayingBrowseArtworkSize
	local SS_ARTWORK_SIZE = self:getSettings().nowPlayingSSArtworkSize
	local browseArtWidth  = ARTWORK_SIZE
	local ssArtWidth      = SS_ARTWORK_SIZE

	s.ssnpartwork = {
		w = ssArtWidth,
		border = { 10, 50, 10, 0 },
		position = LAYOUT_WEST,
		align = "center",
		artwork = {
			align = "center",
			padding = 0,
			-- FIXME: this is a placeholder
			img = _loadImage(self, "Icons/icon_album_noartwork_190.png"),
		},
	}

	s.browsenpartwork = _uses(s.ssnpartwork)
	s.largenpartwork = _uses(s.ssnpartwork)

	local topPadding = screenHeight/2 + 10
	local rightPadding = screenWidth/2 - 15
	local buttonPadding = { 10, 5, 10, 5 }

	s.ssnpcontrols = {
		order = { 'rew', 'play', 'fwd', 'vol' },
		position = LAYOUT_NONE,
		x = rightPadding,
		y = topPadding,
		bgImg = buttonBox,
		rew = {
			align = 'center',
			padding = buttonPadding,
			img = _loadImage(self, "Player_Controls/icon_toolbar_rew.png"),
		},
		play = {
			align = 'center',
			padding = buttonPadding,
			img = _loadImage(self, "Player_Controls/icon_toolbar_play.png"),
		},
		pause = {
			align = 'center',
			padding = buttonPadding,
			img = _loadImage(self, "Player_Controls/icon_toolbar_pause.png"),
		},
		fwd = {
			align = 'center',
			padding = buttonPadding,
			img = _loadImage(self, "Player_Controls/icon_toolbar_ffwd.png"),
		},
		vol = {
			align = 'center',
			padding = buttonPadding,
			img = _loadImage(self, "Player_Controls/icon_toolbar_vol_up.png"),
		},
	}

	s.ssnpcontrols.pressed = {
		rew = _uses(s.ssnpcontrols.rew),
		play = _uses(s.ssnpcontrols.play),
		pause = _uses(s.ssnpcontrols.pause),
		fwd = _uses(s.ssnpcontrols.fwd),
		vol = _uses(s.ssnpcontrols.vol),
	}
	
	s.browsenpcontrols = _uses(s.ssnpcontrols)
	s.largenpcontrols  = _uses(s.ssnpcontrols)

	-- Progress bar
	s.ssprogress = {
		position = LAYOUT_SOUTH,
		padding = { 10, 10, 10, 5 },
		order = { "elapsed", "slider", "remain" },
		elapsed = {
			align = 'right',
		},
		remain = {
			align = 'left',
		},
		text = {
			w = 75,
			align = 'right',
			padding = { 8, 0, 8, 15 },
			font = _boldfont(18),
			fg = { 0xe7,0xe7, 0xe7 },
			sh = { 0x37, 0x37, 0x37 },
		},
	}

	s.ssprogress.elapsed = _uses(s.ssprogress.text)
	s.ssprogress.remain = _uses(s.ssprogress.text)

	s.browseprogress = _uses(s.ssprogress)
	s.largeprogress  = _uses(s.ssprogress)

	s.ssprogressB = {
		horizontal  = 1,
		bgImg       = sliderBackground,
		img         = sliderBar,
		position    = LAYOUT_SOUTH,
		padding     = { 0, 0, 0, 15 },
	}

	s.browseprogressB = _uses(s.ssprogressB)
	s.largeprogressB  = _uses(s.ssprogressB)

	-- special style for when there shouldn't be a progress bar (e.g., internet radio streams)
	s.ssprogressNB = {
		position = LAYOUT_SOUTH,
		padding = { 0, 0, 0, 5 },
		order = { "elapsed" },
		text = {
			w = WH_FILL,
			align = "center",
			padding = { 0, 0, 0, 5 },
			font = _boldfont(18),
			fg = { 0xe7, 0xe7, 0xe7 },
			sh = { 0x37, 0x37, 0x37 },
		},
	}

	s.ssprogressNB.elapsed = _uses(s.ssprogressNB.text)

	s.browseprogressNB = _uses(s.ssprogressNB)
	s.largeprogressNB  = _uses(s.ssprogressNB)


end -- LEGACY STYLES


end


--[[

=head1 LICENSE

Copyright 2007 Logitech. All Rights Reserved.

This file is subject to the Logitech Public Source License Version 1.0. Please see the LICENCE file for details.

=cut
--]]

