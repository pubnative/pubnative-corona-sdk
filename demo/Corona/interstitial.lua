local composer = require( "composer" );
local widget = require( "widget" );
widget.setTheme( "widget_theme_android" );
local scene = composer.newScene()
composer.recycleOnSceneChange = true

-- Pubnative Interstitial Plugin
local interstitial = require( "plugin.pubnative.interstitial" )

-- Parameters for Pubnative Interstitial
local APP_TOKEN = "2c6fdfd723dd4a6ba52e8e6878138145";
local PLACEMENT = "mraid_large";

-- ------------------------------------------------------------------------------
-- Spinner
-- ------------------------------------------------------------------------------
-- Image sheet options and declaration
-- For testing, you may copy/save the image under "Single Frame Construction" above
local options = {
  width = 48,
  height = 48,
  numFrames = 1,
  sheetContentWidth = 48,
  sheetContentHeight = 48
}

local spinnerSingleSheet = graphics.newImageSheet( "spinner.png", options )

-- Create the widget
local spinner = widget.newSpinner(
  {
    width = 48,
    height = 48,
    sheet = spinnerSingleSheet,
    startFrame = 1,
    deltaAngle = 10,
    incrementEvery = 20
  }
)
spinner.isVisible = false;

-- -----------------------------------------------------------------------------
-- Listeners
-- -----------------------------------------------------------------------------
-- Pubnative SDK LoadListener
local function loadListener(event)
  spinner:stop();
  spinner.isVisible = false;
  if(event.isError) then
    native.showAlert(
      "Fail",
      "Ad loading failed! Error: " .. tostring( event.response ),
      { "OK" }
    )
  else
    native.showAlert(
      "Success",
      "Ad loaded!",
      { "OK" }
    )
  end
end

-- Pubnative SDK TrackListeners
local function impressionListener(event)
  -- Do something, if Impression tracked
--  native.showAlert(
--    "Insights",
--    "Impression tracked!",
--    { "OK" }
--  )
end

local function clickListener(event)
  -- Do something, if Click tracked
--  native.showAlert(
--    "Insights",
--    "Click tracked!",
--    { "OK" }
--  )
  interstitial.hide()
end

-- Pubnative SDK ViewListeners
local function showListener(event)
  -- Do something, if view shown
--  native.showAlert(
--    "View",
--    "View shown!",
--    { "OK" }
--  )
end

local function hideListener(event)
  -- Do something, if view hidden
--  native.showAlert(
--    "View",
--    "View hidden!",
--    { "OK" }
--  )
end

-- -----------------------------------------------------------------------------
-- UI Widgets
-- -----------------------------------------------------------------------------

local returnButton = widget.newButton
{
  label = "Return",
  onRelease = function(event)
    composer.gotoScene("menu")
  end,
}

returnButton.x = returnButton.contentWidth / 2;
returnButton.y = returnButton.contentHeight / 2;

local pubnativeLoadInterstitialButton = widget.newButton
{
  label = "Load Interstitial";
  onRelease = function(event)
    spinner.isVisible = true;
    spinner:start();
    -- --------------------------------------------------------------------------
    -- For loading pubnative Banner you should pass a three paramters into load()
    -- 1. App Token
    -- 2. Placement name
    -- 3. Listener for detecting Loading behavior from Pubnative SDK
    -- --------------------------------------------------------------------------
    interstitial.load(APP_TOKEN, PLACEMENT, loadListener);
  end,
}

pubnativeLoadInterstitialButton.x = display.contentCenterX;
pubnativeLoadInterstitialButton.y = 130;

local pubnativeShowInterstitialButton = widget.newButton
{
  label = "Show",
  onRelease = function( event )
    -- --------------------------------------------------------------------------
    -- For show pubnative Banner you should pass a four paramters into load()
    -- Set Impression Listener and Click Listener,
    -- if you want detect impressions and clicks for the ads and
    -- set Show and Hide listeners, if you want detect when Ad is shown or Hidden
    -- --------------------------------------------------------------------------
    interstitial.setImpressionListener(impressionListener)
    interstitial.setClickListener(clickListener)
    interstitial.setShowListener(showListener)
    interstitial.setHideListener(hideListener)
    interstitial.show()
  end,
}

pubnativeShowInterstitialButton.x = display.contentCenterX;
pubnativeShowInterstitialButton.y = pubnativeLoadInterstitialButton.y + pubnativeLoadInterstitialButton.contentHeight + pubnativeShowInterstitialButton.contentHeight * 0.5;

spinner.x = display.contentCenterX;
spinner.y = pubnativeShowInterstitialButton.y + pubnativeShowInterstitialButton.contentHeight + spinner.contentHeight * 0.5;

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
    sceneGroup:insert( pubnativeLoadInterstitialButton )
    sceneGroup:insert( pubnativeShowInterstitialButton )
    sceneGroup:insert( spinner )
    sceneGroup:insert( returnButton )
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
    sceneGroup:remove( pubnativeLoadInterstitialButton )
    sceneGroup:remove( pubnativeShowInterstitialButton )
    sceneGroup:remove( spinner )
    sceneGroup:remove( returnButton )
  end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------

return scene
