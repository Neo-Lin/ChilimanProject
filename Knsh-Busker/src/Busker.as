package  
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Busker extends MovieClip 
	{
		private var totalTopic:int = 20;		//總題數
		private var topic_number:int = 0;		//進行中的題目
		private var topic:Array = [];			//題目陣列
		private var _t:Timer = new Timer(1000, 1);
		private var s_yes:Sound = new sound_yes();	//答對音效
		
		public function Busker() 
		{
			stop();
			randomTopic();
			start_btn.addEventListener(MouseEvent.CLICK, goStart);
			_t.addEventListener(TimerEvent.TIMER_COMPLETE, goTime);
		}
		
		//開始
		private function goStart(e:MouseEvent):void 
		{
			gotoAndStop(2);
			time_mc.stop();
			bingo_mc.visible = false;
			bingo_mc.ok_btn.addEventListener(MouseEvent.CLICK, nextTopic);
			time_mc.restart_btn.addEventListener(MouseEvent.CLICK, restart);
			o_btn.addEventListener(MouseEvent.CLICK, goCheck);
			x_btn.addEventListener(MouseEvent.CLICK, goCheck);
			goTopic();
		}
		
		//重新開始
		private function restart(e:MouseEvent):void 
		{
			gotoAndStop(1);
			topic_number = 0;
			randomTopic();
			start_btn.addEventListener(MouseEvent.CLICK, goStart);
		}
		
		//判斷結束或出題
		private function nextTopic(e:MouseEvent):void 
		{
			bingo_mc.visible = false;
			//檢查是否答完所有題目
			if (topic_number + 1 < totalTopic) {
				topic_number++;
				goTopic();
			}else {
				gotoAndStop(3);
				restart_btn.addEventListener(MouseEvent.CLICK, restart);
			}
		}
		
		//檢查答對答錯
		private function goCheck(e:MouseEvent):void 
		{
			_t.stop();
			if ((e.currentTarget.name.charAt(0) == "o" && topic[topic_number] <= 10)
			|| (e.currentTarget.name.charAt(0) == "x" && topic[topic_number] > 10)) {
				bingo_mc.visible = true;
				txt_mc.visible = true;
				s_yes.play(0,0,this.soundTransform);
			}else {
				time_mc.gotoAndStop(51);
			}
		}
		
		//出題
		private function goTopic():void {
			time_mc.gotoAndStop(1);
			q_mc.gotoAndStop(topic_number + 1);
			txt_mc.visible = false;
			txt_mc.gotoAndStop(topic[topic_number]);
			pic_mc.gotoAndStop(topic[topic_number]);
			_t.start();
		}
		
		//產生亂數題目陣列
		private function randomTopic():void {
			topic = [];
			var _n:int;
			do {
				_n = Math.floor(Math.random() * totalTopic) +1;
				if (topic.indexOf(_n) < 0) {
					topic.push(_n);
				}
			}while (topic.length < 20)
			//trace(topic);
		}
		
		//倒數三秒
		private function goTime(e:TimerEvent):void 
		{
			time_mc.nextFrame();
			if (time_mc.currentFrame < 4) {
				_t.start();
			}else {
				time_mc.play();
			}
		}
		
	}

}