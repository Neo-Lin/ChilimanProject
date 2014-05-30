package 
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var loader:Loader = new Loader();
			loader.load(new URLRequest("swf/EliminateGame.swf"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleSWFLoadComplete, false, 0, true);
		}
		
		private function handleSWFLoadComplete(e:Event):void 
		{
			var levelObjectsMC:MovieClip = e.target.loader.content;
			var eg:EliminateGame = new EliminateGame(levelObjectsMC);
			addChild(eg);
			
			//e.target.loader.unloadAndStop();
		}
		
	}
	
}