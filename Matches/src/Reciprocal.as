package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Reciprocal extends MovieClip 
	{
		private var _minute:uint = 6;
		private var _second:uint = 10;
		private var minute:uint;
		private var second:uint;
		private var myTime:Timer = new Timer(1000, 1);
		
		public function Reciprocal() 
		{
			startTime();
		}
		
		public function startTime():void {
			second = _second;
			minute = _minute;
			second_mc.gotoAndStop(second);
			minute_mc.gotoAndStop(minute);
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, changeTime);
			myTime.start();
		}
		
		public function stopTime():void {
			myTime.stop();
		}
		
		private function changeTime(e:TimerEvent):void 
		{
			second--;
			if (second == 0) {
				second = 10;
			}else if (second == 9) {
				minute --;
				if (minute == 0) {
					minute = 10;
				}
			}
			second_mc.gotoAndStop(second);
			minute_mc.gotoAndStop(minute);
			
			if (second == 10 && minute == 10) {
				myTime.stop();
				this.dispatchEvent(new Event("timeout"));
				return;
			}
			myTime.start();
		}
		
	}

}