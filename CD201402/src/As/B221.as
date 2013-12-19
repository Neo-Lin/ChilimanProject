package As 
{
	import As.Events.MainEvent;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Neo
	 */
	public class B221 extends GM 
	{
		private var myTime:Timer = new Timer(1000, 1);
		private var caseBtnNum:uint;
		private var eventLoad:Loader = new Loader();
		private var eventUrl:URLRequest;
		private var allBtn:Array;
		private var soundArray:Array = [[sound_g1_1, sound_g1_2, sound_g1_3, sound_g1_4, sound_g1_5],
										[sound_g2_1, sound_g2_2, sound_g2_3, sound_g2_4],
										[sound_g3_1, sound_g3_2, sound_g3_3, sound_g3_4],
										[sound_g4_1, sound_g4_2, sound_g4_3, sound_start]];
		
		public function B221() 
		{ 
		}
		
		//進入遊戲
		override public function EnterGame():void {
			stop();
			
			//測試模式
			if (SingletonValue.getInstance().testMode) {
				//this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "G00.swf"));
				eventLoad.addEventListener(MouseEvent.CLICK, goSkip);
			}
			
			//若案件有破關過就可以跳過華生對話
			if (SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] != 4){
				skip_btn.visible = false;
			}
			stage.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_HIDE, true));
			skip_btn.addEventListener(MouseEvent.CLICK, skipWatson);
			//華生對話,依據進入221B時的狀態播放語音
			if (SingletonValue.getInstance().caseNum == 4) { //未進行任何案件
				playSound("TSC", sound_start);
				watson_mc.gotoAndStop(3);
				SingletonValue.getInstance().needRest = true;  //華生說完話之後要顯示休息一下
			}else if (SingletonValue.getInstance().unitNum == 4 && SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) { //過關
				playSound("TSC", soundArray[SingletonValue.getInstance().caseNum][3]);
				watson_mc.gotoAndStop(4);
				SingletonValue.getInstance().needRest = true;
			}else if (SingletonValue.getInstance().hp <= 10) { //快掛了
				playSound("TSC", soundArray[SingletonValue.getInstance().caseNum][1]);
				watson_mc.gotoAndStop(7);
				SingletonValue.getInstance().needRest = true;
			}else if (SingletonValue.getInstance().unitNum == 5) { //沒進去案發現場
				playSound("TSC", soundArray[SingletonValue.getInstance().caseNum][0]);
				watson_mc.gotoAndStop(2);
				SingletonValue.getInstance().needRest = true;
			}else if (SingletonValue.getInstance().unitNum == 4 && SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 2) { //沒過關
				playSound("TSC", soundArray[SingletonValue.getInstance().caseNum][2]);
				watson_mc.gotoAndStop(5);
				SingletonValue.getInstance().needRest = true;
			}else if (SingletonValue.getInstance().unitNum == 2 && SingletonValue.getInstance().caseNum == 0) { //只有G01有這狀況
				playSound("TSC", soundArray[SingletonValue.getInstance().caseNum][4]);
				watson_mc.gotoAndStop(6);
				SingletonValue.getInstance().needRest = true;
			}else { //若沒有需要撥放的華生語音,就顯示主選單
				stage.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_SHOW, true));
				skip_btn.visible = false;
				skip_btn.removeEventListener(MouseEvent.CLICK, skipWatson);
			}
			
			HP_mc.gotoAndStop(SingletonValue.getInstance().hp);
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, addHP);
			myTime.start();
			
			//是否要放棄紀錄挑戰其他案件字卡
			changeCase_mc.visible = false;		
			changeCase_mc.y_btn.addEventListener(MouseEvent.CLICK, changeCase);
			changeCase_mc.n_btn.addEventListener(MouseEvent.CLICK, noChange);
			//出發到案發現場
			goCase_mc.visible = false;		
			
			//繼續挑戰其他案件吧
			keepOn_mc.visible = false;		
			keepOn_mc.go_btn.addEventListener(MouseEvent.CLICK, keepOn);
			//已經破案要再玩嗎?
			caseHasEnded_mc.visible = false;
			caseHasEnded_mc.y_btn.addEventListener(MouseEvent.CLICK, againCase);
			caseHasEnded_mc.n_btn.addEventListener(MouseEvent.CLICK, noAgainCase);
			
			//SingletonValue.getInstance().caseArr = [3, 3, 3, 1];  //測試用
			//四個案件的華生與可樂球對話
			event1_mc.addEventListener("finish", openBook);
			event2_mc.addEventListener("finish", openBook);
			event3_mc.addEventListener("finish", openBook);
			event4_mc.addEventListener("finish", openBook);
			event1_mc.visible = event2_mc.visible = event3_mc.visible = event4_mc.visible = false;
			
			allBtn = [case0_mc, case1_mc, case2_mc, case3_mc];
			
			initCaseBtn();
			setSound();
			
		}
	
		private function keepOn(e:MouseEvent):void 
		{
			keepOn_mc.visible = false;
			stage.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_SHOW, true));
			goCheckRest();
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
				_mc.addEventListener(MouseEvent.CLICK, ifCaseHasEnded);
				//若案件進行中或再玩一次,取消滑入手指與偵聽滑鼠按下
				if (_mc.currentFrame == 2 || _mc.currentFrame == 4) {
					//_mc.useHandCursor = false;
					_mc.removeEventListener(MouseEvent.CLICK, ifCaseHasEnded);
					_mc.addEventListener(MouseEvent.CLICK, goChangeSide);
				} 
			} 
			//判斷最後一個案件是否可執行
			if (SingletonValue.getInstance().caseArr.lastIndexOf(1, 2) >= 0 || SingletonValue.getInstance().caseArr.lastIndexOf(2, 2) >= 0) {
				_mc.useHandCursor = false;
				_mc.removeEventListener(MouseEvent.CLICK, ifCaseHasEnded);
				_mc.gotoAndStop(5);
			}else {
				//_mc.alpha = 1;
			}
		}
			
		private function againCase(e:MouseEvent):void 
		{
			checkChange();
			caseHasEnded_mc.visible = false;
		}
		private function noAgainCase(e:MouseEvent):void 
		{
			caseHasEnded_mc.visible = false;
		}
		//檢查案件是不是破過了
		private function ifCaseHasEnded(e:MouseEvent):void {
			stopSound("BTNSC");
			caseBtnNum = e.currentTarget.name.charAt(4);
			if (e.currentTarget.currentFrame == 3) {//這個案件你已經破案，你要再進行一次嗎?
				caseHasEnded_mc.visible = true;
			}else {
				checkChange();
			}
		}
		
		//檢查目前有沒有進行中的案件
		private function checkChange():void 
		{
			if (SingletonValue.getInstance().caseNum == 4) {  //如果目前沒有進行任何案件
				changeCase(null);
			}else {  //如果有就問:你要放棄其他案件的紀錄,開始新的案件挑戰嗎?
				changeCase_mc.visible = true;
				changeCase_mc.gotoAndStop(SingletonValue.getInstance().caseNum + 1);
				playSound("TSC", getDefinitionByName("sound_changeCase" + SingletonValue.getInstance().caseNum) as Class);
			}
		}
		
		//放棄換場景
		private function noChange(e:MouseEvent):void 
		{
			changeCase_mc.visible = false;
			stopSound("TSC");
		}
		
		//修改caseArr陣列
		private function changeCase(e:MouseEvent):void 
		{
			changeCase_mc.visible = false;
			stopSound("TSC");
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
	        if (SingletonValue.getInstance().caseArr[caseBtnNum] == 3) {  //若狀態是破案(3)就改成再玩一次(4)
				SingletonValue.getInstance().caseArr[caseBtnNum] = 4
			}else {
				SingletonValue.getInstance().caseArr[caseBtnNum] = 2;
			}
			SingletonValue.getInstance().caseNum = caseBtnNum;	//設定caseNum為目前進行中的案件編號
			SingletonValue.getInstance().unitNum = 5;	//設定案件進度,一律都由EVENTS(案發過程動畫)開始
			//trace(SingletonValue.getInstance().caseNum);
			initCaseBtn();
			//載入
			trace(SingletonValue.getInstance().allGameSwf[5][SingletonValue.getInstance().caseNum]);
			eventUrl = new URLRequest(SingletonValue.getInstance().allGameSwf[5][SingletonValue.getInstance().caseNum]);
			eventUrl.url = SingletonValue.getInstance().userLink + eventUrl.url;
			loadEvent();
			eventUrl.url = SingletonValue.getInstance().allGameSwf[5][SingletonValue.getInstance().caseNum];
			//this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  SingletonValue.getInstance().allGameSwf[0][SingletonValue.getInstance().caseNum]));
		}
		
		private function loadEvent():void 
		{
			SingletonValue.getInstance().needRest = true;
			eventLoad.load(eventUrl);
			stage.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_HIDE, true));
			eventLoad.contentLoaderInfo.addEventListener(Event.COMPLETE, playEvent);
			addChild(eventLoad);
		}
		
		private function playEvent(e:Event):void 
		{
			eventLoad.content.addEventListener("finish", eventFinish);
			//若案件有破關過就可以跳過案發動畫
			if (SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 4){
				skip_btn.visible = true;
				this.addChild(skip_btn);
				skip_btn.addEventListener(MouseEvent.CLICK, skipEvent);
				skip_btn.removeEventListener(MouseEvent.CLICK, skipWatson);
			}
		}
		
		//跳過案發動畫
		private function skipEvent(e:MouseEvent):void 
		{	
			skip_btn.removeEventListener(MouseEvent.CLICK, skipEvent);
			var _mc:MovieClip = eventLoad.content as MovieClip;
			_mc.gotoAndPlay(_mc.totalFrames);
			skip_btn.addEventListener(MouseEvent.CLICK, skipEventMove);
			skip_btn.visible = true;
		}
		
		//跳過案發動畫後的場景上對話動畫
		private function skipEventMove(e:MouseEvent):void 
		{
			skip_btn.removeEventListener(MouseEvent.CLICK, skipEventMove);
			skip_btn.visible = false;
			var st:SoundTransform = new SoundTransform(0);
			this["event" + eventUrl.url.substr(2, 1) + "_mc"].soundTransform  = st;
			this["event" + eventUrl.url.substr(2, 1) + "_mc"].gotoAndPlay(this["event" + eventUrl.url.substr(2, 1) + "_mc"].totalFrames);
		}
		
		private function eventFinish(e:Event):void 
		{
			trace("案件動畫結束!");
			eventLoad.unloadAndStop();
			watson_mc.visible = cola_mc.visible = false;
			this["event" + eventUrl.url.substr(2, 1) + "_mc"].visible = true;
			this["event" + eventUrl.url.substr(2, 1) + "_mc"].play();
		}
		
		//翻開華生筆記
		private function openBook(e:Event):void 
		{
			skip_btn.visible = false;
			goCase_mc.go_btn.addEventListener(MouseEvent.CLICK, goCase);
			goCase_mc.gotoAndStop(2);
			goCase_mc.visible = true; 
			playSound("TSC", sound_openBook);
			//if(SingletonValue.getInstance().rest == false) SingletonValue.getInstance().needRest = false;
		}
		//出發到案發現場字卡
		private function goCase(e:MouseEvent):void 
		{
			goCase_mc.go_btn.addEventListener(MouseEvent.CLICK, goChangeSide);
			goCase_mc.gotoAndStop(1);
			goCase_mc.visible = true; 
			stopSound("TSC");
			playSound("TSC", sound_goCase);
			if(SingletonValue.getInstance().rest == false) SingletonValue.getInstance().needRest = false;
		}
		
		//恢復可樂球血量
		private function addHP(e:TimerEvent):void 
		{
			if (SingletonValue.getInstance().hp + 5 < 100) {
				SingletonValue.getInstance().hp += 5;  
				myTime.start();
			} else if (SingletonValue.getInstance().hp + 5 == 100) {
				SingletonValue.getInstance().hp += 5;
				//播放音效  
				playSound("ESC", sound_hp, 0, 1, 1, false);
				HP_mc.light_mc.gotoAndPlay(2); //閃光效果
			}
			HP_mc.gotoAndStop(SingletonValue.getInstance().hp);
		}
		
		//設定按鈕聲音=============================================================
		private function setSound():void {
			playSound("BGSC", sound_bg, 0, 1000);	//背景音樂
			var _n:uint = allBtn.length;
			for (var i:uint = 0; i < _n; i++) {	
				allBtn[i].addEventListener(MouseEvent.MOUSE_OVER, btnPlaySound);
				allBtn[i].addEventListener(MouseEvent.MOUSE_OUT, btnStopSound);
			}
		}
		
		private function btnPlaySound(e:MouseEvent):void 
		{	
			stopSound("TSC");
			scComplete();
			if (e.currentTarget.name == "case0_mc") {
				playSound("BTNSC", sound_case0);
			}else if (e.currentTarget.name == "case1_mc") {
				playSound("BTNSC", sound_case1);
			}else if (e.currentTarget.name == "case2_mc") {
				playSound("BTNSC", sound_case2);
			}else if (e.currentTarget.name == "case3_mc") {
				if (case3_mc.currentFrame == 5) return;
				playSound("BTNSC", sound_case3);
			}else if (e.currentTarget.name == "y_btn") {
				playSound("BTNSC", sound_y);
			}else if (e.currentTarget.name == "n_btn") {
				playSound("BTNSC", sound_n);
			}
		}
		
		private function btnStopSound(e:MouseEvent):void 
		{
			stopSound("BTNSC");
		}
		//設定按鈕聲音============================================================
		
		//跳過華生對話
		private function skipWatson(e:MouseEvent):void 
		{
			skip_btn.removeEventListener(MouseEvent.CLICK, skipWatson);
			stopSound("TSC");
			watson_mc.gotoAndStop(1);
			skip_btn.visible = false;
			stage.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_SHOW, true));
			goCheckRest();
			if (SingletonValue.getInstance().caseNum < 4) {
					this["case" + SingletonValue.getInstance().caseNum + "_mc"].light_mc.visible = true;
					this["case" + SingletonValue.getInstance().caseNum + "_mc"].light_mc.buttonMode = false;
				}
		}
		
		override public function scComplete(e:Event = null):void 
		{	
			if (watson_mc.currentFrame != 1) { //若是華生語音結束就把跳過按鈕隱藏
				skip_btn.visible = false;
				stage.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_SHOW, true));
				if (SingletonValue.getInstance().caseNum < 4 && SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] != 3) {
					this["case" + SingletonValue.getInstance().caseNum + "_mc"].light_mc.visible = true;
				}
				if (SingletonValue.getInstance().unitNum == 4 && SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) { //過關
					SingletonValue.getInstance().caseNum = 4;  //播完過關語音後將目前進行案件改成無
					//繼續挑戰其他案件字卡
					keepOn_mc.visible = true;
					playSound("TSC", sound_keepOn);
					stage.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_HIDE, true));
				}else {
					goCheckRest();
				}
				//解鎖動畫
				if (SingletonValue.getInstance().caseArr[0] == 3 &&
				SingletonValue.getInstance().caseArr[1] == 3 &&
				SingletonValue.getInstance().caseArr[2] == 3 &&
				SingletonValue.getInstance().caseArr[3] == 1) {
					case3_mc.unLock_mc.gotoAndPlay(2);
				}
			}
				
			watson_mc.gotoAndStop(1);
		}
		
		//檢查是否需要顯示休息室窗
		private function goCheckRest():void 
		{	
			//若在華生說話時需要顯示30分鐘休息(rest_mc),就在結束說話後播放
			if (SingletonValue.getInstance().needRest && SingletonValue.getInstance().rest) {
				stage.dispatchEvent(new MainEvent(MainEvent.GO_REST, true));
			}
			SingletonValue.getInstance().needRest = false;
		}
		
		//換場景
		private function goChangeSide(e:MouseEvent):void 
		{
			if (SingletonValue.getInstance().swfPlayList[1] == 1) {
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "G00.swf"));
			}else {
				SingletonValue.getInstance().swfPlayList[1] = 1;
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "G00_G_EX.swf"));
			}
		}
		/*private function firstGoChangeSide(e:MouseEvent):void 
		{
			//如果破關過就不用播主遊戲說明
			if (SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 4) {
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "G00.swf"));
			}else {
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "G00_G_EX.swf"));
			}
		}*/
		
		//暫停
		override public function Pause(e:MainEvent):void { 
			stopSound("TSC");
			stopSound("BTNSC");
			watson_mc.gotoAndStop(1);
		}
		
		//結束暫停
		override public function UnPause(e:MainEvent):void {
		}
		
		//測試模式時用來略過案發動畫
		private function goSkip(e:MouseEvent):void 
		{	
			e.currentTarget.content.dispatchEvent(new Event("finish"));
		}
	}

}