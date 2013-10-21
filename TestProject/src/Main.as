package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author test
	 */
	public class Main extends Sprite 
	{
		private var myS:testSwc;
		private var ot1:OverrideTest1;
		private var ot2:OverrideTest2;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			myS = new testSwc();
			myS.x = 100;
			myS.y = 100; 
			myS.addEventListener(MenuEvent.Mouse_Click, doMenu);
			addChild(myS);
			
			ot1 = new OverrideTest1();
			ot2 = new OverrideTest2();
			//ot1.ft1();
			//ot1.ft2();
			//ot2.ft1();
		}
		
		private function doMenu(e:MenuEvent):void 
		{
			trace(e.Target_Name);
		}
		
		
	}
	
}