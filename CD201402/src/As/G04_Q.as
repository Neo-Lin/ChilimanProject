package As 
{
	import As.Events.MainEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Neo
	 */
	public class G04_Q extends GM 
	{
		//==============================
		//finish_mc				過關字卡
		//	ok_btn					確定紐
		//lightAll_mc			答對數量圖示
		//topic_mc				題目板
		//b_btn,n_btn			校對用上下題按鈕			
		//
		//
		//==============================
		private var nowTopic:uint = 0;		//目前答對幾題
		private var totalTopic:uint;		//幾題可以過關
		//所有題目陣列,亂數抽取用
		private var topicArray:Array = new Array();
		private var tempAnswer:MovieClip;	//紀錄當題的正確答案是哪一個按鈕
		private var nextTimer:Timer = new Timer(1000, 1);//答完倒數一秒接下一題
		
		public function G04_Q() 
		{
			
		}
		
		override public function EnterGame():void {
			b_btn.visible = false;
			n_btn.visible = false;
			b_btn.addEventListener(MouseEvent.CLICK, testMode);
			n_btn.addEventListener(MouseEvent.CLICK, testMode);
			
			finish_mc.visible = false;
			finish_mc.ok_btn.addEventListener(MouseEvent.CLICK, goFinish);
			
			totalTopic = lightAll_mc.numChildren;
			nextTimer.addEventListener(TimerEvent.TIMER_COMPLETE, goNext);
			
			linstnerAll();
			
			//產生所有題目陣列,亂數抽取用
			for (var i:uint = 1; i <= topic_mc.totalFrames; i++) {
				topicArray.push(i);
			}
			/*for (var _i:uint = 0; _i < 3; _i++) {
				//var n:uint = _a.splice(Math.random() * _a.length, 1)[0];
				this["answer" + (_i + 1) + "_mc"].answer_mc.gotoAndStop("q" + topic_mc.currentFrame + (_i + 1));
			}*/
			
			startTopic();
		}
		
		private function linstnerAll():void 
		{
			for (var i:uint = 1; i <= 3; i++) {
				this["answer" + i + "_mc"].addEventListener(MouseEvent.CLICK, selectAnswer);
				this["answer" + i + "_mc"].addEventListener(MouseEvent.MOUSE_OVER, mcOver);
				this["answer" + i + "_mc"].addEventListener(MouseEvent.MOUSE_OUT, mcOut);
				this["answer" + i + "_mc"].answer_btn.gotoAndStop("mouseOut");
			}
		}
		private function unLinstnerAll():void 
		{
			for (var i:uint = 1; i <= 3; i++) {
				this["answer" + i + "_mc"].removeEventListener(MouseEvent.CLICK, selectAnswer);
				this["answer" + i + "_mc"].removeEventListener(MouseEvent.MOUSE_OVER, mcOver);
				this["answer" + i + "_mc"].removeEventListener(MouseEvent.MOUSE_OUT, mcOut);
			}
		}
		
		//出題&&選項
		private function startTopic():void 
		{
			//亂數出題
			var _n:uint = topicArray.splice(Math.random() * topicArray.length, 1)[0];
			topic_mc.gotoAndStop(_n);
			//亂數選項
			var _a:Array = [1, 2, 3];
			for (var i:uint = 0; i < 3; i++) {
				var n:uint = _a.splice(Math.random() * _a.length, 1)[0];
				this["answer" + (i + 1) + "_mc"].answer_mc.gotoAndStop("q" + _n + n);
				//紀錄正確答案是哪個按鈕,正確答案固定放在第1個影格
				if (n == 1) {
					tempAnswer = this["answer" + (i + 1) + "_mc"];
					trace(tempAnswer.name);
				}
			}
		}
		
		private function selectAnswer(e:MouseEvent):void 
		{
			if (e.currentTarget == tempAnswer) {
				trace("答對");
				nowTopic++;
				e.currentTarget.answer_btn.gotoAndStop("O");	//顯示按鈕答對動畫
				lightAll_mc["light" + nowTopic + "_mc"].gotoAndStop(2);	//亮燈泡
				
			}else {
				trace("答錯");
				e.currentTarget.answer_btn.gotoAndStop("X");
			}
			unLinstnerAll()
			nextTimer.start();
		}
		
		private function goNext(e:TimerEvent):void 
		{
			//檢查答對題數是否滿足過關標準
			if (nowTopic == totalTopic) {
				finish_mc.visible = true;
				tempAnswer.answer_btn.gotoAndStop("mouseOut");
				return;
			}
			if (topicArray.length <= 0) {
				trace("挑戰失敗..............");
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "G00.swf"));
				return;
			}
			linstnerAll();
			startTopic();
		}
		
		private function mcOver(e:MouseEvent):void 
		{	
			e.currentTarget.answer_btn.gotoAndStop("mouseOver");
		}
		
		private function mcOut(e:MouseEvent):void 
		{
			e.currentTarget.answer_btn.gotoAndStop("mouseOut");
		}
		
		//過關
		private function goFinish(e:MouseEvent):void 
		{
			trace("恭喜恭喜!!");
			this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "GEX"));
		}
		
		//校對用
		private function testMode(e:MouseEvent):void 
		{
			if (e.currentTarget.name == "b_btn") { 
				topic_mc.prevFrame();
			}else {
				topic_mc.nextFrame();
			}
			if (topic_mc.currentFrame < topic_mc.totalFrames) {
				n_btn.visible = true;
			}else  {
				n_btn.visible = false;
			}
			if (topic_mc.currentFrame > 1) {
				b_btn.visible = true;
			}else {
				b_btn.visible = false;
			}
			//var _a:Array = [1, 2, 3];
			for (var i:uint = 0; i < 3; i++) {
				//var n:uint = _a.splice(Math.random() * _a.length, 1)[0];
				this["answer" + (i + 1) + "_mc"].answer_mc.gotoAndStop("q" + topic_mc.currentFrame + (i + 1));
			}
		}
	}

}