package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.media.SoundChannel;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenuItem;
	import flash.utils.getDefinitionByName;
	import flash.display.StageQuality;
	
	import com.iggyzuk.components.Transition;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class GameController {
		
		public static var gameName:String = "LD23";
		
		public static var timeline:MovieClip;
		public static var stage:Stage;
		public static var transition:Transition;
		
		public static var mute:Boolean = false;
		
		public static var local:Boolean = true;
		public static var allowedSite:String = "";
		
		public static var soundChannelList:Array = [];
		public static var soundTransformList:Array = [];
		
		public static var musicChannel:SoundChannel;
		public static var musicTransform:SoundTransform;
		
		public static var musicVolume:Number = 0.55;
		
		public static var myContextMenu:ContextMenu;
		
		public static function setup(t:MovieClip, s:Stage, tr:Transition) {
			
			timeline = t;
			stage = s;
			transition = tr;
			
			soundChannelList.push(new SoundChannel); // SFX
			soundChannelList.push(new SoundChannel); // Voice
			soundChannelList.push(new SoundChannel); // Low SFX
			
			soundTransformList.push(new SoundTransform);
			soundTransformList.push(new SoundTransform);
			soundTransformList.push(new SoundTransform);
			
			musicChannel = new SoundChannel;
			musicTransform = new SoundTransform;
			
			setContextMenu(timeline);
			
			setSoundVolume(0.35, 0);
			setSoundVolume(1, 1);
			setSoundVolume(0.5, 2);
			
			setMusicVolume(musicVolume);
			setQuality(0);
		}
		
		//Context menu
		public static function setContextMenu(d:DisplayObjectContainer):void {
			
			myContextMenu = new ContextMenu();
			myContextMenu.hideBuiltInItems();
			
			var menuItem1:ContextMenuItem = new ContextMenuItem("Game by Ignatus Zuk");
			var menuItem2:ContextMenuItem = new ContextMenuItem("Greed Wars 30 © 2012",true,false);
			
			myContextMenu.customItems.push(menuItem1);
			
			menuItem1.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, gameDown);
			
			d.contextMenu = myContextMenu;
		}
		
		//Shared Object
		public static function getSharedObject(saveId:int = 1):SharedObject {
			var soName:String = "so_" + gameName + saveId;
			return SharedObject.getLocal(soName);
		}
		
		//Site Lock
		public static function isLocked():Boolean {
			if(local) return false;
			
			var siteLocked:Boolean = false;
			
			var domain:String = timeline.loaderInfo.url.split("/")[2];
			
			if (domain.indexOf(allowedSite) == (domain.length - allowedSite.length)) siteLocked = false;
			else if (domain.indexOf(allowedSite) != (domain.length - allowedSite.length)) siteLocked = true;
			
			if(siteLocked){
				//Add Site Locked Message
				var lockedBitmap:Bitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x000000));
				stage.addChild(lockedBitmap);
				
				var textFormat:TextFormat = new TextFormat();
				textFormat.font = "Verdana"
				textFormat.size = 17;
				textFormat.color = 0xFFFFFF;
				textFormat.align = TextFormatAlign.CENTER;
				textFormat.bold = true;
				
				var lockedText:TextField = new TextField();
				lockedText.defaultTextFormat = textFormat;
				lockedText.text = String("GAME LOCKED \n www."+allowedSite);
				lockedText.width = stage.stageWidth;
				lockedText.x = 0;
				lockedText.y = stage.stageHeight/2;
				lockedText.selectable = false;
				stage.addChild(lockedText);
				
				return true;
			}
			
			return false;
		}
		
		//Sounds / Music
		public static function playSound(soundName:String, channel:int = 0):void {
			if (mute) return;
			var soundRef:Class = getDefinitionByName(soundName) as Class;
			var s:Sound = new soundRef;
			var r:int = 0;
			soundChannelList[channel] = s.play(0, 0, soundTransformList[channel]);
		}
		
		public static function playMusic(musicName:String):void {
			musicChannel.stop();
			var musicRef:Class = getDefinitionByName(musicName) as Class;
			var m:Sound = new musicRef;
			musicChannel = m.play(0, int.MAX_VALUE, musicTransform);
		}
		
		public static function setSoundVolume(val:Number, channel:int = 0):void {
			soundTransformList[channel].volume = val;
			soundChannelList[channel].soundTransform = soundTransformList[channel];
		}
		
		public static function setMusicVolume(val:Number):void {
			musicTransform.volume = val;
			musicChannel.soundTransform = musicTransform;
		}
		
		public static function stopAllSounds():void {
			SoundMixer.stopAll();
			trace("STOP ALL SOUNDS!");
		}
		
		public static function gameDown(e:ContextMenuEvent):void {
			navigateToURL(new URLRequest("http://www.iggyzuk.com/"), "_blank");
		}
		
		public static function setQuality(q:int):void {
			if(q == 0) stage.quality = StageQuality.LOW;
			else if(q == 1) stage.quality = StageQuality.MEDIUM;
			else if(q == 2) stage.quality = StageQuality.HIGH;
		}
	}
}