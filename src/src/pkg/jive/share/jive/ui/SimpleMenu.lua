--[[
=head1 NAME

jive.ui.SimpleMenu - A simple menu widget.

=head1 DESCRIPTION

A simple menu widget, extends L<jive.ui.Menu>.

=head1 SYNOPSIS

 -- Create a new menu
 local menu = jive.ui.Menu("menu",
		   {
			   {
				   "Item 1",
				   widget1,
				   function1
			   ),
			   {
				   "Item 2",
				   widget2,
				   function2
			   ),
		   })

=head1 STYLE

The Label includes the following style parameters in addition to the widgets basic parameters.

=over

B<itemHeight> : the height of each menu item.

=head1 METHODS

=cut
--]]


-- stuff we use
local assert, ipairs, string, tostring, type = assert, ipairs, string, tostring, type


local oo              = require("loop.simple")
local debug           = require("debug")

local Label           = require("jive.ui.Label")
local Menu            = require("jive.ui.Menu")
local Widget          = require("jive.ui.Widget")

local table           = require("jive.utils.table")
local log             = require("jive.utils.log").logger("ui")

local EVENT_ACTION    = jive.ui.EVENT_ACTION

local EVENT_CONSUME   = jive.ui.EVENT_CONSUME
local EVENT_UNUSED    = jive.ui.EVENT_UNUSED


-- our class
module(...)
oo.class(_M, Menu)

-- _coerce
-- returns value coerced between 1 and max
local function _coerce(value, max)
	if value < 1 then 
		return 1
	elseif value > max then
		return max
	end
	return value
end


-- _safeIndex
-- returns array[index] if index is in array bounds, nil otherwise
local function _safeIndex(array, index)
	if index and index>0 and index<=#array then
		return array[index]
	end
--	log:warn("_safeIndex failed - ", debug.traceback())
	return nil
end


-- _itemRenderer
-- updates the widgetList ready for the menu to be rendered
local function _itemRenderer(menu, widgetList, indexList, size, list)
	for i = 1,size do
		if indexList[i] ~= nil then
			local item = list[indexList[i]]

			if widgetList[i] == nil then
				widgetList[i] = Label("item", item[1], item[2])
			else
				widgetList[i]:setValue(item[1])
				widgetList[i]:setWidget(item[2])
			end
		end
	end
end


-- _itemListener
-- called for menu item events
local function _itemListener(menu, menuItem, list, index, event)
	local item = list[index]
	if event:getType() == EVENT_ACTION and type(item[3]) == "function" then
		local r = item[3](event, item)
		if r == nil then
			return EVENT_CONSUME
		else
			return r
		end
	end

	return EVENT_UNUSED
end


function __init(self, style, items)
	assert(type(style) == "string")

	local obj = oo.rawnew(self, Menu(style, _itemRenderer, _itemListener))
	obj.items = items or {}

	obj:setItems(obj.items, #obj.items)

	return obj
end


--[[

=head2 jive.ui.Menu:numItems()

Returns the top number of items in the menu.

=cut
--]]
function numItems(self)
	return #self.items
end


--[[

=head2 jive.ui.Menu:getItem(index)

Returns the item at the index I<index>.

=cut
--]]
function getItem(self, index)
	assert(type(index) == "number")

	return _safeIndex(self.items, index)
end


--[[

=head2 jive.ui.Menu:getIndex(item)

Returns the index of item I<item>, or nil if it is not in this menu.

=cut
--]]
function getIndex(self, item)
	for k,v in ipairs(self.items) do
		if item == v then
			return k
		end
	end

	return nil
end


--[[

=head2 jive.ui.Menu:setItems(items)

Efficiently replaces the current menu items, with I<items>.

=cut
--]]
function setItems(self, items)
	self.items = items

	Menu.setItems(self, self.items, #self.items)
end



--[[

=head2 jive.ui.Menu:addItem(item)

Add I<item> to the end of the menu.

=cut
--]]
function addItem(self, item)
	return self:insertItem(item, nil)
end


--[[

=head2 jive.ui.Menu:insertItem(item, index)

Insert I<item> into the menu at I<index>. The item can be any type of widget.

=cut
--]]
function insertItem(self, item, index)
	assert(index == nil or type(index) == "number")

	if index == nil then
		table.insert(self.items, item)
		index = #self.items
	else
		table.insert(self.items, _coerce(index, #self.items), item)
	end

	Menu.setItems(self, self.items, #self.items, index, index)
end


--[[

=head2 jive.ui.Menu:replaceIndex(item, index)

Replace the item at I<index> with I<item>.

=cut
--]]
function replaceIndex(self, item, index)
	assert(index and type(index) == "number")

	if _safeIndex(self.item, index) then
		self.items[index] = item
		Menu.setItems(self, self.items, #self.items, index, index)
	end
end


--[[

=head2 jive.ui.Menu:removeIndex(index)

Remove the item at I<index> from the menu. Returns the item removed from
the menu.

=cut
--]]
function removeIndex(self, index)
	assert(type(index) == "number")

	if _safeIndex(self.items, index) then

		local item = table.remove(self.items, index)
		if item ~= nil then
			Menu.setItems(self, self.items, #self.items, index, #self.items)
		end
	end
	return nil
end


--[[

=head2 jive.ui.Menu:removeItem(item)

Remove I<item> from the menu. Returns the item removed from the menu.

=cut
--]]
function removeItem(self, item)
	local index = self:getIndex(item)
	if index ~= nil then
		return self:removeIndex(index)
	else
		return nil
	end
end


--[[

=head2 jive.ui.Menu:updatedIndex(index)

Notifies the menu with the items at I<index> has changed. If neccessary this will cause the menu to be redrawn.

=cut
--]]
function updatedIndex(self, index)
	assert(type(index) == "number")

	Menu.setItems(self, self.items, #self.items, index, index)
end


--[[

=head2 jive.ui.Menu:updatedItem(item)

Notifies the menu with the item I<item> has changed. If neccessary this will cause the menu to be redrawn.

=cut
--]]
function updatedItem(self, item)
	local index = self:getIndex(item)
	if index ~= nil then
		self:updatedIndex(index)
	end
end


function __tostring(self)
	return "SimpleMenu()"
end


--[[

=head1 LICENSE

Copyright 2007 Logitech. All Rights Reserved.

This file is subject to the Logitech Public Source License Version 1.0. Please see the LICENCE file for details.

=cut
--]]


