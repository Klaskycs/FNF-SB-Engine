package options;

import flixel.addons.display.shapes.FlxShapeCircle;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxPoint;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.transition.FlxTransitionableState;
import lime.system.Clipboard;
import flixel.util.FlxGradient;

class NotesSubState extends MusicBeatSubstate
{
	var onModeColumn:Bool = true;
	var currentlySelectedMode:Int = 0;
	var currentlySelectedNote:Int = 0;
	var onPixel:Bool = false;
	var dataArray:Array<Array<FlxColor>>;

	var hexTypeLine:FlxSprite;
	var hexTypeNum:Int = -1;
	var hexTypeVisibleTimer:Float = 0;

	var copyButton:FlxSprite;
	var pasteButton:FlxSprite;

	var colorGradient:FlxSprite;
	var colorGradientSelector:FlxSprite;
	var colorPalette:FlxSprite;
	var colorWheel:FlxSprite;
	var colorWheelSelector:FlxSprite;

	var alphabetR:Alphabet;
	var alphabetG:Alphabet;
	var alphabetB:Alphabet;
	var alphabetHex:Alphabet;

	var bg:FlxSprite;
	var grid:FlxBackdrop;

	var modeBG:FlxSprite;
	var notesBG:FlxSprite;

	// controller support
	var controllerPointer:FlxSprite;
	var _lastControllerMode:Bool = false;
	var tipTxt:FlxText;
	
