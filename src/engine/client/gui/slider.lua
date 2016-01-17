--========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========--
--
-- Purpose: Slider class
--
--============================================================================--

class "slider" ( gui.scrollbar )

function slider:slider( parent, name )
	gui.scrollbar.scrollbar( self, parent, name )
	self.width    = 216
	self.height   = 46
	self.minLabel = "Min"
	self.maxLabel = "Max"
	self:setMax( 100 )
end

function slider:draw()
	self:drawTrough()
	self:drawLabels()
	self:drawThumb()

	gui.panel.draw( self )
end

function slider:drawLabels()
	local property = "slider.fontColor"

	if ( self:isDisabled() ) then
		property = "slider.disabled.fontColor"
	end

	graphics.setColor( self:getScheme( property ) )
	local font = self:getScheme( "fontSmall" )
	graphics.setFont( font )
	local minLabel = self:getMinLabel()
	local maxLabel = self:getMaxLabel()
	local height   = self:getHeight()
	local width    = self:getWidth()
	local x        = width - font:getWidth( maxLabel )
	graphics.print( minLabel, 0, height / 2 + 9 )
	graphics.print( maxLabel, x, height / 2 + 9 )
end

function slider:drawThumb()
	local property = "scrollbar.backgroundColor"
	local height   = self:getHeight()
	local y        = 0

	if ( self:isDisabled() ) then
		property = "scrollbar.disabled.backgroundColor"
	end

	graphics.setColor( self:getScheme( property ) )
	graphics.rectangle( "fill", self:getThumbPos(), y, 4, height / 2 )
end

function slider:drawTrough()
	local property = "slider.backgroundColor"
	local height   = self:getHeight()
	local width    = self:getWidth()

	if ( self:isDisabled() ) then
		property = "slider.disabled.backgroundColor"
	end

	graphics.setColor( self:getScheme( property ) )
	graphics.line( 0, height / 4, width, height / 4 )
end

function slider:getMinLabel()
	return self.minLabel
end

function slider:getMaxLabel()
	return self.maxLabel
end

function slider:getThumbLength()
	local range = self:getMax() - self:getMin()
	local size  = self:getRangeWindow() / range
	return size * ( self:getWidth() - 4 )
end

function slider:getThumbPos()
	local min     = self:getMin()
	local range   = self:getMax() - min
	local percent = ( self:getValue() + min ) / range
	return percent * ( self:getWidth() - 4 )
end

slider.invalidateLayout = gui.panel.invalidateLayout

function slider:setMinLabel( minLabel )
	self.minLabel = minLabel
	self:invalidate()
end

function slider:setMaxLabel( maxLabel )
	self.maxLabel = maxLabel
	self:invalidate()
end

local localX, localY = 0, 0

function slider:mousepressed( x, y, button, istouch )
	if ( self.mouseover and button == 1 ) then
		self.mousedown = true
	end

	if ( self.mousedown and button == 1 ) then
		localX, localY = self:screenToLocal( x, y )

		if ( localX < self:getThumbPos() ) then
			self:pageUp()
			return
		elseif ( localX > self:getThumbPos() + 4 ) then
			self:pageDown()
			return
		end

		self.grabbedX  = localX
		self.grabbedY  = localY
	end
end

local mouseX, mouseY   = 0, 0
local getMousePosition = input.getMousePosition
local deltaX, deltaY   = 0, 0

function slider:update( dt )
	gui.panel.update( self, dt )

	if ( not self:isVisible() or self:isDisabled() ) then
		return
	end

	if ( not ( self.grabbedX or self.grabbedY ) ) then
		return
	end

	mouseX, mouseY = getMousePosition()
	localX, localY = self:screenToLocal( mouseX, mouseY )
	deltaX, deltaY = localX - self.grabbedX,
	                 localY - self.grabbedY

	if ( deltaX == 0 and deltaY == 0 ) then
		return
	end

	minRange, maxRange = self:getRange()
	range              = maxRange - minRange
	deltaValue         = ( deltaX / self:getWidth() ) * range
	deltaValue         = self:setValue( self:getValue() + deltaValue )
	self.grabbedX      = localX + ( deltaValue / range ) * self:getWidth()
	self.grabbedY      = localY
end

gui.register( slider, "slider" )
