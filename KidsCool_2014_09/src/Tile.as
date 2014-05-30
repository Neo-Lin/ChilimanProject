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
		
		public function Tile() 
		{
			stop();
			addEventListener(Event.ADDED_TO_STAGE, goDrop);
		}
		
		private function goDrop(e:Event):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, goDrop);
			addEventListener(Event.ENTER_FRAME, drop);
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