local composer = require( "composer" );
local scene = composer.newScene()
composer.recycleOnSceneChange = true

local widget = require( "widget" );
widget.setTheme( "widget_theme_android" );

local bannerButton = widget.newButton
{
	label = "Banner";
	onRelease = function(event)
		composer.gotoScene("banner");
	end,
}

local interstitialButton = widget.newButton
{
	label = "Interstitial";
	onRelease = function(event)
		composer.gotoScene("interstitial");
	end,
}

bannerButton.x = display.contentCenterX;
bannerButton.y = 130;

interstitialButton.x = display.contentCenterX;
interstitialButton.y = bannerButton.y + bannerButton.contentHeight + interstitialButton.contentHeight * 0.5;

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		sceneGroup:insert( bannerButton )
		sceneGroup:insert( interstitialButton )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------

return scene
