class MSMenu extends GFxMoviePlayer;

// Standard Flash Objects
var GFxObject 				MenuMC, MouseCursorMC, RollOverMC;

// CLIK Widgets
var GFxClikWidget 			MainMenuTF, OptionsMenuTF, ToolTipTF;
var GFxClikWidget			StartBtn, OptionsBtn, BackBtn,QuitBtn;

// All display text is localized and stored in the file 'ProjectS.int' in the /Localization/INT directory.
var localized string 		mainMenuTitle, optionsMenuTitle, startBtnLabel, optionsBtnLabel, backBtnLabel, startBtnTip, optionsBtnTip, backBtnTip,quitBtnLabel;

// Plays SWF, this is also were you would initialize objects and variables
function bool Start(optional bool StartPaused = false)
{	
    super.Start();
    Advance(0.f);
	
	// Cache a reference to the menu container.
	MenuMC = GetVariableObject("root.menu");
		
    return true;
}

// Callback when a CLIK widget with enableInitCallback set to TRUE is initialized.  Returns TRUE if the widget was handled, FALSE if not.
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{    
    switch (WidgetName) // WidgetName = instance name of a Flash object.
    {         
		case ('mainMenu_tf'):
			MainMenuTF = GFxClikWidget(Widget);
			MainMenuTF.SetString("text", mainMenuTitle);
			break;
		case ('optionsMenu_tf'):
			OptionsMenuTF = GFxClikWidget(Widget);
			OptionsMenuTF.SetString("text", optionsMenuTitle);
			break;
		case ('start_btn'):
			StartBtn = GFxClikWidget(Widget);
			StartBtn.SetFloat("focused", 1);
			SetUpButtonEvents(StartBtn, startBtnLabel);
			break;
		case ('options_btn'):
			OptionsBtn = GFxClikWidget(Widget);
			SetUpButtonEvents(OptionsBtn, optionsBtnLabel);
			break;
		case ('back_btn'):
			BackBtn = GFxClikWidget(Widget);
			BackBtn.SetFloat("focused", 1);
			SetUpButtonEvents(BackBtn, backBtnLabel);
			break;
		case ('mCursor'):
			MouseCursorMC = Widget;
			RollOverMC = MouseCursorMC.GetObject("rollOver_mc");
			break;
		case ('tooltip_tf'):
			ToolTipTF = GFxClikWidget(Widget);
			ToolTipTF.SetString("text", "");
			break;
		case ('quit_btn'):
			QuitBtn = GFxClikWidget(Widget);
			QuitBtn.SetFloat("focused", 1);
			SetUpButtonEvents(QuitBtn, quitBtnLabel);
			break;
        default:
            break;
    }
    return true;
}

// This function adds event listeners to the menu buttons, and sets the text displayed on the button.
function SetUpButtonEvents(GFxClikWidget button, string buttonLabel)
{
	button.AddEventListener('CLIK_buttonPress', handleBtnPress);
	button.AddEventListener('CLIK_rollOver', handleRollOver);
	button.AddEventListener('CLIK_rollOut', handleRollOut);

	button.SetString("label", buttonLabel);
}

// The next several functions are event handlers for CLIK UI widgets that tell the movie what to do when those events occur.
function handleBtnPress(GFxClikWidget.EventData ev)
{
	local GFxObject button;
	button = ev._this.GetObject("target");
	
	switch (button.GetString("name"))
	{
		case ("start_btn"):
			ConsoleCommand("open MetalStar_TEST.udk");
			Close(true);
			break;
		case ("options_btn"):
			MenuMC.GotoAndPlay("options");
			handleRollOut();
			break;
		case ("back_btn"):
			MenuMC.GotoAndPlay("main");
			handleRollOut();
			break;
		case ("quit_btn"):
			ConsoleCommand("Quit");
			break;
		default:
			break;
	}
}

function handleRollOver(GFxClikWidget.EventData ev)
{
	local GFxObject button;
	button = ev._this.GetObject("target");
	
	RollOverMC.GotoAndStop("on");
	
	switch (button.GetString("name"))
	{
		case ("start_btn"):
			ToolTipTF.SetString("text", startBtnTip);
			break;
		case ("options_btn"):
			ToolTipTF.SetString("text", optionsBtnTip);
			break;
		case ("back_btn"):
			ToolTipTF.SetString("text", backBtnTip);
			break;
		default:
			break;
	}
}

function handleRollOut(optional GFxClikWidget.EventData ev)
{
	if (ToolTipTF != none)
	{
		ToolTipTF.SetString("text","");
	}
	RollOverMC.GotoAndStop("off");
}

defaultproperties
{    
	WidgetBindings(0)={(WidgetName="mainMenu_tf",WidgetClass=class'GFxClikWidget')}
	WidgetBindings(1)={(WidgetName="optionsMenu_tf",WidgetClass=class'GFxClikWidget')}
	WidgetBindings(2)={(WidgetName="start_btn",WidgetClass=class'GFxClikWidget')}
	WidgetBindings(3)={(WidgetName="options_btn",WidgetClass=class'GFxClikWidget')}
	WidgetBindings(4)={(WidgetName="back_btn",WidgetClass=class'GFxClikWidget')}
	WidgetBindings(5)={(WidgetName="mCursor",WidgetClass=class'GFxClikWidget')}
	WidgetBindings(6)={(WidgetName="tooltip_tf",WidgetClass=class'GFxClikWidget')}
	WidgetBindings(7)={(WidgetName="quit_btn",WidgetClass=class'GFxClikWidget')}

	bDisplayWithHudOff=TRUE
	bCaptureInput=TRUE
	bIgnoreMouseInput=FALSE
}