package As
{
	import As.Events.MainEvent;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.net.LocalConnection;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import As.mdm.mdm_As;
	import net.hires.debug.Stats;
	
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
		private var saveDataSharedObject:SharedObject = SharedObject.getLocal("saveData", "/");
		private var userLink:String = "";//資料夾位置.
		private var Folder1:String = "benesse";//記錄檔資料夾名稱
		private var Folder2:String = "2月號尋找福爾摩斯";//記錄檔單元資料夾名稱
		//1.安裝第一層目錄、2.單元名稱、3.功能列表目錄、4.捷徑名稱、5.暫存資料夾第一層目錄
		private var mdm:mdm_As = new mdm_As("巧連智光碟系列\\中年級版",Folder2,"巧連智中年級版\\2月號尋找福爾摩斯","尋找福爾摩斯",Folder1);
		//private var nowMdmAct:String = "";//MDM偵聽功能不夠完整，無法得知complete事件，由此取代
		
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
			this.tabChildren = false;
			SingletonValue.getInstance().allGameSwf = allGameSwf;
			//以下之後需要改成讀取記錄檔======================================
			//設定一開始血量
			//SingletonValue.getInstance().hp = 100;
			//設定一開始所有案件狀態
			SingletonValue.getInstance().caseArr = [3, 3, 3, 2];
			SingletonValue.getInstance().caseNum = 3;
			SingletonValue.getInstance().unitNum = 4;
			//======================================以上之後需要改成讀取記錄檔
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(MainEvent.CHANGE_SITE, ChangeSide);
			stage.addEventListener(MainEvent.GAME_FINISH, Win);
			stage.addEventListener(MainEvent.LOAD_EX, loadEx);
			stage.addEventListener(MainEvent.EXIT, goExit);
			stage.addEventListener(MainEvent.START_NEW, goStartNew);
			stage.addEventListener(MainEvent.SAVE, saveGame);
			stage.addEventListener(MainEvent.GO_REST, startRest);
			myLoader.contentLoaderInfo.addEventListener(Event.OPEN, openHandler);
			myLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			myLoader.contentLoaderInfo.addEventListener(Event.INIT, completeHandler);
			this.addChild(myLoader);
			this.addChild(toolBar_mc);
			//addChild(new Stats());
			
			else_mc.visible = false;
			else_mc.addEventListener("goExitGame", gotoEnd);  	//你真的要離開嗎:選擇是,全過關要再挑戰一次嗎:選不要
			else_mc.addEventListener("goCloseElse", closeElse);	//你真的要離開嗎:選擇否,刪除記錄重新開始嗎:選不要
			else_mc.addEventListener("goAgain", allAgain);		//全過關要再挑戰一次嗎 -> 清除存檔從新開始嗎:選要
			
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, goRest);
			myTime.start();
			rest_mc.visible = false;
			rest_mc.ok_btn.addEventListener(MouseEvent.CLICK, closeRest);
			
			//取得執行程式位置
			if(mdm.getZincPath() != null){
				if( ! mdm.getFileExists( mdm.getZincPath() + "LookingHolmes.exe" ) ){
					userLink = chkInstall();
				}else{
					userLink = mdm.getZincPath();
				}
			}
			SingletonValue.getInstance().userLink = userLink;
			
			loadSave();
			//mdm.showMessage("Main-------:"+String(SingletonValue.getInstance().swfPlayList[0] == 1));
			LoadSwf();
			
		}
		
		//必須取得swf路徑
		private function chkInstall():String{
			//讀取檔案			
			//var windowsPath:String = "c:\\benesse\\";
			var windowsPath:String = mdm.getUserPath() +"\\"+ Folder1 + "\\" +Folder2 + "\\";
			var installPath:String = "";
			//mdm.Dialogs.prompt("keyExists=="+keyExists.toString());
			if ( mdm.getFileExists(windowsPath + "setup.ini") ){
				installPath=mdm.getFileContant(windowsPath + "setup.ini");
			}
			//mdm.showMessage(installPath);
			if (installPath==""){//沒安裝
				installPath = mdm.getZincPath();
				
				//判斷同一層有沒有遊戲執行檔
				if (mdm.getFileExists(installPath + "LookingHolmes.exe")){//使用遊戲執行檔路徑
					installPath = mdm.getZincPath();
				}else{
					//跑光碟的swf
					installPath = mdm.getZincPath() + "bin\\";
				}
				
					
			}else{//有安裝
				installPath = installPath.replace("InstallPath=","");
				installPath = installPath + "巧連智光碟系列\\中年級版\\" + Folder2 + "\\" ;
				//installPath = installPath + "ChilimanProject\\CD201402\\bin" + "\\" ;
				
			}
			
			//mdm.Dialogs.prompt("currPath=="+mdm.Application.path.toString());
			//mdm.Dialogs.prompt("installPath=="+installPath.toString());
			return installPath;
		}
		
		/*//=======================================mdm使用功能=======================================
		//mdm偵聽事件
		public function mdmHandler(e:Event):void{
			switch(e.type){
				case "onComplete":
					mdmOnCompleteAct(nowMdmAct);
					break;
				case "onIOError":
					removeMdm();
					break;
				default:
					break;
			}
		}
		
		//針對偵聽完成事件
		private function mdmOnCompleteAct(act:String = ""):void{
			//移除偵聽
			removeMdm();
			
			//分類事件
			switch( act ){
				case "delete":
					//刪除完成
					mdmGetSaveDataAry();
					//呼叫GX流程結束
					gameMc.VS.swfEnd();
					break;
				case "load":
					//載入完成，開啟GM//目前沒有讀取資料文件的Async
					break;
				case "save":
					//存檔完成，重讀資訊
					mdmGetSaveDataAry();
					break;
				case "kidscool":
					//存檔完成，重讀資訊
					mdmGetSaveDataAry();
					//重新載入GM
					enterGameInit("GM");
					loadOrderAct();
					break;
				default:
					break;
			}
			
		}
		
		//偵聽mdm偵聽功能
		private function addMdm(mdmAct:String):void{
			//偵聽
			mdm.mdmListener(this , "onComplete");
			mdm.mdmListener(this , "onIOError");
			//紀錄mdm執行事件
			nowMdmAct = mdmAct;
		}
		
		
		//移除偵聽mdm偵聽功能
		private function removeMdm():void{
			//移除偵聽
			mdm.mdmRemoveListener(this , "onComplete");
			mdm.mdmRemoveListener(this , "onIOError");
			//清空mdm執行事件
			nowMdmAct = "";
		}
		//=======================================mdm使用功能=======================================*/
		
		//休息一下視窗====================================
		private function closeRest(e:MouseEvent):void 
		{
			rest_mc.visible = false;
			rest_mc.gotoAndStop(1);
			stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			myTime.reset();
			myTime.start();
			SingletonValue.getInstance().rest = false;
		}
		private function goRest(e:TimerEvent):void 
		{
			SingletonValue.getInstance().rest = true;
			if (SingletonValue.getInstance().needRest || rest_mc.visible) return;
			//如果有載入說明動畫(使用者自己按的)就關掉
			exLoader.unloadAndStop();
			//若在播放說明動畫時就先不顯示,等播放完,載入下一個場景再顯示(goCheckRest)
			if (SingletonValue.getInstance().nowSiteName == "221B_EX.swf" ||
				SingletonValue.getInstance().nowSiteName == "G00_G_EX.swf" ||
				SingletonValue.getInstance().nowSiteName == "GEX" ||
				SingletonValue.getInstance().nowSiteName == "QEX") {
					SingletonValue.getInstance().needRest = true;
			}else {	
				startRest();
			}
		}
		private function startRest(e:MainEvent = null):void {
			addChild(rest_mc);
			rest_mc.play();
			rest_mc.visible = true;
			stage.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
			SingletonValue.getInstance().needRest = false;
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
			myUrl.url = userLink + myUrl.url;
			exLoader.load(myUrl);
			exLoader.addEventListener(MouseEvent.CLICK, unLoadEx);
			this.addChild(exLoader);
			this.setChildIndex(stageMask_mc, this.numChildren - 1);
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
			if (myUrl.url == userLink + "G00_G_EX.swf" ||　myUrl.url == userLink + "221B.swf") return;
			//若在播放說明動畫時需要顯示30分鐘休息(rest_mc),就在結束說明動畫後播放
			if (SingletonValue.getInstance().needRest) {	
				startRest();
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
			/*if (SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3 || 
			SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 4) {*/
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
			//}
		}
		
		//載入swf
		private function LoadSwf():void
		{
			trace("Main: LoadSw載入前:", "stage.numChildren:" + stage.numChildren, "this.numChildren:" + this.numChildren);
			//myLoader.load(new URLRequest(userLink + "loading.swf"));
			//主選單顯示狀態--播放動畫跟答題庫時不顯示主選單
			if(myUrl.url == "221B.swf" || myUrl.url == "G00.swf"){
				toolBar_mc.visible = true;
			}else if (SingletonValue.getInstance().unitNum == 0 || 
				SingletonValue.getInstance().unitNum == 1 || 
				SingletonValue.getInstance().unitNum == 2 || 
				SingletonValue.getInstance().unitNum == 3 || 
				SingletonValue.getInstance().unitNum == 5 ||
				myUrl.url == "index.swf" || myUrl.url == "indexMV.swf" || myUrl.url == "OpenSave.swf") {
				toolBar_mc.gotoAndStop("open");
				toolBar_mc.visible = false;
			}else {
				toolBar_mc.visible = true;
			}
			myUrl.url = userLink + myUrl.url;
			//mdm.showMessage("myUrl.url:"+myUrl.url);
			myLoader.load(myUrl);
			this.setChildIndex(stageMask_mc, this.numChildren - 1);
			
			trace("Main: LoadSwf載入後:", "stage.numChildren:" + stage.numChildren, "this.numChildren:" + this.numChildren, "SingletonValue.getInstance().nowSiteName:" + SingletonValue.getInstance().nowSiteName);
		}
		
		//顯示載入進度
		private function openHandler(e:Event):void 
		{
			this.setChildIndex(loading_mc, this.numChildren - 1);
			loading_mc.bar_mc.gotoAndStop(1);
			loading_mc.visible = true;
		}
		private function progressHandler(e:ProgressEvent):void 
		{
			var bl:int = myLoader.contentLoaderInfo.bytesLoaded;
			var bt:int = myLoader.contentLoaderInfo.bytesTotal;
			var percent:Number = bl / bt;
			loading_mc.bar_mc.gotoAndStop(int(percent*100));
		}
		private function completeHandler(e:Event):void 
		{
			loading_mc.bar_mc.gotoAndStop(100);
			loading_mc.visible = false;
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
				/*SingletonValue.getInstance().hp = saveDataSharedObject.data.hp;
				SingletonValue.getInstance().caseNum = saveDataSharedObject.data.caseNum;
				SingletonValue.getInstance().unitNum = saveDataSharedObject.data.unitNum;
				SingletonValue.getInstance().caseArr = saveDataSharedObject.data.caseArr;
				SingletonValue.getInstance().nowSiteName = saveDataSharedObject.data.nowSiteName;
				SingletonValue.getInstance().beforeSiteName = saveDataSharedObject.data.beforeSiteName;
				SingletonValue.getInstance().swfPlayList = saveDataSharedObject.data.swfPlayList;*/
				loadSave();
				stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "221B.swf"));
			}else if (SingletonValue.getInstance().caseNum == 3 && 
			SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) {  //如果是第四關而且破關了
				stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "221B.swf"));
			}else {  //你真的要離開嗎:選擇否
				stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			}
		}
		//全過關要再挑戰一次嗎:選要 -> 清除存檔從新開始嗎:選要
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
			SingletonValue.getInstance().firstOpenCase3 = true;
			//SingletonValue.getInstance().swfPlayList = [0,0];
			stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "221B_EX.swf"));
			saveGame();
		}
		
		//進入遊戲是否要讀取存檔:選重新開始新遊戲
		private function goStartNew(e:MainEvent):void 
		{
			else_mc.gotoAndPlay(396); //刪除紀錄重新開始???
			this.addChild(else_mc);
			else_mc.visible = true;
		}
		
		private function saveGame(e:MainEvent = null):void {
			/*saveDataSharedObject.data.hp = SingletonValue.getInstance().hp;
			saveDataSharedObject.data.caseNum = SingletonValue.getInstance().caseNum;
			saveDataSharedObject.data.unitNum = SingletonValue.getInstance().unitNum;
			saveDataSharedObject.data.caseArr = SingletonValue.getInstance().caseArr;
			saveDataSharedObject.data.nowSiteName = SingletonValue.getInstance().nowSiteName;
			saveDataSharedObject.data.beforeSiteName = SingletonValue.getInstance().beforeSiteName;
			saveDataSharedObject.data.swfPlayList = SingletonValue.getInstance().swfPlayList;
			saveDataSharedObject.flush();	//存入SharedObject*/
			
			//取得使用者暫存位置
			var tmpPath:String = mdm.getUserPath();
			
			//建立資料夾，不論有無都做，沒有才會執行建立動作
			mdm.mkDir(tmpPath + "\\" + Folder1 );//第一層 benesse 資料夾
			mdm.mkDir(tmpPath + "\\" + Folder1 + "\\" + Folder2 );//第二層 單元名稱 資料夾
			
			//依使用者年級取得路徑
			var tmpFile:String = "lookingHolmes.ini";
			var filePath:String = tmpPath + "\\" + Folder1 + "\\" + Folder2 + "\\" + tmpFile;
			var txtContant:String = '';
			//把存檔資料轉成字串	
			txtContant = SingletonValue.getInstance().hp + "@";
			txtContant += SingletonValue.getInstance().caseNum + "@";
			txtContant += SingletonValue.getInstance().unitNum + "@";
			var _a = SingletonValue.getInstance().caseArr;
			txtContant += _a[0] + "?" + _a[1] + "?" + _a[2] + "?" + _a[3] + "@";
			txtContant += SingletonValue.getInstance().nowSiteName + "@";
			txtContant += SingletonValue.getInstance().beforeSiteName + "@";
			_a = SingletonValue.getInstance().swfPlayList;
			txtContant += _a[0] + "?" + _a[1] + "@";
			txtContant += String(SingletonValue.getInstance().firstOpenCase3);
			
			//寫入文件
			mdm.saveFileContant(filePath , txtContant);
		}
		
		//載入進度
		private function loadSave():void {
			//取得使用者暫存位置
			var tmpPath:String = mdm.getUserPath();
			var tmpFile:String = "lookingHolmes.ini";
			//取得紀錄路徑
			var filePath:String = tmpPath + "\\" + Folder1 + "\\" + Folder2 + "\\" + tmpFile;
			var Contant:String = '';
			//紀錄是否存在
			if( mdm.getFileExists(filePath) ){
				//存在時
				Contant = mdm.getFileContant(filePath);//取得字串
				//mdm.showMessage("===========loadSave:" + Contant);
				var passAry = Contant.split("@");//切割成陣列
				SingletonValue.getInstance().hp = passAry[0];
				SingletonValue.getInstance().caseNum =  passAry[1];
				SingletonValue.getInstance().unitNum =  passAry[2];
				var _a = passAry[3].split("?"); 
				//字串產生的Array裡的值都是字串,所以要轉成int
				SingletonValue.getInstance().caseArr = [int(_a[0]), int(_a[1]), int(_a[2]), int(_a[3])];
				SingletonValue.getInstance().nowSiteName =  passAry[4];
				SingletonValue.getInstance().beforeSiteName =  passAry[5];
				_a = passAry[6].split("?");
				SingletonValue.getInstance().swfPlayList = [int(_a[0]), int(_a[1])];
				if (passAry[7] == "true") {
					SingletonValue.getInstance().firstOpenCase3 = true;
				}else {
					SingletonValue.getInstance().firstOpenCase3 = false;
				}
				
				//mdm.showMessage("===========loadSave:" + String(SingletonValue.getInstance().firstOpenCase3)+passAry[7]);
			}
		}
	}

}