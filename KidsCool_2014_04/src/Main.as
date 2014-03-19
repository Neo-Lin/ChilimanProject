package  {

	import citrus.core.CitrusEngine;
	import citrus.sounds.CitrusSoundGroup;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	//import soundpatchdemo.DemoState;
	//import soundpatchdemo.WebsiteFrame;
	

	
	[SWF(backgroundColor="#000000", frameRate="40", width="800", height="600")]

	public class Main extends CitrusEngine {

		public function Main() {
			// Create audio assets
			sound.addSound("Beep", {sound:"sounds/beep1.mp3",group:CitrusSoundGroup.SFX}); //吃到禮物
			sound.addSound("Fail", {sound:"sounds/fail.mp3", group:CitrusSoundGroup.SFX}); //失敗
			sound.addSound("Win", {sound:"sounds/win.mp3", group:CitrusSoundGroup.SFX});	//過關
			sound.addSound("Miss", {sound:"sounds/miss.mp3", volume:3, group:CitrusSoundGroup.SFX}); //失誤
			sound.addSound("Skid", {sound:"sounds/skid.mp3",group:CitrusSoundGroup.SFX});  //老鷹放人
			sound.addSound("Jump", {sound:"sounds/jump.mp3", volume:3, group:CitrusSoundGroup.SFX}); //疊到
			sound.addSound("Game1", {sound:"sounds/game1.mp3",loops:-1,group:CitrusSoundGroup.BGM}); //第一關背景音樂
			sound.addSound("Ya", {sound:"sounds/yayaya.mp3", group:CitrusSoundGroup.SFX}); //要掉下來哀哀叫
			sound.addSound("Ya1", {sound:"sounds/yayaya1.mp3", group:CitrusSoundGroup.SFX}); //要掉下來哀哀叫
			sound.addSound("Yb", {sound:"sounds/yayayb.mp3", group:CitrusSoundGroup.SFX}); //要掉下來哀哀叫
			sound.addSound("Yc", {sound:"sounds/yayayc.mp3", group:CitrusSoundGroup.SFX}); //要掉下來哀哀叫
			sound.addSound("Wuan", {sound:"sounds/wuan.mp3", group:CitrusSoundGroup.SFX}); //狗要掉下來哀哀叫
			sound.addSound("Walk", { sound:"sounds/walk.mp3",loops: -1, volume:1, group:CitrusSoundGroup.SFX } );
			

			var loader:Loader = new Loader();
			loader.load(new URLRequest("levels/SoundPatchDemo/SoundPatchDemo.swf"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleSWFLoadComplete, false, 0, true);

			/*var websiteFrame:WebsiteFrame = new WebsiteFrame();
			addChild(websiteFrame);*/
		}
		
		/*override public function initialize():void {
			
		}*/

		private function handleSWFLoadComplete(e:Event):void {
			var levelObjectsMC:MovieClip = e.target.loader.content;
			state = new DemoState(levelObjectsMC);

			e.target.loader.unloadAndStop();
		}
	}
}