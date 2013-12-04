package As
{
	import As.Events.MainEvent;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Main extends Sprite
	{	//撥放狀態--1:顯示, 2:顯示但可以跳過, 3:不顯示, 4:互動內容
		private var INTO:Array = ["G01_INTO.swf", "G02_INTO.swf", "G03_INTO.swf", "G04_INTO.swf"];				//子遊戲開場動畫_swf
		private var _INTO:Array = [2, 2, 2, 2];																		//播放狀態
		private var QEX:Array = ["G01_Q_EX.swf", "G02_Q_EX.swf", "G03_Q_EX.swf", "G04_Q_EX.swf"];				//題庫說明動畫_swf
		private var _QEX:Array = [2, 2, 2, 2];																		//播放狀態
		private var Q:Array =  ["G01_Q.swf", "G02_Q.swf", "G03_Q.swf", "G04_Q.swf"];							//題庫
		private var GEX:Array = ["G01_G_EX.swf", "G02_G_EX.swf", "G03_G_EX.swf", "G04_G_EX.swf"];				//遊戲說明動畫_swf
		private var _GEX:Array = [2, 2, 2, 2];																		//播放狀態
		private var G:Array = ["G01.swf", "G02.swf", "G03.swf", "G04.swf"];										//遊戲
		private var EVENTS:Array = ["G01_EVENT.swf", "G02_EVENT.swf", "G03_EVENT.swf", "G04_EVENT.swf"];		//案發過程動畫(221B室按下案件按鈕時載入撥放)
		private var allGameSwf:Array = [INTO, QEX, Q, GEX, G, EVENTS];
		private var _allGameSwf:Array = [_INTO, _QEX, null, _GEX];
		private var allUnitTxt:Array = ["INTO", "QEX", "Q", "GEX", "G"];
		private var myLoader:Loader = new Loader();
		private var exLoader:Loader = new Loader();
		private var myUrl:URLRequest = new URLRequest("index.swf");
		private var tempSiteName:String;
		//private var nowUnit:uint; //紀錄目前allGameSwf進行第幾個
		
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
			SingletonValue.getInstance().hp = 100;
			//設定一開始所有案件狀態
			//SingletonValue.getInstance().caseArr = [1, 1, 2, 1];
			//SingletonValue.getInstance().caseNum = 2;
			//======================================以上之後需要改成讀取記錄檔
			stage.addEventListener(MainEvent.CHANGE_SITE, ChangeSide);
			stage.addEventListener(MainEvent.GAME_FINISH, Win);
			stage.addEventListener(MainEvent.LOAD_EX, loadEx);
			stage.addEventListener(MainEvent.EXIT, goExit);
			this.addChild(myLoader);
			this.addChild(toolBar_mc);
			LoadSwf();
			addChild(new Stats());
			
			else_mc.visible = false;
		}
		
		private function goExit(e:MainEvent):void 
		{
			else_mc.gotoAndStop(1);
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
			exLoader.load(myUrl);
			exLoader.addEventListener(MouseEvent.CLICK, unLoadEx);
			this.addChild(exLoader);
			toolBar_mc.gotoAndStop("open");
		}
		private function unLoadEx(e:MouseEvent):void 
		{
			exLoader.unloadAndStop();
			removeChild(exLoader);
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
			}else if(tempSiteName == "GEX") {	//載入子遊戲說明動畫
				SingletonValue.getInstance().unitNum = 3;
				myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, goINTO);
			}else if(tempSiteName == "G") {	//載入子遊戲
				SingletonValue.getInstance().unitNum = 4;
			}
			myUrl = new URLRequest(allGameSwf[SingletonValue.getInstance().unitNum][SingletonValue.getInstance().caseNum]);
			if (tempSiteName.search(".swf") > -1) {  //直接給路徑
				myUrl = new URLRequest(e.ChangeSiteName);
			}
			myLoader.unloadAndStop();
			LoadSwf();
			
			trace("Main: 換場景後: stage.numChildren=", stage.numChildren, "  ///  this.numChildren=" + this.numChildren);
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
			//如果播放狀態是2表示可以點滑鼠跳過
			if (_allGameSwf[SingletonValue.getInstance().unitNum][SingletonValue.getInstance().caseNum] == 2) {
				_mc.addFrameScript(1, function() {
					stage.addEventListener(MouseEvent.CLICK, goNext);
					_mc.addEventListener(Event.REMOVED_FROM_STAGE, kill);
					function goNext(e:MouseEvent):void {
						stage.removeEventListener(MouseEvent.CLICK, goNext);
						stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  allUnitTxt[SingletonValue.getInstance().unitNum+1]));
					}
					function kill(e:Event):void {
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
			
			trace("Main: LoadSwf載入後:", "stage.numChildren:" + stage.numChildren, "this.numChildren:" + this.numChildren);
		}
		
		//過關
		private function Win(e:MainEvent):void {	
			SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] = 3;
			stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "G00.swf"));
		}
		
	}

}