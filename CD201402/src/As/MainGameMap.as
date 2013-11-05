package As 
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class MainGameMap extends MovieClip 
	{
		var mapClipBmpData:BitmapData;
		
		public function MainGameMap() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			mapClipBmpData = new BitmapData(this.width, this.height, true, 0);
			mapClipBmpData.draw(this);
			//trace( "mapClipBmpData : " + mapClipBmpData );
		}
		
	}

}