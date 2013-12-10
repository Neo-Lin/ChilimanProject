package As
{
	import As.Events.MainEvent;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import mdm.Dialogs;
	import net.hires.debug.Stats;
	import mdm.Application;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Main extends Sprite
	{	//撥放狀態--1:顯示, 2:顯示但可以跳過, 3:不顯示, 4:互動內容
		private var INTO:Array = ["G01_INTO.swf", "G02_INTO.swf", "G03_INTO.swf", "G04_INTO.swf"];				//子遊戲開場動畫_swf
		//private var _INTO:Array = [2, 2, 2, 2];																		//播放狀態
		private var QEX:Array = ["G01_Q_EX.swf", "G02_Q_EX.swf", "G03_Q_EX.swf", "G04_Q_EX.swf"];				//題庫說明動畫_swf
		//private var _QEX:Array = [2, 2, 2, 2];																		//播放狀態
		private var Q:Array =  ["G01_Q.swf", "G02_Q.swf", "G03_Q.swf", "G04_Q.swf"];							//題庫
		private var GEX:Array = ["G01_G_EX.swf", "G02_G_EX.swf", "G03_G_EX.swf", "G04_G_EX.swf"];				//遊戲說明動畫_swf
		//private var _GEX:Array = [2, 2, 2, 2];																		//播放狀態
		private var G:Array = ["G01.swf", "G02.swf", "G03.swf", "G04.swf"];										//遊戲
		private var EVENTS:Array = ["G01_EVENT.swf", "G02_EVENT.swf", "G03_EVENT.swf", "G04_EVENT.swf"];		//案發過程動畫(221B室按下案件按鈕時載入撥放)
		private var allGameSwf:Array = [INTO, QEX, Q, GEX, G, EVENTS];
		//private var _allGameSwf:Array = [_INTO, _QEX, null, _GEX];
		private var allUnitTxt:Array = ["INTO", "QEX", "Q", "GEX", "G"];
		private var myLoader:Loader = new Loader();
		private var exLoader:Loader = new Loader();
		private var myUrl:URLRequest = new URLRequest("index.swf");
		private var tempSiteName:String;
		private var myTime:Timer = new Timer(60000, 30);
		//private var myTime:Timer = new Timer(6000, 1);
		//private var nowUnit:uint; //紀錄目前allGameSwf進行第幾個
		private var needRest:Boolean = false; //紀錄是否需要跳出休息室窗
		private var saveDataSharedObject:SharedObject = SharedObject.getLocal("saveData", "/");
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			SingletonValue.getInstance().allGameSwf = allGameSwf;
			//以下之後需要改成讀取記錄檔======================================
			//設定一開始血量
			//SingletonValue.getInstance().hp = 100;
			//設定一開始所有案件狀態
			//SingletonValue.getInstance().caseArr = [1, 1, 2, 1];
			//SingletonValue.getInstance().caseNum = 2;
			//======================================以上之後需要改成讀取記錄檔
			stage.addEventListener(MainEvent.CHANGE_SITE, ChangeSide);
			stage.addEventListener(MainEvent.GAME_FINISH, Win);
			stage.addEventListener(MainEvent.LOAD_EX, loadEx);
			stage.addEventListener(MainEvent.EXIT, goExit);
			stage.addEventListener(MainEvent.START_NEW, goStartNew);
			this.addChild(myLoader);
			this.addChild(toolBar_mc);
			LoadSwf();
			//addChild(new Stats());
			
			else_mc.visible = false;
			else_mc.addEventListener("goExitGame", gotoEnd);  	//你真的要離開嗎:選擇是,全過關要再挑戰一次嗎:選不要
			else_mc.addEventListener("goCloseElse", closeElse);	//你真的要離開嗎:選擇否,刪除記錄重新開始嗎:選不要
			else_mc.addEventListener("goAgain", allAgain);		//全過關要再挑戰一次嗎 -> 清除存檔從新開始嗎:選要
			
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, goRest);
			myTime.start();
			rest_mc.visible = false;
			rest_mc.ok_btn.addEventListener(MouseEvent.CLICK, closeRest);
			
			mdm.Application.init();
			Dialogs.prompt("Hello World!");
			mdm.Application.exit();
		}
		
		//休息一下視窗====================================
		private function closeRest(e:MouseEvent):void 
		{
			rest_mc.visible = false;
			rest_mc.gotoAndStop(1);
			stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			myTime.reset();
			myTime.start();
		}
		private function goRest(e:TimerEvent):void 
		{
			//如果有載入說明動畫(使用者自己按的)就關掉
			exLoader.unloadAndStop();
			//若在播放說明動畫時就先不顯示,等播放完,載入下一個場景再顯示(goCheckRest)
			if (SingletonValue.getInstance().nowSiteName == "221B_EX.swf" ||
				SingletonValue.getInstance().nowSiteName == "G00_G_EX.swf" ||
				SingletonValue.getInstance().nowSiteName == "GEX" ||
				SingletonValue.getInstance().nowSiteName == "QEX") {
					needRest = true;
			}else {
				startRest();
			}
		}
		private function startRest():void {
			addChild(rest_mc);
			rest_mc.play();
			rest_mc.visible = true;
			stage.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
		}
		//====================================休息一下視窗
		
		private function goExit(e:MainEvent):void 
		{
			else_mc.gotoAndPlay(2);
			this.addChild(else_mc);
			else_mc.visible = true;
		}
		
		//主選單的遊戲說明功能
		private function loadEx(e:MainEvent):void 
		{
			if (e.ChangeSiteName.search(".swf") > -1) {  //直接給路徑
				myUrl = new URLRequest(e.ChangeSiteName);
			}else if (e.ChangeSiteName == "QEX") {
				myUrl = new URLRequest(allGameSwf[1][SingletonValue.getInstance().caseNum]);
			}else if (e.ChangeSiteName == "GEX") {
				myUrl = new URLRequest(allGameSwf[3][SingletonValue.getInstance().caseNum]);
			}
			exLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, exLoaderAddScript);
			exLoader.load(myUrl);
			exLoader.addEventListener(MouseEvent.CLICK, unLoadEx);
			this.addChild(exLoader);
			toolBar_mc.gotoAndStop("open");
		}
		private function exLoaderAddScript(e:Event):void 
		{
			exLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, exLoaderAddScript);
			var _mc:MovieClip = e.currentTarget.content as MovieClip;
			_mc.addEventListener("exLoaderFinish", closeExLoader);
			//221B_EX跟G00_G_EX的影格上有載入下一個場景的程式碼,如果是按主選單載入的話,就要取代掉.
			//其他雖然沒有影格程式碼,但也要知道說明播放完畢
			_mc.addFrameScript(_mc.totalFrames-1, function() {
				_mc.dispatchEvent(new Event("exLoaderFinish"));
				_mc.stop();
			});
		}
		private function closeExLoader(e:Event = null):void 
		{
			exLoader.unloadAndStop();
			removeChild(exLoader);
			stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
		}
		private function unLoadEx(e:MouseEvent):void 
		{
			closeExLoader();
		}
		
		//換場景
		private function ChangeSide(e:MainEvent):void
		{
			trace("Main: 換場景前: stage.numChildren=", stage.numChildren, "  ///  this.numChildren=" + this.numChildren);
			trace("Main: ", e.currentTarget, e.target);
			
			tempSiteName = e.ChangeSiteName;
			if (tempSiteName == "INTO") {  //載入子遊戲開場動畫
				SingletonValue.getInstance().unitNum = 0;
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, goINTO);
			}else if(tempSiteName == "QEX") {	//載入題庫說明動畫
				SingletonValue.getInstance().unitNum = 1;
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, goINTO);
			}else if(tempSiteName == "Q") {	//載入題庫
				SingletonValue.getInstance().unitNum = 2;
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, goCheckRest);
			}else if(tempSiteName == "GEX") {	//載入子遊戲說明動畫
				SingletonValue.getInstance().unitNum = 3;
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, goINTO);
			}else if(tempSiteName == "G") {	//載入子遊戲
				SingletonValue.getInstance().unitNum = 4;
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, goCheckRest);
			}
			myUrl = new URLRequest(allGameSwf[SingletonValue.getInstance().unitNum][SingletonValue.getInstance().caseNum]);
			if (tempSiteName.search(".swf") > -1) {  //直接給路徑
				myUrl = new URLRequest(e.ChangeSiteName);
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, goCheckRest);
			}
			myLoader.unloadAndStop();
			LoadSwf();
			
			trace("Main: 換場景後: stage.numChildren=", stage.numChildren, "  ///  this.numChildren=" + this.numChildren);
		}
		
		//檢查是否需要顯示休息室窗
		private function goCheckRest(e:Event):void 
		{
			//若在播放說明動畫時需要顯示30分鐘休息(rest_mc),就在結束說明動畫後播放
			if (needRest) {
				startRest();
				needRest = false;
			}
		}
		
		private function goINTO(e:Event):void 
		{
			myLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, goINTO);
			var _mc:MovieClip = e.currentTarget.content as MovieClip;
			//在最後一個影格加程式碼,讓動畫播完可以自動載入下一個swf
			if(tempSiteName == "INTO") {  //載入子遊戲開場動畫
				_mc.addFrameScript(_mc.totalFrames - 1, function() {
					stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "QEX"));
				});
			}else if(tempSiteName == "QEX") {	//載入題庫說明動畫
				_mc.addFrameScript(_mc.totalFrames-1, function() {
					stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "Q"));
				});
			}else if(tempSiteName == "GEX") {	//載入遊戲說明動畫
				_mc.addFrameScript(_mc.totalFrames-1, function() {
					stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "G"));
				});
			}
			//如果案件狀態是3(破案)或4(再玩一次)就可以點滑鼠跳過
			if (SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3 || 
			SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 4) {
				_mc.addFrameScript(1, function() {
					stage.addEventListener(MouseEvent.CLICK, goNext);
					_mc.addEventListener(Event.REMOVED_FROM_STAGE, kill);
					function goNext(e:MouseEvent):void {
						stage.removeEventListener(MouseEvent.CLICK, goNext);
						stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  allUnitTxt[SingletonValue.getInstance().unitNum+1]));
					}
					function kill(e:Event):void {
						_mc.removeEventListener(Event.REMOVED_FROM_STAGE, kill);
						stage.removeEventListener(MouseEvent.CLICK, goNext);
					}
				});
			}
		}
		
		//載入swf
		private function LoadSwf():void
		{
			trace("Main: LoadSw載入前:", "stage.numChildren:" + stage.numChildren, "this.numChildren:" + this.numChildren);
			
			//主選單顯示狀態--播放動畫時不顯示主選單
			if(myUrl.url == "221B.swf" || myUrl.url == "G00.swf"){
				toolBar_mc.visible = true;
			}else if (SingletonValue.getInstance().unitNum == 0 || 
				SingletonValue.getInstance().unitNum == 1 || 
				SingletonValue.getInstance().unitNum == 3 || 
				SingletonValue.getInstance().unitNum == 5) {
				toolBar_mc.gotoAndStop("open");
				toolBar_mc.visible = false;
			}else {
				toolBar_mc.visible = true;
			}
			myLoader.load(myUrl);
			
			trace("Main: LoadSwf載入後:", "stage.numChildren:" + stage.numChildren, "this.numChildren:" + this.numChildren, "SingletonValue.getInstance().nowSiteName:" + SingletonValue.getInstance().nowSiteName);
		}
		
		//過關
		private function Win(e:MainEvent):void {	
			SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] = 3;
			if (SingletonValue.getInstance().caseNum == 3) { //如果是G04就表示全破了
				else_mc.gotoAndStop(598); //送可樂豆畫面
				this.addChild(else_mc);
				else_mc.visible = true;
			}else {
				stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "G00.swf"));
			}
			saveGame();
		}
		
		//else_mc偵聽事件
		//你真的要離開嗎:選擇是,全過關要再挑戰一次嗎:選不要
		private function gotoEnd(e:Event):void 
		{
			saveGame();
			//播放片尾名單
		}
		//你真的要離開嗎:選擇否,刪除記錄重新開始嗎:選不要
		private function closeElse(e:Event):void 
		{
			else_mc.visible = false;
			else_mc.gotoAndStop(1);
			stage.focus = stage;
			if (SingletonValue.getInstance().nowSiteName == "OpenSave.swf") {  //OpenSave.swf"選重新開始新遊戲" -> 刪除記錄重新開始嗎:選不要
				SingletonValue.getInstance().hp = saveDataSharedObject.data.hp;
				SingletonValue.getInstance().caseNum = saveDataSharedObject.data.caseNum;
				SingletonValue.getInstance().unitNum = saveDataSharedObject.data.unitNum;
				SingletonValue.getInstance().caseArr = saveDataSharedObject.data.caseArr;
				SingletonValue.getInstance().nowSiteName = saveDataSharedObject.data.nowSiteName;
				SingletonValue.getInstance().beforeSiteName = saveDataSharedObject.data.beforeSiteName;
				stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "221B.swf"));
			}else if (SingletonValue.getInstance().caseNum == 3 && 
			SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) {  //如果是第四關而且破關了
				stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "221B.swf"));
			}else {  //你真的要離開嗎:選擇否
				stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			}
		}
		//全過關要再挑戰一次嗎 -> 清除存檔從新開始嗎:選要
		private function allAgain(e:Event):void 
		{
			else_mc.visible = false;
			else_mc.gotoAndStop(1);
			stage.focus = stage;
			SingletonValue.getInstance().hp = 100;
			SingletonValue.getInstance().caseNum = 4;
			SingletonValue.getInstance().unitNum = 5;
			SingletonValue.getInstance().caseArr = [1,1,1,1];
			SingletonValue.getInstance().nowSiteName = "";
			SingletonValue.getInstance().beforeSiteName = "";
			stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "221B_EX.swf"));
		}
		
		//進入遊戲是否要讀取存檔:選重新開始新遊戲
		private function goStartNew(e:MainEvent):void 
		{
			else_mc.gotoAndPlay(396); //刪除紀錄重新開始???
			this.addChild(else_mc);
			else_mc.visible = true;
		}
		
		private function saveGame():void {
			saveDataSharedObject.data.hp = SingletonValue.getInstance().hp;
			saveDataSharedObject.data.caseNum = SingletonValue.getInstance().caseNum;
			saveDataSharedObject.data.unitNum = SingletonValue.getInstance().unitNum;
			saveDataSharedObject.data.caseArr = SingletonValue.getInstance().caseArr;
			saveDataSharedObject.data.nowSiteName = SingletonValue.getInstance().nowSiteName;
			saveDataSharedObject.data.beforeSiteName = SingletonValue.getInstance().beforeSiteName;
			saveDataSharedObject.flush();	//存入SharedObject
		}
	}

}