/* This is the HUD wrapper. Its job is to instantiate the HUD and to tell it to update after each frame is rendered. */

class MSHudWrapper extends UTHUDBase;

/** Movie */
var MSHud   			HudMovie;
var Vector2D			HudMovieSize;
var bool cursorStatus;
var GFxUI_PauseMenu		PauseMenuMovie;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	CreateHUDMovie();
}


function CreateHUDMovie()
{
	local float x0, y0, x1, y1;
	
	HudMovie = new class'MSHud';

	HudMovie.SetTimingMode(TM_Real);
	HudMovie.Init(class'Engine'.static.GetEngine().GamePlayers[HudMovie.LocalPlayerOwnerIndex]);
	
	/* Using SM_NoScale, the Flash movie will not be scaled larger or smaller, regardless of the game's resolution. */
	/* Using SM_NoBorder, the Flash movie is scaled but with some varying levels of fail with the GetVisibleFrameRect() below*/
	HudMovie.SetViewScaleMode(SM_NoBorder);
	HudMovie.SetAlignment(Align_TopLeft);
	
	/* GetVisibleFrameRect(x1, y0, x1, y1) will allow us to determine the current viewport size. */
	HudMovie.GetVisibleFrameRect(x0, y0, x1, y1);
	HudMovieSize.X = x1-x0;
	HudMovieSize.Y = y1-y0;
}
exec function ShowMenu()
{
	// if using GFx HUD, use GFx pause menu
	TogglePauseMenu();
}
exec function ToggleMouseCursor(bool showCursor)
{
	cursorStatus = HudMovie.ToggleMouseCursor(showCursor);
}

function TogglePauseMenu()
{
    if ( PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen )
	{
		
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.PlayCloseAnimation();
		}
		else
		{
			// On mobile previewer, close right away
			CompletePauseMenuClose();
		}
	}
	else
    {
		CloseOtherMenus();

        PlayerOwner.SetPause(True);

        if (PauseMenuMovie == None)
        {
	        PauseMenuMovie = new class'GFxUI_PauseMenu';
            PauseMenuMovie.MovieInfo = SwfMovie'MSUI.MSPauseMenu';
            PauseMenuMovie.bEnableGammaCorrection = FALSE;
			PauseMenuMovie.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerOwner.Player));
            PauseMenuMovie.SetTimingMode(TM_Real);
        }

		SetVisible(false);
        PauseMenuMovie.Start();
        PauseMenuMovie.PlayOpenAnimation();

		// Do not prevent 'escape' to unpause if running in mobile previewer
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.AddFocusIgnoreKey('Escape');
		}
    }
}
function CompletePauseMenuClose()
{
    PlayerOwner.SetPause(False);
    PauseMenuMovie.Close(false);  // Keep the Pause Menu loaded in memory for reuse.
    SetVisible(true);
}
/* 
* Events 
*/

event PostRender()
{	
	super.PostRender();

	if (HudMovie != none)
	{
			
			HudMovie.TickHud(0);				

	}
	
}



defaultproperties
{
}
