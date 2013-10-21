package  
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author test
	 */
	public class testSwcAs extends MovieClip
	{
		
		public function testSwcAs():void
		{
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void 
		{
			trace("testSwcAs trace target: " + e.target.name);
			trace("testSwcAs trace currentTarget : " + e.currentTarget.name);
			dispatchEvent(new MenuEvent(MenuEvent.Mouse_Click, e.target.name));
		}
		
		
	}

}