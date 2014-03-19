package  
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	/**
	 * ...載入遊戲動畫及說明等
	 * @author Neo
	 */
	public class OpLoader extends Loader 
	{
		private var _btn:SimpleButton;
		private var card_mc:MovieClip;
		private var _gameNumber:int;
		
		public function OpLoader(_url:String) 
		{
			super();
			contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			load(new URLRequest(_url));
		}
		
		private function onComplete(e:Event):void 
		{
			/*if (MovieClip(content)._btn) { //跳過 
				_btn = MovieClip(content)._btn;
				_btn.addEventListener(MouseEvent.CLICK, onBtnClick);
			}else if (MovieClip(content).card_mc) { //字卡
				card_mc = MovieClip(content).card_mc;
				card_mc.addEventListener(MouseEvent.CLICK, cardClick);
			}*/
			//影格播完自動發出事件
			addEventListener(Event.ENTER_FRAME, goEnd);
			addEventListener(MouseEvent.CLICK, cardClick);
		}
		
		private function goEnd(e:Event):void 
		{
			if (MovieClip(content).currentFrame == MovieClip(content).totalFrames) {
				//trace("自動事件");
				removeEventListener(Event.ENTER_FRAME, goEnd);
				dispatchEvent(new Event("finishMovie"));
			}
		}
		
		private function cardClick(e:MouseEvent):void 
		{	trace(e.target.name);
			if (e.target.name == "_btn") { //跳過
				dispatchEvent(new Event("goNext"));
			}else if (e.target.name == "back_btn") { //回選單
				dispatchEvent(new Event("goBack"));
			}else if (e.target.name == "close_btn") { //關閉遊戲
				dispatchEvent(new Event("CLOSE_WINDOW"));
			}else if (e.target.name == "again_btn") { //再一次
				dispatchEvent(new Event("goAgain"));
			}else if (e.target.name == "store_btn") { //到儲藏室
				trace("儲藏室");
				dispatchEvent(new Event("goStore"));
			}else if (e.target.name == "game1_btn") { //第一關
				_gameNumber = 1;
				dispatchEvent(new Event("startGoGame"));
			}else if (e.target.name == "game2_btn") { //第二關
				//DemoState.indexComplete會用日期判斷每個關卡開放的狀態,開放就會把game2_mc.gotoAndStop(2)
				if (MovieClip(content).game2_mc.currentFrame == 1) return;
				_gameNumber = 2;
				dispatchEvent(new Event("startGoGame"));
			}else if (e.target.name == "game3_btn") { //第三關
				if (MovieClip(content).game3_mc.currentFrame == 1) return;
				_gameNumber = 3;
				dispatchEvent(new Event("startGoGame"));
			}else if (e.target.name == "game4_btn") { //第四關
				if (MovieClip(content).game4_mc.currentFrame == 1) return;
				_gameNumber = 4;
				dispatchEvent(new Event("startGoGame"));
			}
		}
		
		public function get gameNumber():int 
		{
			return _gameNumber;
		}
		
		override public function unloadAndStop(gc:Boolean = true):void 
		{
			super.unloadAndStop(gc);
			removeEventListener(MouseEvent.CLICK, cardClick);
			removeEventListener(Event.ENTER_FRAME, goEnd);
		}
		
		/*private function onBtnClick(e:MouseEvent):void 
		{
			dispatchEvent(new Event("goNext"));
		}*/
	}

}