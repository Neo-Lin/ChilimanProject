package  
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Matchstick extends MovieClip 
	{
		//記錄每一關的題目(要顯示的火柴棒)
		private var AQ:Array = [["_2","_3","_4","_6","_7","_22","_23","_8","_10","_11","_14","_24","_25","_15","_16","_18","_20","_21"],
								["_3","_7","_23","_10","_14","_24","_25","_15","_16","_18","_19","_20","_21"],
								["_2","_3","_4","_5","_6","_22","_23","_8","_9","_11","_12","_13","_14","_24","_25","_16","_17","_21"],
								["_7","_8","_14","_12","_13","_18","_19","_17","_25","_24"],
								["_4","_7","_8","_12","_18","_13","_19","_17","_25","_27"],
								["_9","_8","_14","_13","_12","_18","_19","_17","_25","_27"],
								["_1","_3","_4","_5","_6","_7","_8","_9","_10","_11","_12","_13","_14","_15","_17"],
								["_2","_6","_7","_11","_12","_16","_17","_18","_19"],
								["_2","_6","_8","_9","_13","_17","_18","_19","_22","_23"],
								["_5","_9","_10","_11","_15","_16","_17","_21"]];
		//記錄每一關的答案(要顯示的火柴棒)
		private var AA:Array = [["_2","_3","_4","_6","_7","_1","_23","_8","_10","_11","_14","_24","_25","_15","_16","_18","_20","_21"],
								["_3","_7","_23","_10","_14","_24","_25","_15","_16","_17","_19","_20","_21"],
								["_2","_3","_4","_5","_6","_22","_23","_8","_9","_11","_26","_13","_14","_24","_25","_16","_17","_21"],
								["_9","_8","_14","_12","_13","_18","_19","_17","_25","_27"],
								["_9","_14","_8","_12","_18","_13","_19","_17","_25","_27"],
								["_9", "_8", "_14", "_13", "_12", "_18", "_19", "_5", "_35", "_20"],
								[["_2","_3","_5","_6","_7","_8","_9","_10","_11","_12","_13","_14","_15","_16","_17"],
								 ["_1","_2","_4","_5","_6","_8","_9","_10","_11","_12","_13","_14","_15","_16","_17"],
								 ["_1","_2","_3","_4","_5","_6","_7","_8","_9","_10","_11","_12","_13","_15","_16"],
								 ["_1","_2","_3","_4","_5","_6","_7","_8","_9","_10","_12","_13","_14","_16","_17"]],
								[["_1", "_2", "_4", "_5", "_6", "_7", "_11", "_16", "_17"],
								 ["_2", "_3", "_6", "_7", "_8", "_9", "_12", "_18", "_19"],
								 ["_11","_12","_16","_17","_18","_19","_23","_27","_28"]],
								["_2","_6","_7","_9","_14","_17","_18","_19","_22","_23"],
								[["_20", "_22", "_10", "_24", "_15", "_16", "_17", "_21"],
								 ["_5", "_9", "_10", "_11", "_2", "_16", "_4", "_6"]]];
		//每關的可走步數Array
		private var allStep:Array = [1,1,1,2,2,3,2,3,2,3];				
		private var nowStep:uint = 0;				//目前步數
		private var nowQ:uint = 0;					//目前關卡uint
		private var takeMatch:Boolean = false;		//玩家是否有選取火柴
		private var tempMatch:MovieClip;			//紀錄玩家選取的火柴
		private var againNum:uint = 1;				//重玩次數
		private var winTimer:Timer = new Timer(1000, 1);//答對倒數一秒接下一題
		private var s_yes:Sound = new sound_yes();	//答對音效
		private var s_take:Sound = new sound_take();//拿火柴音效
		private var s_btnS:Sound = new sound_btnS();  //按鈕音效
			
		public function Matchstick() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(MouseEvent.CLICK, playSound);
			winTimer.addEventListener(TimerEvent.TIMER_COMPLETE, goWin);
			qa_mc.visible = false;		//遊戲說明
			qa_mc.ok_btn.addEventListener(MouseEvent.CLICK, closeQA);
			start_btn.addEventListener(MouseEvent.CLICK, goStart);
		}
		
		private function playSound(e:MouseEvent):void 
		{
			if (e.target is SimpleButton) {
				s_btnS.play(0,0,this.soundTransform);
			}
		}
		
		private function goStart(e:MouseEvent):void 
		{	
			start_btn.visible = false;
			this.gotoAndStop("GAME");
			txtCard_mc.visible = false;		//字卡
			txtCard_mc.ok_btn.addEventListener(MouseEvent.CLICK, goNextQ);
			qa_btn.addEventListener(MouseEvent.CLICK, goQA);
			sound_btn.addEventListener(MouseEvent.CLICK, mute);
			time_mc.addEventListener("timeout", timeOut);
			actionQ();
		}
		
		//開始出題
		private function actionQ():void 
		{
			match_mc.gotoAndStop(nowQ + 1);
			var _n:uint = MovieClip(match_mc.getChildAt(0)).numChildren;
			var _mc:MovieClip;
			for (var i:uint = 0; i < _n; i++) {
				_mc = MovieClip(match_mc.getChildAt(0)).getChildAt(i) as MovieClip;
				if (AQ[nowQ].indexOf(_mc.name) >= 0) {
					_mc.gotoAndStop("exist");
				}else { 
					_mc.gotoAndStop("noexist");
				}
				_mc.addEventListener(MouseEvent.CLICK, matchChange);
			}
			Q_mc.gotoAndStop(nowQ + 1);
			QT_mc.gotoAndStop(nowQ + 1);
		}
		
		//點選火柴棒
		private function matchChange(e:MouseEvent):void 
		{
			s_take.play(0,0,this.soundTransform);
			if (takeMatch && e.currentTarget.currentLabel != "exist") {
				tempMatch.gotoAndStop("noexist");
				e.currentTarget.gotoAndStop("exist");
				takeMatch = false;
				if (tempMatch != e.currentTarget) {
					nowStep++;
				}
				if (nowStep == allStep[nowQ]) goCheckQ();
			} else if (!takeMatch && e.currentTarget.currentLabel == "exist") {
				tempMatch = e.currentTarget as MovieClip;
				tempMatch.gotoAndStop("select");
				takeMatch = true;
			}
		}
		
		//檢查是否答對
		private function goCheckQ():void 
		{	
			var _n:uint = AA[nowQ].length;
			var _mc:MovieClip;
			
			//有多種答案
			if (AA[nowQ][0] is Array) {		
				for (var _i:uint = 0; _i < _n; _i++) {
					var n:uint = AA[nowQ][_i].length;
					for (var j:uint = 0; j < n; j++) {
						_mc = MovieClip(match_mc.getChildAt(0)).getChildByName(AA[nowQ][_i][j]) as MovieClip;
						if (_mc.currentLabel == "noexist") {
							break;
						}
					}
					//如果for有執行完都沒有break表示全部符合
					if (j == n) {
						trace("過關");
						win();
						return;
					}
				}
				trace("沒過");
				if (againNum == 3) {
					lose();
					life_mc.gotoAndStop(4);	//燈全滅
				} else {
					again();
				}
				return;
			}
			
			//只有一種答案
			for (var i:uint = 0; i < _n; i++) {
				_mc = MovieClip(match_mc.getChildAt(0)).getChildByName(AA[nowQ][i]) as MovieClip;
				if (_mc.currentLabel == "noexist") {
					trace("沒過");
					if (againNum == 3) {
						lose();
						life_mc.gotoAndStop(4);	//燈全滅
					} else {
						again();
					}
					return;
				}
			}
			trace("過關");
			win();
		}
		
		//Game Over
		private function lose():void 
		{
			txtCard_mc.gotoAndStop("lose");
			txtCard_mc.visible = true;
			time_mc.stopTime();
			nowStep = 0;
			againNum = 1;
			nowQ = 0;
		}
		
		//再試一次
		private function again():void 
		{
			txtCard_mc.gotoAndStop("again");
			txtCard_mc.visible = true;
			time_mc.stopTime();
			againNum++;
			life_mc.gotoAndStop(againNum);
			nowStep = 0;
		}
		
		//時間到
		private function timeOut(e:Event):void 
		{
			goCheckQ();
		}
		
		//答對
		private function win():void 
		{
			s_yes.play(0,0,this.soundTransform);
			winTimer.start();
			txtCard_mc.gotoAndStop(1);
			txtCard_mc.visible = true;
		}
		private function goWin(e:TimerEvent):void 
		{
			if (nowQ != allStep.length - 1) {
				txtCard_mc.gotoAndStop("win");
				txtCard_mc.visible = true;
				time_mc.stopTime();
				nowStep = 0;
				againNum = 1;
				takeMatch = false;
				nowQ++;
			}else {	//最後一題
				txtCard_mc.gotoAndStop("allWin");
				txtCard_mc.visible = true;
				time_mc.stopTime();
				nowStep = 0;
				againNum = 1;
				nowQ = 0;
			}
		}
		
		//下一關或再試一次
		private function goNextQ(e:MouseEvent):void 
		{
			//三次機會都用完或是全部過關就回首頁
			if (txtCard_mc.currentLabel == "lose" || txtCard_mc.currentLabel == "allWin") {
				this.gotoAndStop("index");
				start_btn.visible = true;
				return;
			}
			txtCard_mc.visible = false;
			actionQ();
			time_mc.startTime();
			life_mc.gotoAndStop(againNum);
			txtCard_mc.gotoAndStop(0);
		}
		
		//遊戲說明
		private function goQA(e:MouseEvent):void 
		{
			time_mc.stopTime();
			qa_mc.visible = true;
		}
		private function closeQA(e:MouseEvent):void 
		{
			qa_mc.visible = false;
			time_mc.reStartTime();
		}
		
		//靜音
		private function mute(e:MouseEvent):void 
		{
			var st:SoundTransform = new SoundTransform(0);
			if (this.soundTransform.volume == 1) {
				this.soundTransform = new SoundTransform(0);
				
			}else {
				this.soundTransform = new SoundTransform(1);
			}
		}
		
	}

}