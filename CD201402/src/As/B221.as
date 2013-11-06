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
	public class B221 extends GM 
	{
		private var myTime:Timer = new Timer(1000, 1);
		
		public function B221() 
		{ 
		}
		
		//進入遊戲
		override public function EnterGame():void {
			ChangeSide_btn.addEventListener(MouseEvent.CLICK, goChangeSide);
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, addHP);
			myTime.start();
			
			//SingletonValue.getInstance().caseArr = [3, 1, 3, 1];  //測試用
			
			initCaseBtn();
		}
		
		//設定按鈕外觀
		private function initCaseBtn():void {
			var _n:uint = SingletonValue.getInstance().caseArr.length;
			var _mc:MovieClip;
			for (var i = 0; i < _n; i++) {
				_mc = this.getChildByName("case" + i + "_mc") as MovieClip;
				_mc.gotoAndStop(SingletonValue.getInstance().caseArr[i]);
				_mc.buttonMode = true;
				_mc.useHandCursor = true;
				_mc.addEventListener(MouseEvent.CLICK, changeCase);
				//若案件進行中或再玩一次,取消滑入手指與偵聽滑鼠按下
				if (_mc.currentFrame == 2 || _mc.currentFrame == 4) {
					_mc.useHandCursor = false;
					_mc.removeEventListener(MouseEvent.CLICK, changeCase);
				} 
			} 
			//判斷最後一個案件是否可執行
			if (SingletonValue.getInstance().caseArr.lastIndexOf(1, 2) + SingletonValue.getInstance().caseArr.lastIndexOf(2, 2) >= 0) {
				_mc.useHandCursor = false;
				_mc.removeEventListener(MouseEvent.CLICK, changeCase);
				_mc.alpha = .3;
			}else {
				_mc.alpha = 1;
			}
		}
		
		//修改caseArr陣列
		private function changeCase(e:MouseEvent):void 
		{
			trace("你要放棄其他案件的紀錄,開始新的案件挑戰嗎?");
			
			//把所有進行中都改成尚未進行
			var _n:uint = SingletonValue.getInstance().caseArr.length;
			for (var i = 0; i < _n; i++) { 
				if (SingletonValue.getInstance().caseArr[i] == 2) { 
					SingletonValue.getInstance().caseArr[i] = 1;
				}else if (SingletonValue.getInstance().caseArr[i] == 4) {  //若是再玩一次就改回破案
					SingletonValue.getInstance().caseArr[i] = 3;
				}
			}
			//按下的按鈕對應的案件改為進行(2)中或再玩一次(4)
	        if (SingletonValue.getInstance().caseArr[e.currentTarget.name.charAt(4)] == 3) {  //若狀態是破案(3)就改成再玩一次(4)
				SingletonValue.getInstance().caseArr[e.currentTarget.name.charAt(4)] = 4
			}else {
				SingletonValue.getInstance().caseArr[e.currentTarget.name.charAt(4)] = 2;
			}
			SingletonValue.getInstance().caseNum = e.currentTarget.name.charAt(4);	//設定caseNum為目前進行中的案件編號
			//trace(SingletonValue.getInstance().caseNum);
			initCaseBtn();
		}
		
		//恢復可樂球血量
		private function addHP(e:TimerEvent):void 
		{
			if (SingletonValue.getInstance().hp + 5 < 100) {
				SingletonValue.getInstance().hp += 5;  trace("221B!!!", "HP:", SingletonValue.getInstance().hp);
				myTime.start();
			} else if (SingletonValue.getInstance().hp + 5 == 100) {
				SingletonValue.getInstance().hp += 5;
				//播放音效  
				trace("221B!!!播放血滿音效", "HP:", SingletonValue.getInstance().hp);
			}
		}
		
		//換場景
		private function goChangeSide(e:MouseEvent):void 
		{
			this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "MainGame.swf"));
		}
		
	}

}