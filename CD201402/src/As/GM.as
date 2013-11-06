package As 
{
	import As.Events.MainEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class GM extends MovieClip 
	{
		
		public function GM() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, kill);
			stage.addEventListener(MainEvent.PAUSE, Pause);
			stage.addEventListener(MainEvent.UN_PAUSE, UnPause);
			// entry point
			EnterGame();
		}
		
		//進入遊戲
		public function EnterGame():void { }
		
		//暫停
		public function Pause(e:MainEvent):void { }
		
		//結束暫停
		public function UnPause(e:MainEvent):void{}
		
		//過關
		public function Win():void {}
		
		//失敗
		public function Lost():void{}
		
		//看手冊(華生筆記)???
		public function Doc():void { }
		
		//移除
		public function kill(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
		}
	}

}