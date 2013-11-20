package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Matchstick extends MovieClip 
	{
		//記錄每一關的題目(要顯示的火柴棒)
		private var AQ:Array = [[],
								[],
								[],
								[],
								[],
								["_9","_8","_14","_13","_12","_18","_19","_17","_25","_27"],
								[],
								[],
								[],
								[]];
		//記錄每一關的答案(要顯示的火柴棒)
		private var AA:Array = [[],
								[],
								[],
								[],
								[],
								["_9", "_8", "_14", "_13", "_12", "_18", "_19", "_5", "_35", "_20"],
								[],
								[],
								[],
								[]];
		//每關的可走步數Array
		private var allStep:Array = [,,,,,3,,,,];				
		private var nowStep:uint = 0;				//目前步數
		private var nowQ:uint = 5;					//目前關卡uint
		private var takeMatch:Boolean = false;		//玩家是否有選取火柴
		private var tempMatch:MovieClip;			//紀錄玩家選取的火柴
		private var againNum:uint = 1;				//重玩次數
		
		
		public function Matchstick() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			start_btn.addEventListener(MouseEvent.CLICK, goStart);
		}
		
		private function goStart(e:MouseEvent):void 
		{	
			start_btn.visible = false;
			this.gotoAndStop("GAME");
			txtCard_mc.visible = false;		//字卡
			txtCard_mc.ok_btn.addEventListener(MouseEvent.CLICK, goNextQ);
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
			if (takeMatch && e.currentTarget.currentLabel != "exist") {
				tempMatch.gotoAndStop("noexist");
				e.currentTarget.gotoAndStop("exist");
				takeMatch = false;
				nowStep++;
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
			for (var i:uint = 0; i < _n; i++) {
				_mc = MovieClip(match_mc.getChildAt(0)).getChildByName(AA[nowQ][i]) as MovieClip;
				if (_mc.currentLabel == "noexist") {
					trace("沒過");
					if (againNum == 3) {
						lose();
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
			nowQ = 5;
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
		
		//答對
		private function win():void 
		{
			txtCard_mc.gotoAndStop("win");
			txtCard_mc.visible = true;
			time_mc.stopTime();
			nowStep = 0;
			againNum = 1;
			nowQ++;
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
		}
		
	}

}