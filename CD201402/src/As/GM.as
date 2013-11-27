package As 
{
	import As.Events.MainEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class GM extends MovieClip 
	{
		private var BGSC:SoundChannel;		//背景音樂頻道
		private var BTNSC:SoundChannel;		//按鈕音樂頻道
		private var ESC:SoundChannel;		//音效音樂頻道
		private var TSC:SoundChannel;		//語音音樂頻道
		private var tmpSnd:Sound;
		private var tmpST:SoundTransform;
		
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
		
		//播放音樂
		public function playSound( SC:String , sound:Class , startTime:Number = 0 , loop:int = 1 , vol:Number = 1 ){
			tmpSnd = new sound();
			tmpST = new SoundTransform( vol );
			this[SC] = tmpSnd.play( startTime , loop , tmpST );
			this[SC].addEventListener(Event.SOUND_COMPLETE, scComplete);
		}
		
		public function scComplete(e:Event = null):void 
		{	
			e.currentTarget.removeEventListener(Event.SOUND_COMPLETE, scComplete);
		}
		
		//停止音樂面板
		public function stopSound( SC:String = null ){
			if( this[SC] != null ){
				this[SC].stop();
				if (this[SC].hasEventListener(Event.SOUND_COMPLETE)) { 
					this[SC].removeEventListener(Event.SOUND_COMPLETE, scComplete); 
				}
				SC = null;
			}
		}
		
		//進入遊戲
		public function EnterGame():void { }
		
		//暫停
		public function Pause(e:MainEvent):void { }
		
		//結束暫停
		public function UnPause(e:MainEvent):void{}
		
		//失敗
		public function Lost():void{}
				
		//移除
		public function kill(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
			stopSound("BTNSC");
			stopSound("ESC");
			stopSound("TSC");
			stopSound("BGSC");
		}
	}

}