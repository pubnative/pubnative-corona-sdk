
local composer = require( "composer" );
local widget = require( "widget" );
widget.setTheme( "widget_theme_android" );
local scene = composer.newScene()
composer.recycleOnSceneChange = true

-- Pubnative Banner Plugin
local banner = require( "plugin.pubnative.banner" )

-- Parameters for Pubnative Banner
local APP_TOKEN = "2c6fdfd723dd4a6ba52e8e6878138145";
local PLACEMENT = "iOS_asset_group_1";
local bannerPosition = 1;

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

-- ------------------------------------------------------------------------------
-- Listeners
-- ------------------------------------------------------------------------------
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
  native.showAlert(
    "Insights",
    "Impression tracked!",
    { "OK" }
  )
end

local function clickListener(event)
  -- Do something, if Click tracked
  -- For example, close the Ad
  -- pubnativeSdk.hide();
  native.showAlert(
    "Insights",
    "Click tracked!",
    { "OK" }
  )
end

-- ------------------------------------------------------------------------------
-- UI Widgets
-- ------------------------------------------------------------------------------

local returnButton = widget.newButton
{
  label = "Return",
  onRelease = function(event)
    composer.gotoScene("menu")
  end,
}

returnButton.x = returnButton.contentWidth / 2;
returnButton.y = returnButton.contentHeight / 2;

-- Handle press events for the checkbox
local function onSwitchPress( event )
  local switch = event.target
  print( "Switch with ID '"..switch.id.."' is on: "..tostring(switch.isOn) )
end

-- Create a group for the radio button set
local bannerPosition = display.newGroup();
local rect = display.newRect( 0, 0, 200, 80 );
rect:setFillColor( 0.5 );
bannerPosition:insert(rect);

-- Create two associated radio buttons (inserted into the same display group)
local bannerTop = widget.newSwitch(
  {
    x = -60,
    y = -20,
    label = "TOP",
    style = "radio",
    id = "RadioButton1",
    initialSwitchState = true,
    onPress = onSwitchPress
  }
)
local bannerTopText = display.newText( "TOP", - 30, - 20, native.systemFont, 16 );
bannerPosition:insert( bannerTop );
bannerPosition:insert( bannerTopText );

local bannerBottom = widget.newSwitch(
  {
    x = -60,
    y = 10,
    label = "BOTTOM",
    style = "radio",
    id = "RadioButton2",
    onPress = onSwitchPress
  }
)
local bannerBottomText = display.newText( "BOTTOM", - 10, 10, native.systemFont, 16 );
bannerPosition:insert( bannerBottom );
bannerPosition:insert( bannerBottomText );

local pubnativeLoadBannerButton = widget.newButton
{
  label = "Load Banner";
  onRelease = function(event)
    spinner.isVisible = true;
    spinner:start();
    -- --------------------------------------------------------------------------
    -- For loading pubnative Banner you should pass a three paramters into load()
    -- 1. App Token
    -- 2. Placement name
    -- 3. Listener for detecting Loading behavior from Pubnative SDK
    -- --------------------------------------------------------------------------
    banner.hide();
    banner.load(APP_TOKEN, PLACEMENT, loadListener);
  end,
}

pubnativeLoadBannerButton.x = display.contentCenterX;
pubnativeLoadBannerButton.y = 130;

local pubnativeShowBannerButton = widget.newButton
{
  label = "Show",
  onRelease = function( event )
    -- --------------------------------------------------------------------------
    -- For displaying banner on the screen, you should set
    -- Impression Listener and Click Listener,
    -- if you want detect impressions and clicks for the ads
    -- And then use show() method
    -- --------------------------------------------------------------------------
    if(bannerTop.isOn) then
      bannerPosition = 1;
    elseif(bannerBottom.isOn) then
      bannerPosition = 2;
    end
    banner.setImpressionListener(impressionListener)
    banner.setClickListener(clickListener)
    banner.show(bannerPosition)
  end,
}

pubnativeShowBannerButton.x = display.contentCenterX;
pubnativeShowBannerButton.y = pubnativeLoadBannerButton.y + pubnativeLoadBannerButton.contentHeight + pubnativeShowBannerButton.contentHeight * 0.5;

local pubnativeHideBannerButton = widget.newButton
{
  label = "Hide",
  onRelease = function( event )
    banner.hide()
  end,
}

pubnativeHideBannerButton.x = display.contentCenterX;
pubnativeHideBannerButton.y = pubnativeShowBannerButton.y + pubnativeShowBannerButton.contentHeight + pubnativeHideBannerButton.contentHeight * 0.5;

bannerPosition.x = display.contentCenterX;
bannerPosition.y = pubnativeHideBannerButton.y + pubnativeHideBannerButton.contentHeight + bannerPosition.contentHeight * 0.5;

spinner.x = display.contentCenterX;
spinner.y = bannerPosition.y + bannerPosition.contentHeight + spinner.contentHeight * 0.5;

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
    sceneGroup:insert( pubnativeLoadBannerButton )
    sceneGroup:insert( pubnativeShowBannerButton )
    sceneGroup:insert( pubnativeHideBannerButton )
    sceneGroup:insert( bannerPosition )
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
    sceneGroup:remove( pubnativeLoadBannerButton )
    sceneGroup:remove( pubnativeShowBannerButton )
    sceneGroup:remove( pubnativeHideBannerButton )
    sceneGroup:remove( bannerPosition )
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