	var easyColorMethodBox:FlxUIInputText;
    var checkTheLenght:String = '';
    var checkTheColor:String = '';
	public function new() {
		super();

		if (options.OptionsState.onPlayState) 
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu - Paused (In Note Color Menu)"; 
		else 
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu (In Note Color Menu)";
		FlxTween.tween(FlxG.sound.music, {volume: 0.4}, 0.8);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		switch (ClientPrefs.data.themes) {
			case 'SB Engine':
				bg.color = FlxColor.BROWN;
			
			case 'Psych Engine':
				bg.color = 0xFFea71fd;
		}
		bg.scrollFactor.set();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.updateHitbox();
		add(bg);

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x70000000, 0x0));
		grid.velocity.set(FlxG.random.bool(50) ? 90 : -90, FlxG.random.bool(50) ? 90 : -90);
		grid.visible = ClientPrefs.data.velocityBackground;
		grid.antialiasing = ClientPrefs.data.antialiasing;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		modeBG = FlxSpriteUtil.drawRoundRect(new FlxSprite(215, 85).makeGraphic(315, 115, FlxColor.TRANSPARENT), 0, 0, 315, 115, 65, 65, FlxColor.BLACK);
		modeBG.visible = false;
		modeBG.alpha = 0.4;
		add(modeBG);

		notesBG = FlxSpriteUtil.drawRoundRect(new FlxSprite(120, 190).makeGraphic(510, 125, FlxColor.TRANSPARENT), 0, 0, 510, 125, 65, 65, FlxColor.BLACK);
		notesBG.visible = false;
		notesBG.alpha = 0.4;
		add(notesBG);

		modeNotes = new FlxTypedGroup<FlxSprite>();
		add(modeNotes);

		myNotes = new FlxTypedGroup<StrumNote>();
		add(myNotes);

		var bg:FlxSprite = new FlxSprite(720).makeGraphic(FlxG.width - 720, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.25;
		add(bg);
		var bg:FlxSprite = new FlxSprite(750, 160).makeGraphic(FlxG.width - 780, 540, FlxColor.BLACK);
		bg.alpha = 0.25;
		add(bg);
		
		var text:Alphabet = new Alphabet(50, 86, 'CTRL', false);
		#if android text.set_text('TAP'); #end
		text.alignment = CENTERED;
		text.setScale(0.4);
		add(text);

		copyButton = new FlxSprite(760, 50).loadGraphic(Paths.image('noteColorMenu/copy'));
		copyButton.alpha = 0.6;
		add(copyButton);

		pasteButton = new FlxSprite(1180, 50).loadGraphic(Paths.image('noteColorMenu/paste'));
		pasteButton.alpha = 0.6;
		add(pasteButton);

		colorGradient = FlxGradient.createGradientFlxSprite(60, 360, [FlxColor.WHITE, FlxColor.BLACK]);
		colorGradient.setPosition(780, 200);
		add(colorGradient);

		colorGradientSelector = new FlxSprite(770, 200).makeGraphic(80, 10, FlxColor.WHITE);
		colorGradientSelector.offset.y = 5;
		add(colorGradientSelector);

		colorPalette = new FlxSprite(820, 580).loadGraphic(Paths.image('noteColorMenu/palette', false));
		colorPalette.scale.set(20, 20);
		colorPalette.updateHitbox();
		colorPalette.antialiasing = false;
		add(colorPalette);
		
		colorWheel = new FlxSprite(860, 200).loadGraphic(Paths.image('noteColorMenu/colorWheel'));
		colorWheel.setGraphicSize(360, 360);
		colorWheel.updateHitbox();
		add(colorWheel);

		colorWheelSelector = new FlxShapeCircle(0, 0, 8, {thickness: 0}, FlxColor.WHITE);
		colorWheelSelector.offset.set(8, 8);
		colorWheelSelector.alpha = 0.6;
		add(colorWheelSelector);

		var txtX = 980;
		var txtY = 90 + 20;
		alphabetR = makeColorAlphabet(txtX - 100, txtY);
		add(alphabetR);
		alphabetG = makeColorAlphabet(txtX, txtY);
		add(alphabetG);
		alphabetB = makeColorAlphabet(txtX + 100, txtY);
		add(alphabetB);
		alphabetHex = makeColorAlphabet(txtX, txtY - 40);
		add(alphabetHex);
		hexTypeLine = new FlxSprite(0, txtY - 40).makeGraphic(5, 62, FlxColor.WHITE);
		hexTypeLine.visible = false;
		add(hexTypeLine);

		spawnNotes();
		updateNotes(true);
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);

		var tipX = 20;
		var tipY = 660;
		var tip:FlxText = new FlxText(tipX, tipY, 0, "Press RELOAD to Reset the selected Note Part.", 16);
		#if android
			// tipX = 200; Doesn't change the position on Android for some reason
			tip.x = 200;
			tip.text ="Tap on C button to Reset the selected Note Part"; 
		#end
		switch (ClientPrefs.data.gameStyle) {
			case 'SB Engine': tip.setFormat(Paths.font("bahnschrift.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 'Psych Engine' | 'Kade Engine' | 'Cheeky': tip.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 'Dave and Bambi': tip.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 'TGT Engine': tip.setFormat(Paths.font("calibri.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		tip.borderSize = 2;
		add(tip);

		tipTxt = new FlxText(tipX, tipY + 24, 0, '', 16);
		#if android	tipX = 200;	#end
		switch (ClientPrefs.data.gameStyle) {
			case 'SB Engine': tipTxt.setFormat(Paths.font("bahnschrift.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 'Psych Engine' | 'Kade Engine' | 'Cheeky': tipTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 'Dave and Bambi': tipTxt.setFormat(Paths.font("comic.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			case 'TGT Engine': tipTxt.setFormat(Paths.font("calibri.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		tipTxt.borderSize = 2;
		add(tipTxt);
		updateTip();

		controllerPointer = new FlxShapeCircle(0, 0, 20, {thickness: 0}, FlxColor.WHITE);
		controllerPointer.offset.set(20, 20);
		controllerPointer.screenCenter();
		controllerPointer.alpha = 0.6;
		add(controllerPointer);
		
		FlxG.mouse.visible = !controls.controllerMode;
		controllerPointer.visible = controls.controllerMode;
		_lastControllerMode = controls.controllerMode;
		
		easyColorMethodBox = new FlxUIInputText(940, 20, 160, '', 30);
		easyColorMethodBox.focusGained = () -> FlxG.stage.window.textInputEnabled = true;
		checkTheLenght = easyColorMethodBox.text;
		add(easyColorMethodBox);

		#if android
		addVirtualPad(FULL, NOTESCOLORMENU);
		#end
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function updateTip()
	{
		#if !android
		tipTxt.text = 'Hold ' + (!controls.controllerMode ? 'Shift' : 'Left Shoulder Button') + ' + Press RELOAD to fully reset the selected Note.';
		#else
		tipTxt.text = "Tap on E button to fully reset the selected Note.";
		#end
	}

	var _storedColor:FlxColor;
	var changingNote:Bool = false;
	var holdingOnObj:FlxSprite;
	var allowedTypeKeys:Map<FlxKey, String> = [
		ZERO => '0', ONE => '1', TWO => '2', THREE => '3', FOUR => '4', FIVE => '5', SIX => '6', SEVEN => '7', EIGHT => '8', NINE => '9',
		NUMPADZERO => '0', NUMPADONE => '1', NUMPADTWO => '2', NUMPADTHREE => '3', NUMPADFOUR => '4', NUMPADFIVE => '5', NUMPADSIX => '6',
		NUMPADSEVEN => '7', NUMPADEIGHT => '8', NUMPADNINE => '9', A => 'A', B => 'B', C => 'C', D => 'D', E => 'E', F => 'F'];

	override function update(elapsed:Float) {
	
	checkTheLenght = easyColorMethodBox.text;
	
		if (FlxG.keys.justPressed.ESCAPE #if android || MusicBeatSubstate.virtualPad.buttonB.justPressed #end ) {
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			#if android
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
			#else
			close();
			#end
			Application.current.window.title = "Friday Night Funkin': SB Engine v" + MainMenuState.sbEngineVersion + " - Options Menu";
		}

		super.update(elapsed);

		// Early controller checking
		if(FlxG.gamepads.anyJustPressed(ANY)) controls.controllerMode = true;
		else if(FlxG.mouse.justPressed || FlxG.mouse.deltaScreenX != 0 || FlxG.mouse.deltaScreenY != 0) controls.controllerMode = false;
		//
		
		var changedToController:Bool = false;
		if(controls.controllerMode != _lastControllerMode)
		{
			//TraceText.makeTheTraceText('changed controller mode');
			FlxG.mouse.visible = !controls.controllerMode;
			controllerPointer.visible = controls.controllerMode;

			// changed to controller mid state
			if(controls.controllerMode)
			{
				controllerPointer.x = FlxG.mouse.x;
				controllerPointer.y = FlxG.mouse.y;
				changedToController = true;
			}
			// changed to keyboard mid state
			/*else
			{
				FlxG.mouse.x = controllerPointer.x;
				FlxG.mouse.y = controllerPointer.y;
			}
			// apparently theres no easy way to change mouse position that i know, oh well
			*/
			_lastControllerMode = controls.controllerMode;
			updateTip();
		}

		// controller things
		var analogX:Float = 0;
		var analogY:Float = 0;
		var analogMoved:Bool = false;
		if(controls.controllerMode && (changedToController || FlxG.gamepads.anyInput()))
		{
			for (gamepad in FlxG.gamepads.getActiveGamepads())
			{
				analogX = gamepad.getXAxis(LEFT_ANALOG_STICK);
				analogY = gamepad.getYAxis(LEFT_ANALOG_STICK);
				analogMoved = (analogX != 0 || analogY != 0);
				if(analogMoved) break;
			}
			controllerPointer.x = Math.max(0, Math.min(FlxG.width, controllerPointer.x + analogX * 1000 * elapsed));
			controllerPointer.y = Math.max(0, Math.min(FlxG.height, controllerPointer.y + analogY * 1000 * elapsed));
		}
		var controllerPressed:Bool = (controls.controllerMode && controls.ACCEPT);
		//

		if(FlxG.keys.justPressed.CONTROL)
		{
			onPixel = !onPixel;
			spawnNotes();
			updateNotes(true);
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		}
		
		if(checkTheLenght.length == 6 && checkTheColor != checkTheLenght)
			{
			    checkTheColor = checkTheLenght;
			
				var curColor:String = alphabetHex.text;
				var newColor:String = easyColorMethodBox.text /*curColor.substring(0, hexTypeNum) + allowedTypeKeys.get(keyPressed) + curColor.substring(hexTypeNum + 1)*/ ;

				var colorHex:FlxColor = FlxColor.fromString('#' + newColor);
				setShaderColor(colorHex);
				_storedColor = getShaderColor();
				updateColors();
				
				// move you to next letter
				//hexTypeNum++;
				//changed = true;
			}

		if(hexTypeNum > -1)
		{
			var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
			hexTypeVisibleTimer += elapsed;
			var changed:Bool = false;
			if(changed = FlxG.keys.justPressed.LEFT)
				hexTypeNum--;
			else if(changed = FlxG.keys.justPressed.RIGHT)
				hexTypeNum++;
			else if(FlxG.keys.justPressed.ENTER)
				hexTypeNum = -1;	
			else if(checkTheLenght.length == 6)
			{
			    checkTheColor = checkTheLenght;
			
				var curColor:String = alphabetHex.text;
				var newColor:String = easyColorMethodBox.text /*curColor.substring(0, hexTypeNum) + allowedTypeKeys.get(keyPressed) + curColor.substring(hexTypeNum + 1)*/ ;

				var colorHex:FlxColor = FlxColor.fromString('#' + newColor);
				setShaderColor(colorHex);
				_storedColor = getShaderColor();
				updateColors();
				
				// move you to next letter
				//hexTypeNum++;
				//changed = true;
			}
			
			
			var end:Bool = false;
			if(changed)
			{
				if (hexTypeNum > 5) //Typed last letter
				{
					hexTypeNum = -1;
					end = true;
					hexTypeLine.visible = false;
				}
				else
				{
					if(hexTypeNum < 0) hexTypeNum = 0;
					else if(hexTypeNum > 5) hexTypeNum = 5;
					centerHexTypeLine();
					hexTypeLine.visible = false;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			if(!end) hexTypeLine.visible = false;
		}
		else
		{
			var add:Int = 0;
			if(analogX == 0 && !changedToController)
			{
				if(controls.UI_LEFT_P) add = -1;
				else if(controls.UI_RIGHT_P) add = 1;
			}

			if(analogY == 0 && !changedToController && (controls.UI_UP_P || controls.UI_DOWN_P))
			{
				onModeColumn = !onModeColumn;
				modeBG.visible = onModeColumn;
				notesBG.visible = !onModeColumn;
			}
	
			if(add != 0)
			{
				if(onModeColumn) changeSelectionMode(add);
				else changeSelectionNote(add);
			}
			hexTypeLine.visible = false;
		}

		// Copy/Paste buttons
		var generalMoved:Bool = (FlxG.mouse.justMoved || analogMoved);
		var generalPressed:Bool = (FlxG.mouse.justPressed || controllerPressed);
		if(generalMoved)
		{
			copyButton.alpha = 0.6;
			pasteButton.alpha = 0.6;
		}

		if(pointerOverlaps(copyButton))
		{
			copyButton.alpha = 1;
			if(generalPressed)
			{
				Clipboard.text = getShaderColor().toHexString(false, false);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				TraceText.makeTheTraceText('copied: ' + Clipboard.text);
			}
			hexTypeNum = -1;
		}
		else if (pointerOverlaps(pasteButton))
		{
			pasteButton.alpha = 1;
			if(generalPressed)
			{
				var formattedText = Clipboard.text.trim().toUpperCase().replace('#', '').replace('0x', '');
				var newColor:Null<FlxColor> = FlxColor.fromString('#' + formattedText);
				//TraceText.makeTheTraceText('#${Clipboard.text.trim().toUpperCase()}');
				if(newColor != null && formattedText.length == 6)
				{
					setShaderColor(newColor);
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					_storedColor = getShaderColor();
					updateColors();
				}
				else //errored
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
			}
			hexTypeNum = -1;
		}

		// Click
		if(generalPressed)
		{
			hexTypeNum = -1;
			if (pointerOverlaps(modeNotes))
			{
				modeNotes.forEachAlive(function(note:FlxSprite) {
					if (currentlySelectedMode != note.ID && pointerOverlaps(note))
					{
						modeBG.visible = notesBG.visible = false;
						currentlySelectedMode = note.ID;
						onModeColumn = true;
						updateNotes();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					}
				});
			}
			else if (pointerOverlaps(myNotes))
			{
				myNotes.forEachAlive(function(note:StrumNote) {
					if (currentlySelectedNote != note.ID && pointerOverlaps(note))
					{
						modeBG.visible = notesBG.visible = false;
						currentlySelectedNote = note.ID;
						onModeColumn = false;
						bigNote.rgbShader.parent = Note.globalRgbShaders[note.ID];
						bigNote.shader = Note.globalRgbShaders[note.ID].shader;
						updateNotes();
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					}
				});
			}
			else if (pointerOverlaps(colorWheel)) {
				_storedColor = getShaderColor();
				holdingOnObj = colorWheel;
			}
			else if (pointerOverlaps(colorGradient)) {
				_storedColor = getShaderColor();
				holdingOnObj = colorGradient;
			}
			else if (pointerOverlaps(colorPalette)) {
				setShaderColor(colorPalette.pixels.getPixel32(
					Std.int((pointerX() - colorPalette.x) / colorPalette.scale.x), 
					Std.int((pointerY() - colorPalette.y) / colorPalette.scale.y)));
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				updateColors();
			}
			else if (pointerOverlaps(skinNote))
			{
				onPixel = !onPixel;
				spawnNotes();
				updateNotes(true);
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			else if(pointerY() >= hexTypeLine.y && pointerY() < hexTypeLine.y + hexTypeLine.height &&
					Math.abs(pointerX() - 1000) <= 84)
			{
			    //FlxG.stage.window.textInputEnabled = true;
				hexTypeNum = 0;
				for (letter in alphabetHex.letters)
				{
					if(letter.x - letter.offset.x + letter.width <= pointerX()) hexTypeNum++;
					else break;
				}
				if(hexTypeNum > 5) hexTypeNum = 5;
				hexTypeLine.visible = false;
				centerHexTypeLine();
			}
			else holdingOnObj = null;
		}
		// holding
		if(holdingOnObj != null)
		{
			if (FlxG.mouse.justReleased || (controls.controllerMode && controls.justReleased('accept')))
			{
				holdingOnObj = null;
				_storedColor = getShaderColor();
				updateColors();
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
			else if (generalMoved || generalPressed)
			{
				if (holdingOnObj == colorGradient)
				{
					var newBrightness = 1 - FlxMath.bound((pointerY() - colorGradient.y) / colorGradient.height, 0, 1);
					_storedColor.alpha = 1;
					if(_storedColor.brightness == 0) //prevent bug
						setShaderColor(FlxColor.fromRGBFloat(newBrightness, newBrightness, newBrightness));
					else
						setShaderColor(FlxColor.fromHSB(_storedColor.hue, _storedColor.saturation, newBrightness));
					updateColors(_storedColor);
				}
				else if (holdingOnObj == colorWheel)
				{
					var center:FlxPoint = new FlxPoint(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height/2);
					var mouse:FlxPoint = pointerFlxPoint();
					var hue:Float = FlxMath.wrap(FlxMath.wrap(Std.int(mouse.degreesTo(center)), 0, 360) - 90, 0, 360);
					var sat:Float = FlxMath.bound(mouse.dist(center) / colorWheel.width*2, 0, 1);
					//TraceText.makeTheTraceText('$hue, $sat');
					if(sat != 0) setShaderColor(FlxColor.fromHSB(hue, sat, _storedColor.brightness));
					else setShaderColor(FlxColor.fromRGBFloat(_storedColor.brightness, _storedColor.brightness, _storedColor.brightness));
					updateColors();
				}
			} 
		}
		else if(controls.RESET #if android || MusicBeatSubstate.virtualPad.buttonC.justPressed || MusicBeatSubstate.virtualPad.buttonE.justPressed #end && hexTypeNum < 0)
		{
			if(FlxG.keys.pressed.SHIFT || FlxG.gamepads.anyJustPressed(LEFT_SHOULDER) #if android || MusicBeatSubstate.virtualPad.buttonE.justPressed #end)
			{
				for (i in 0...3)
				{
					var strumRGB:RGBShaderReference = myNotes.members[currentlySelectedNote].rgbShader;
					var color:FlxColor = !onPixel ? ClientPrefs.defaultData.arrowRGB[currentlySelectedNote][i] :
													ClientPrefs.defaultData.arrowRGBPixel[currentlySelectedNote][i];
					switch(i)
					{
						case 0:
							getShader().r = strumRGB.r = color;
						case 1:
							getShader().g = strumRGB.g = color;
						case 2:
							getShader().b = strumRGB.b = color;
					}
					dataArray[currentlySelectedNote][i] = color;
				}
			}
			setShaderColor(!onPixel ? ClientPrefs.defaultData.arrowRGB[currentlySelectedNote][currentlySelectedMode] : ClientPrefs.defaultData.arrowRGBPixel[currentlySelectedNote][currentlySelectedMode]);
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.6);
			updateColors();
		}
	}

	function pointerOverlaps(obj:Dynamic)
	{
		if (!controls.controllerMode) return FlxG.mouse.overlaps(obj);
		return FlxG.overlap(controllerPointer, obj);
	}

	function pointerX():Float
	{
		if (!controls.controllerMode) return FlxG.mouse.x;
		return controllerPointer.x;
	}
	function pointerY():Float
	{
		if (!controls.controllerMode) return FlxG.mouse.y;
		return controllerPointer.y;
	}
	function pointerFlxPoint():FlxPoint
	{
		if (!controls.controllerMode) return FlxG.mouse.getScreenPosition();
		return controllerPointer.getScreenPosition();
	}

	function centerHexTypeLine()
	{
		//TraceText.makeTheTraceText(hexTypeNum);
		if(hexTypeNum > 0)
		{
			var letter = alphabetHex.letters[hexTypeNum-1];
			hexTypeLine.x = letter.x - letter.offset.x + letter.width;
		}
		else
		{
			var letter = alphabetHex.letters[0];
			hexTypeLine.x = letter.x - letter.offset.x;
		}
		hexTypeLine.x += hexTypeLine.width;
		hexTypeVisibleTimer = 0;
	}

	function changeSelectionMode(change:Int = 0) {
		currentlySelectedMode += change;
		if (currentlySelectedMode < 0)
			currentlySelectedMode = 2;
		if (currentlySelectedMode >= 3)
			currentlySelectedMode = 0;

		modeBG.visible = true;
		notesBG.visible = false;
		updateNotes();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	function changeSelectionNote(change:Int = 0) {
		currentlySelectedNote += change;
		if (currentlySelectedNote < 0)
			currentlySelectedNote = dataArray.length-1;
		if (currentlySelectedNote >= dataArray.length)
			currentlySelectedNote = 0;
		
		modeBG.visible = false;
		notesBG.visible = true;
		bigNote.rgbShader.parent = Note.globalRgbShaders[currentlySelectedNote];
		bigNote.shader = Note.globalRgbShaders[currentlySelectedNote].shader;
		updateNotes();
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	// alphabets
	function makeColorAlphabet(x:Float = 0, y:Float = 0):Alphabet
	{
		var text:Alphabet = new Alphabet(x, y, '', true);
		text.alignment = CENTERED;
		text.setScale(0.6);
		add(text);
		return text;
	}

	// notes sprites functions
	var skinNote:FlxSprite;
	var modeNotes:FlxTypedGroup<FlxSprite>;
	var myNotes:FlxTypedGroup<StrumNote>;
	var bigNote:Note;
	public function spawnNotes()
	{
		dataArray = !onPixel ? ClientPrefs.data.arrowRGB : ClientPrefs.data.arrowRGBPixel;
		if (onPixel) PlayState.stageUI = "pixel";

		// clear groups
		modeNotes.forEachAlive(function(note:FlxSprite) {
			note.kill();
			note.destroy();
		});
		myNotes.forEachAlive(function(note:StrumNote) {
			note.kill();
			note.destroy();
		});
		modeNotes.clear();
		myNotes.clear();

		if(skinNote != null)
		{
			remove(skinNote);
			skinNote.destroy();
		}
		if(bigNote != null)
		{
			remove(bigNote);
			bigNote.destroy();
		}

		// respawn stuff
		var res:Int = onPixel ? 160 : 17;
		skinNote = new FlxSprite(48, 24).loadGraphic(Paths.image('noteColorMenu/' + (onPixel ? 'note' : 'notePixel')), true, res, res);
		skinNote.antialiasing = ClientPrefs.data.antialiasing;
		skinNote.setGraphicSize(68);
		skinNote.updateHitbox();
		skinNote.animation.add('anim', [0], 24, true);
		skinNote.animation.play('anim', true);
		if(!onPixel) skinNote.antialiasing = false;
		add(skinNote);

		var res:Int = !onPixel ? 160 : 17;
		for (i in 0...3)
		{
			var newNote:FlxSprite = new FlxSprite(230 + (100 * i), 100).loadGraphic(Paths.image('noteColorMenu/' + (!onPixel ? 'note' : 'notePixel')), true, res, res);
			newNote.antialiasing = ClientPrefs.data.antialiasing;
			newNote.setGraphicSize(85);
			newNote.updateHitbox();
			newNote.animation.add('anim', [i], 24, true);
			newNote.animation.play('anim', true);
			newNote.ID = i;
			if(onPixel) newNote.antialiasing = false;
			modeNotes.add(newNote);
		}

		Note.globalRgbShaders = [];
		for (i in 0...dataArray.length)
		{
			Note.initializeGlobalRGBShader(i);
			var newNote:StrumNote = new StrumNote(150 + (480 / dataArray.length * i), 200, i, 0);
			newNote.useRGBShader = true;
			newNote.setGraphicSize(102);
			newNote.updateHitbox();
			newNote.ID = i;
			myNotes.add(newNote);
		}

		bigNote = new Note(0, 0, false, true);
		bigNote.setPosition(250, 325);
		bigNote.setGraphicSize(250);
		bigNote.updateHitbox();
		bigNote.rgbShader.parent = Note.globalRgbShaders[currentlySelectedNote];
		bigNote.shader = Note.globalRgbShaders[currentlySelectedNote].shader;
		for (i in 0...Note.colArray.length)
		{
			if(!onPixel) bigNote.animation.addByPrefix('note$i', Note.colArray[i] + '0', 24, true);
			else bigNote.animation.add('note$i', [i + 4], 24, true);
		}
		insert(members.indexOf(myNotes) + 1, bigNote);
		_storedColor = getShaderColor();
		PlayState.stageUI = "normal";
	}

	function updateNotes(?instant:Bool = false)
	{
		for (note in modeNotes)
			note.alpha = (currentlySelectedMode == note.ID) ? 1 : 0.6;

		for (note in myNotes)
		{
			var newAnim:String = currentlySelectedNote == note.ID ? 'confirm' : 'pressed';
			note.alpha = (currentlySelectedNote == note.ID) ? 1 : 0.6;
			if(note.animation.curAnim == null || note.animation.curAnim.name != newAnim) note.playAnim(newAnim, true);
			if (!instant) continue;
			if(instant) note.animation.curAnim.finish();
		}
		bigNote.animation.play('note$currentlySelectedNote', true);
		updateColors();
	}

	function updateColors(specific:Null<FlxColor> = null)
	{
		var color:FlxColor = getShaderColor();
		var wheelColor:FlxColor = specific == null ? getShaderColor() : specific;
		alphabetR.text = Std.string(color.red);
		alphabetG.text = Std.string(color.green);
		alphabetB.text = Std.string(color.blue);
		alphabetHex.text = color.toHexString(false, false);

		for (letter in alphabetHex.letters) letter.color = color;

		colorWheel.color = FlxColor.fromHSB(0, 0, color.brightness);
		colorWheelSelector.setPosition(colorWheel.x + colorWheel.width/2, colorWheel.y + colorWheel.height/2);
		if(wheelColor.brightness != 0)
		{
			var hueWrap:Float = wheelColor.hue * Math.PI / 180;
			colorWheelSelector.x += Math.sin(hueWrap) * colorWheel.width/2 * wheelColor.saturation;
			colorWheelSelector.y -= Math.cos(hueWrap) * colorWheel.height/2 * wheelColor.saturation;
		}
		colorGradientSelector.y = colorGradient.y + colorGradient.height * (1 - color.brightness);

		var strumRGB:RGBShaderReference = myNotes.members[currentlySelectedNote].rgbShader;
		switch(currentlySelectedMode)
		{
			case 0:
				getShader().r = strumRGB.r = color;
			case 1:
				getShader().g = strumRGB.g = color;
			case 2:
				getShader().b = strumRGB.b = color;
		}
	}

	function setShaderColor(value:FlxColor) dataArray[currentlySelectedNote][currentlySelectedMode] = value;
	function getShaderColor() return dataArray[currentlySelectedNote][currentlySelectedMode];
	function getShader() return Note.globalRgbShaders[currentlySelectedNote];
}
