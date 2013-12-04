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
	public class ToolBar extends MovieClip 
	{
		
		public function ToolBar() 
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			//stage.addEventListener(MainEvent.PAUSE, Pause);
			//stage.addEventListener(MainEvent.UN_PAUSE, UnPause);
			main_btn.addEventListener(MouseEvent.CLICK, openToolBar);
			index_btn.addEventListener(MouseEvent.CLICK, goIndex);
			ex_btn.addEventListener(MouseEvent.CLICK, goEx);
			sound_btn.addEventListener(MouseEvent.CLICK, goSound);
			exit_btn.addEventListener(MouseEvent.CLICK, goExit);
		}
		
		//回主遊戲
		private function goIndex(e:MouseEvent):void 
		{	trace("index:",e.currentTarget.currentFrame);
			if (index_btn.currentFrame == 1) {
				stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "G00.swf"));
				this.gotoAndPlay("close");
				stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			}
		}
		
		//遊戲說明
		private function goEx(e:MouseEvent):void 
		{	trace("ex:",e.currentTarget.currentFrame, SingletonValue.getInstance().nowSiteName);
			if (ex_btn.currentFrame == 1) {
				if(SingletonValue.getInstance().nowSiteName == "G00.swf") {	//如果在主場景就載入主場景的說明動畫
					stage.dispatchEvent(new MainEvent(MainEvent.LOAD_EX, true,  "G00_G_EX.swf"));
				} else if (SingletonValue.getInstance().unitNum == 2) {	//其他就依照unitNum來載入相對應的說明動畫
					stage.dispatchEvent(new MainEvent(MainEvent.LOAD_EX, true,  "QEX"));
				} else if(SingletonValue.getInstance().unitNum == 4) {
					stage.dispatchEvent(new MainEvent(MainEvent.LOAD_EX, true,  "GEX"));
				}
				this.gotoAndPlay("close");
				stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			}
		}
		
		private function goSound(e:MouseEvent):void 
		{	trace("sound:",e.currentTarget.currentFrame);
			
		}
		
		private function goExit(e:MouseEvent):void 
		{	trace("Exit:",e.currentTarget.currentFrame);
			if (exit_btn.currentFrame == 1) {
				stage.dispatchEvent(new MainEvent(MainEvent.EXIT, true));
				this.gotoAndPlay("close");
				stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			}
		}
		
		private function openToolBar(e:MouseEvent):void 
		{	trace("open");
			stage.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
			this.gotoAndPlay("open");
		}
		
		//暫停
		/*public function Pause(e:MainEvent):void { 
			main_btn.removeEventListener(MouseEvent.CLICK, openToolBar);
			index_btn.gotoAndStop(2);
			ex_btn.gotoAndStop(2);
			//sound_btn.gotoAndStop(2);
			exit_btn.gotoAndStop(2);
		}
		
		//結束暫停
		public function UnPause(e:MainEvent):void {
			main_btn.addEventListener(MouseEvent.CLICK, openToolBar);
			index_btn.gotoAndStop(1);
			ex_btn.gotoAndStop(1);
			//sound_btn.gotoAndStop(1);
			exit_btn.gotoAndStop(1);
		}*/
	}

}