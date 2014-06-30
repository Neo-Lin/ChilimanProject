package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Tile extends MovieClip 
	{
		public static const BOMB:String = "bomb";
		public static const LIGHTNING:String = "lightning";
		public static const RANDOM_TILE:String = "randomTile";
		
		public var select_mc:MovieClip;
		public var help_mc:MovieClip;
		public var skill_mc:MovieClip;
		private var _skill:String;
		private var _readyKill:Boolean;
		
		public function Tile() 
		{
			//stop();
			addEventListener(Event.ADDED_TO_STAGE, goDrop);
			select_mc.visible = false;
			//skill_mc.visible = false;
			
			var _r:Number = Math.random();
			if (_r < .02) {
				skill_mc.gotoAndStop(BOMB);
				skill = BOMB;
			}else if (_r > .02 && _r < .04) {
				skill_mc.gotoAndStop(LIGHTNING);
				skill = LIGHTNING;
			}else if (_r > .04 && _r < .06) {
				//skill_mc.gotoAndStop(RANDOM_TILE);
				skill = RANDOM_TILE;
			}
		}
		
		private function goDrop(e:Event):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, goDrop);
			//addEventListener(Event.ENTER_FRAME, drop);
		}
		
		private function drop(e:Event):void 
		{	
			y+=5;
			if (y>500) {
				removeEventListener(Event.ENTER_FRAME, drop);
			}
		}
		
		public function get skill():String 
		{
			return _skill;
		}
		
		public function set skill(value:String):void 
		{
			_skill = value;
		}
		
		public function get readyKill():Boolean 
		{
			return _readyKill;
		}
		
		public function set readyKill(value:Boolean):void 
		{
			_readyKill = value;
		}
		
	}

}