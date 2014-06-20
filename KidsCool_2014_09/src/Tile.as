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
		public var select_mc:MovieClip;
		public var help_mc:MovieClip;
		
		public function Tile() 
		{
			stop();
			addEventListener(Event.ADDED_TO_STAGE, goDrop);
			select_mc.visible = false;
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
		
	}

}