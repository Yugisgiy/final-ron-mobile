package;

import sys.io.File;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import haxe.io.Path;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#if android
import android.content.Context;
import android.os.Build;
#end
#if mobile
import mobile.CopyState;
#end
import lime.app.Application;
#if desktop
import important.Discord.DiscordClient;
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = menus.NoticeScreen; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
	}
	
    function onCrash(e:UncaughtErrorEvent):Void
    {
        var errMsg:String = "";

	for (stackItem in CallStack.exceptionStack(true)) {
		switch (stackItem) {
			case CFunction: errMsg += 'non-haxe (C) function\n';
			case Module(moduleName): errMsg += 'module ${moduleName}\n';
			case FilePos(s, file, line, column): errMsg += '${file}:${line}\n';
			case Method(className, method): errMsg += '${className} - method ${method}\n';
			case LocalFunction(name): errMsg += 'local function ${name}\n';
		}
	}

        errMsg += '\nwhoopsies. trojan virus detected: ${e.error.toLowerCase()}!\nu should probably send this to the vs ron discord server or soemthing\nhttps://discord.gg/Rg7XUXE4C';
        Sys.println(errMsg);

        Application.current.window.alert(errMsg, "um");
        #if desktop
	DiscordClient.shutdown();
	#end
        Sys.exit(1);
    }

	public function new()
	{
		super();

		#if mobile
		#if android
		mobile.StorageUtil.requestPermissions();
		#end
		Sys.setCwd(mobile.StorageUtil.getStorageDirectory());
		#end

		important.CrashHandler.init();
				
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var data = new haxe.Http("https://github.com/FNF-CNE-Devs/CodenameEngine/blob/main/buildnumber.txt");
		data.onData = function(d) trace(d);
	
		ClientPrefs.loadDefaultKeys();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));
		

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		#if !mobile
		addChild(fpsVar);
		#else
		FlxG.game.addChild(fpsVar);
		#end
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if mobile
		lime.system.System.allowScreenTimeout = ClientPrefs.screensaver;		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
		#end
	}

	public function getFPS():Float
	{
		return fpsVar.currentFPS;
	}
}
