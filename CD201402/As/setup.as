package As
{

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextFormat;

	import As.mdm.mdm_As;
	import flash.text.TextFieldAutoSize;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.events.TimerEvent;




	public class setup extends MovieClip
	{


		//===================文件路徑相關變數================

		var Folder1:String = "benesse";//記錄檔資料夾名稱
		var Folder2:String = "2月號尋找福爾摩斯";//記錄檔單元資料夾名稱

		//===================文件路徑相關變數================

		//1.安裝第一層目錄、2.單元名稱、3.功能列表目錄、4.捷徑名稱、5.暫存資料夾第一層目錄
		//var mdm:mdm_As = new mdm_As("巧連智光碟系列\\低年級版",Folder2,"巧連智低年級版\\5月號前進神祕島","前進神祕島",Folder1);
		var mdm:mdm_As = new mdm_As("巧連智光碟系列\\中年級版",Folder2,"巧連智中年級版\\2月號尋找福爾摩斯","尋找福爾摩斯",Folder1);

		var driveAry:Array;//可用硬碟陣列
		var copyAry:Array;//複製檔案陣列

		var setupRoot:String = "";//記錄使用者挑選的安裝根目錄

		var setupPercent:int;//安裝進度百分比

		var totalSize:Number = 0;//總共要複製檔案的大小:位元組 bytes
		var copySize:Number = 0;//已經複製的檔案大小

		var tarPath:String = "巧連智光碟系列\\中年級版\\2月號尋找福爾摩斯\\";
		
		var delay:Timer = new Timer(200,1);

		var i:int,j:int;
		
		var o:int = 0;
		
		var Snd:Sound;
		var SC:SoundChannel;
		
		var gamePath:String;//遊戲開啟位置 
		var openGame:Boolean = false;

		/////////////////////////////////////////////////////////////////

		//文字格式
		private var brownFormat:TextFormat = new TextFormat();
		private var redFormat:TextFormat = new TextFormat();
		private var blueFormat:TextFormat = new TextFormat();

		/////////////////////////////////////////////////////////////////


		public function setup()
		{
			// constructor code
			this.stop();
			this.addEventListener(Event.ADDED_TO_STAGE , init);
		}

		//初始化設定
		private function init(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE , init);

			//偵聽按鈕
			addInitBtn(btn_setup);
			addInitBtn(btn_playDisk);
			addInitBtn(btn_leave);

			//字顏色
			brownFormat.color = 0x663300;
			redFormat.color = 0xff0000;
			blueFormat.color = 0x0000ff;
			
			//Mc_loading.visible = false;
			//this.addEventListener(Event.ENTER_FRAME , prevLoad);
			
			mdm.showMessage("path:" + mdm.getZincPath());
		}
		
		/*private function prevLoad(e:Event):void{
			o ++ ;
			if(Mc_loading != null && o > 2){
				//this.removeEventListener(Event.ENTER_FRAME , prevLoad);
				if(o == 3){
					mdm.getFileSize(mdm.getZincPath() + "\\Data\\MysteryIsland.exe");
				}
				if(o == 4){
					this.removeEventListener(Event.ENTER_FRAME , prevLoad);
					mdm.getFileSize(mdm.getZincPath() + "\\Data\\English.exe");
					Mc_loading.visible = false;
					o = 0;
				}
			}
		}*/

		//====================================按鈕=====================================
		//按鈕事件
		private function btnHandler(e:MouseEvent):void
		{
			var Mc:MovieClip;
			switch (e.type)
			{
				case "click" :
					switch (e.currentTarget.name)
					{
						case "btn_setup" :
							//初始安裝程序
							setupInit();
							break;
						case "btn_playDisk" :
							//執行遊戲Exe
							var tmpPath:String = mdm.getZincPath() + "bin\\" ; // play.exe;
							//mdm.runFile(tmpPath);
							
							//關閉視窗
							//mdm.closeWindow();
							
							//進入遊戲選單
							//this.gotoAndStop(4);
							init_play_menu(tmpPath);
							EnterGame("LookingHolmes");
							break;
						case "btn_leave" :
							//關閉視窗
							mdm.closeWindow();
							break;
						case "btn_confirm" :
							//進行安裝
							setupTest();
							break;
						case "Mc_drive0" :
							driveBtn_init();
							Mc = e.currentTarget as MovieClip;
							Mc.gotoAndStop(2);
							Mc.txt.txt.setTextFormat(blueFormat);
							removeDriveBtn(Mc);
							break;
						case "Mc_drive1" :
							driveBtn_init();
							Mc = e.currentTarget as MovieClip;
							Mc.gotoAndStop(2);
							Mc.txt.txt.setTextFormat(blueFormat);
							removeDriveBtn(Mc);
							break;
						default :
							break;
					}
					break;
				case "mouseOver" :
					stopChannel(SC);
					
					switch (e.currentTarget.name)
					{
						case "btn_setup" :
							Snd = new snd_btn();
							SC = Snd.play(1,1);
							break;
						case "btn_playDisk" :
							Snd = new snd_btn();
							SC = Snd.play(1,1);
							break;
						case "btn_leave" :
							Snd = new snd_btn();
							SC = Snd.play(1,1);
							break;
						case "btn_confirm" :
							Snd = new snd_confirm();
							SC = Snd.play(1,1);
							break;
						case "Mc_drive0" :
							Mc = e.currentTarget as MovieClip;
							Snd = new snd_btn();
							SC = Snd.play(1,1);
							MovieClip_set(Mc.btn , 2);
							Mc_drive0.txt.txt.setTextFormat(redFormat);
							break;
						case "Mc_drive1" :
							Mc = e.currentTarget as MovieClip;
							Snd = new snd_btn();
							SC = Snd.play(1,1);
							MovieClip_set(Mc.btn , 2);
							Mc_drive1.txt.txt.setTextFormat(redFormat);
							break;
						default :
							break;
					}
					break;
				case "mouseOut" :
					stopChannel(SC);
					switch (e.currentTarget.name)
					{
						case "btn_setup" :
							break;
						case "btn_playDisk" :
							break;
						case "btn_leave" :
							break;
						case "btn_confirm" :
							break;
						case "Mc_drive0" :
							Mc = e.currentTarget as MovieClip;
							MovieClip_set(Mc.btn , 1);
							Mc_drive0.txt.txt.setTextFormat(brownFormat);
							break;
						case "Mc_drive1" :
							Mc = e.currentTarget as MovieClip;
							MovieClip_set(Mc.btn , 1);
							Mc_drive1.txt.txt.setTextFormat(brownFormat);
							break;
						default :
							break;
					}
					break;
				case "mouseDown" :
					Mc = e.currentTarget as MovieClip;
					setupRoot = String(Mc.id).toLocaleUpperCase() + ":\\";
					Mc.txt.txt.setTextFormat(redFormat);
					MovieClip_set(Mc.btn , 3);
					break;
				case "mouseUp" :
					
					break;
				default :
					break;
			}
		}

		//偵聽初始按鈕
		private function addInitBtn(Mc):void
		{
			if (! Mc.hasEventListener(MouseEvent.CLICK))
			{
				Mc.addEventListener(MouseEvent.CLICK , btnHandler);
			}
			if (! Mc.hasEventListener(MouseEvent.MOUSE_OVER))
			{
				Mc.addEventListener(MouseEvent.MOUSE_OVER , btnHandler);
			}
			if (! Mc.hasEventListener(MouseEvent.MOUSE_OUT))
			{
				Mc.addEventListener(MouseEvent.MOUSE_OUT , btnHandler);
			}
		}

		//移除偵聽初始按鈕
		private function removeInitBtn(Mc):void
		{
			if (Mc.hasEventListener(MouseEvent.CLICK))
			{
				Mc.removeEventListener(MouseEvent.CLICK , btnHandler);
			}
			if (Mc.hasEventListener(MouseEvent.MOUSE_OVER))
			{
				Mc.removeEventListener(MouseEvent.MOUSE_OVER , btnHandler);
			}
			if (Mc.hasEventListener(MouseEvent.MOUSE_OUT))
			{
				Mc.removeEventListener(MouseEvent.MOUSE_OUT , btnHandler);
			}
		}

		//偵聽drive按鈕
		private function addDriveBtn(Mc):void
		{
			
			if (! Mc.hasEventListener(MouseEvent.CLICK))
			{
				Mc.addEventListener(MouseEvent.CLICK , btnHandler);
			}
			if (! Mc.hasEventListener(MouseEvent.MOUSE_DOWN))
			{
				Mc.addEventListener(MouseEvent.MOUSE_DOWN , btnHandler);
			}
			if (! Mc.hasEventListener(MouseEvent.MOUSE_UP))
			{
				Mc.addEventListener(MouseEvent.MOUSE_UP , btnHandler);
			}
			if (! Mc.hasEventListener(MouseEvent.MOUSE_OVER))
			{
				Mc.addEventListener(MouseEvent.MOUSE_OVER , btnHandler);
			}
			if (! Mc.hasEventListener(MouseEvent.MOUSE_OUT))
			{
				Mc.addEventListener(MouseEvent.MOUSE_OUT , btnHandler);
			}
		}

		//移除偵聽初始按鈕
		private function removeDriveBtn(Mc):void
		{
			
			if (Mc.hasEventListener(MouseEvent.CLICK))
			{
				Mc.removeEventListener(MouseEvent.CLICK , btnHandler);
			}
			if (Mc.hasEventListener(MouseEvent.MOUSE_DOWN))
			{
				Mc.removeEventListener(MouseEvent.MOUSE_DOWN , btnHandler);
			}
			if (Mc.hasEventListener(MouseEvent.MOUSE_UP))
			{
				Mc.removeEventListener(MouseEvent.MOUSE_UP , btnHandler);
			}
			if (Mc.hasEventListener(MouseEvent.MOUSE_OVER))
			{
				Mc.removeEventListener(MouseEvent.MOUSE_OVER , btnHandler);
			}
			if (Mc.hasEventListener(MouseEvent.MOUSE_OUT))
			{
				Mc.removeEventListener(MouseEvent.MOUSE_OUT , btnHandler);
			}
		}
		
		//====================================按鈕=====================================

		//====================================安裝=====================================
		//選擇安裝後初始需要的資料
		private function setupInit():void
		{
			//警告提示
			if (mdm.getOsversion() == "win7" && ! mdm.isAdmin())
			{
				mdm.showMessage("系統偵測到您不是以系統管理者的身分執行安裝程式，安裝過程可能會出現問題。\n請使用系統管理員的身分執行安裝!");
			}
			//移除偵聽按鈕
			removeInitBtn(btn_setup);
			removeInitBtn(btn_playDisk);
			removeInitBtn(btn_leave);

			//找尋可用磁碟機
			driveAry = mdm.scanDrive();



			//前往安裝影格
			this.gotoAndStop(2);

			//偵聽確定按鈕
			addInitBtn(btn_confirm);
			
			//初始deive按鈕
			driveBtn_init();
			
			//預設C槽
			driveBtn_init();
			Mc_drive0.gotoAndStop(2);
			Mc_drive0.txt.txt.setTextFormat(blueFormat);
			setupRoot = String(Mc_drive0.id).toLocaleUpperCase() + ":\\";
			removeDriveBtn(Mc_drive0);

		}
		
		//初始選擇Drive按鈕
		private function driveBtn_init():void{
			//隱藏所有drive元件
			setDriveObj(false,"0");
			this["Mc_drive0"].gotoAndStop(1);
			setDriveObj(false,"1");
			this["Mc_drive1"].gotoAndStop(1);

			//填入drive資料;
			for (i = 0; i < driveAry.length; i ++)
			{
				var tmpMc:MovieClip = this["Mc_drive" + i];

				//設定drive文字
				tmpMc.id = driveAry[i]["drive"];
				tmpMc.txt.txt.text = driveAry[i]["drive"].toString().toUpperCase() + ":\\還剩下" + driveAry[i]["free"] + "MB空間";
				tmpMc.txt.txt.autoSize = TextFieldAutoSize.LEFT;
				//tmpMc.txt.mouseEnabled = false;
				
				//btn改成影片片段元件
				 MovieClip_set(tmpMc.btn,1);
				 MovieClip_set(tmpMc , 1 , true , true);
				//偵聽按鈕事件
				addDriveBtn(tmpMc);

				//顯示物件
				setDriveObj(true,String(i));

			}
		}

		//木板和繩索物件
		private function setDriveObj(Show:Boolean , idStr:String):void
		{
			this["Mc_drive" + idStr].visible = Show;
		}

		//按下確定，判斷進行安裝動作
		private function setupTest():void
		{
			//先判斷是否有選擇磁碟
			if ( setupRoot != "")
			{
				//有選擇
				//判斷磁碟空間是否足夠
				if(mdm.testFreeSize(setupRoot)){
					//空間足夠
					//mdm.showMessage(copyAry.toString());
					//設置安裝路徑
					tarPath = setupRoot + tarPath;
					//前往初始安裝影格
					setupAct();
				}else{
					//空間不足
					mdm.showMessage("磁碟空間不足，請重新選擇安裝磁碟機!");
				}
					
			}
			else
			{
				//無選擇
				//秀訊息
				mdm.showMessage("請先選擇要安裝的磁碟機!");
			}
		}

		//安裝動作啟用
		private function setupAct():void
		{
			//移除偵聽

			//偵聽確定按鈕
			removeInitBtn(btn_confirm);

			for (i = 0; i < driveAry.length; i ++)
			{
				var tmpMc:MovieClip = this["Mc_drive" + i];
				//移除偵聽按鈕事件
				removeDriveBtn(tmpMc);
			}


			//前往安裝進度影格
			this.gotoAndStop(3);
			
			//初始進度Bar
			Mc_bar.gotoAndStop(1);
			txt.text = "0%";
			
			//先等200毫秒，初始完畫面在複製檔案
			delay.addEventListener(TimerEvent.TIMER , copyAct_Init);
			delay.start();
			
			

		}
		//初始複製檔案
		private function copyAct_Init(e:TimerEvent):void{
			delay.removeEventListener(TimerEvent.TIMER , copyAct_Init);
			//取得複製檔案陣列
			copyAry = mdm.getCopyAry(setupRoot);
			
			var tmpStr:String = "";
			//迴圈++取得totalSize
			for (i = 0; i < copyAry.length; i ++)
			{
				totalSize = totalSize + Number(copyAry[i][3]);
				if( i != (copyAry.length - 1)){
					tmpStr = tmpStr + "['" + copyAry[i][0] + "','" + copyAry[i][1] +"','" + copyAry[i][2] + "'," + copyAry[i][3] + "],";
				}else{
					tmpStr = tmpStr + "['" + copyAry[i][0] + "','" + copyAry[i][1] + "','" + copyAry[i][2] + "'," + copyAry[i][3] + "]";
				}
			}
			totalSize = copyAry.length;
			//copyTxt.text = tmpStr;
			//偵聽mdm
			mdm.mdmListener(this,"onComplete");
			mdm.mdmListener(this,"onIOError");
			//複製檔案開始
			mdm.copyFileAsync(copyAry[0][0]  + copyAry[0][2] , copyAry[0][1]  + copyAry[0][2]);
			
			//mdm.showMessage("開始複製檔案");
		}

		//複製複製複製檔案的迴圈,每次複製完成檔案時動作
		private function copyWhile():void
		{
			//已複製檔案SIZE;
			//copySize = copySize + copyAry[0][3];
			copySize ++;

			setupPercent = int(copySize / totalSize * 100);
			//mdm.showMessage(String(copySize+"/")+String(totalSize+"*100=")+String(setupPercent));

			//進度條
			if (setupPercent <= 0)
			{
				Mc_bar.gotoAndStop(1);
			}
			else
			{
				Mc_bar.gotoAndStop(setupPercent);
			}

			txt.text = setupPercent + "%";


			//設定成不是唯讀
			mdm.setFileAttribs(copyAry[0][1]+copyAry[0][2], "-R");



			//刪除第一個
			copyAry.splice(0,1);

			//如果還有，就再次執行複製
			if (copyAry.length > 0)
			{
				//複製檔案
				mdm.copyFileAsync( copyAry[0][0] + "\\" + copyAry[0][2] , copyAry[0][1] + "\\" + copyAry[0][2] );
			}
			else
			{
				//移除偵聽mdm
				mdm.mdmRemoveListener(this,"onComplete");
				mdm.mdmRemoveListener(this,"onIOError");
				//檔案複製完要做的事情
				//捷徑、安裝文件、移除文件等等
				mdm.end_copyFile(tarPath , setupRoot );
				
				
				//建移除文件資料夾
				mdm.mkDir(mdm.getUserPath() +"\\"+ Folder1);
				mdm.mkDir(mdm.getUserPath() +"\\"+ Folder1 + "\\" +Folder2);
				//紀錄文件路徑
				var windowsPath:String = mdm.getUserPath() +"\\"+ Folder1 + "\\" +Folder2 + "\\"
				
				//mdm.showMessage(windowsPath)
				//偵聽mdm
				mdm.mdmListener(this,"onComplete");
				mdm.mdmListener(this,"onIOError");
				//寫移除用文字檔
				mdm.saveFileContant(windowsPath + "setup.ini", "InstallPath="+setupRoot);
				//執行遊戲
				//mdm.showMessage(tmpPath);
				//mdm.runFile(tmpPath);

				//關閉視窗
				//mdm.closeWindow();
				
				
			}
		}

		//====================================安裝=====================================

		//=======================================mdm偵聽使用功能=======================================

		//mdm偵聽事件
		public function mdmHandler(e:Event):void
		{
			switch (e.type)
			{
				case "onComplete" :
					onCompleteAct();
					break;
				case "onIOError" :
					//複製檔案出錯
					mdm.showMessage("Error To Copy");
					mdm.showMessage(copyAry[0][0]+"\\"+copyAry[0][2]);
					mdm.showMessage(copyAry[0][1]+"\\"+copyAry[0][2]);
					break;
				default :
					break;
			}
		}
		
		//MDMComplete動作
		private function onCompleteAct():void{
			if (copyAry.length > 0){
				copyWhile();
			}else{
				//建立第一次安裝遊戲開啟路徑
				var tmpPath:String = tarPath //+ "play.exe";
				
				//進入遊戲選單
				//this.gotoAndStop(4);
				init_play_menu(tmpPath);
				EnterGame("LookingHolmes");
				
				//移除偵聽mdm
				mdm.mdmRemoveListener(this,"onComplete");
				mdm.mdmRemoveListener(this,"onIOError");
			}
		}


		//=======================================mdm偵聽使用功能=======================================
		
		
		
		//=======================================結合最外層選單==================================================
		
		
		var BGSnd:Sound;//背景音樂
		var BGSC:SoundChannel;//背景音樂
		var TSnd:Sound;//語音
		var TSC:SoundChannel;//語音
		
		var menuPath:String;//區別安裝執行及光碟執行
		
		//初始化設定
		private function init_play_menu(str:String):void{

			//初始偵聽按鈕
			//addBtn(btn_LookingHolmes);
			//addBtn(btn_English);
			
			//Play開啟遊戲路徑
			menuPath = str;
			//mdm.showMessage(mdm.getOpenPath());
		}
		
		
		
		//====================================進入遊戲功能=====================================
		
		//進入遊戲
		private function EnterGame(gameName:String):void{
			
			//指定遊戲路徑
			gamePath = menuPath + gameName + ".exe";
			//Mc_loading.visible = true;
			mdm.showMessage("gamePath:\n" + gamePath);
			mdm.showMessage(menuPath);
			mdm.showMessage(gameName);
			//避免畫面出不來，使用影格
			this.addEventListener(Event.ENTER_FRAME ,delayClose);
			
		}
		
		
		private function delayClose(e:Event):void{
			o ++ ;
			if(o==2){
				//開啟指定遊戲.exe
				if(mdm.getFileExists(gamePath) && !openGame){
					openGame = true;
					mdm.runFile(gamePath);
				}
			}else if(o>4){
				this.removeEventListener(Event.ENTER_FRAME ,delayClose);
				//關閉自己
				mdm.closeWindow();
			}
		}
		
		
		//====================================進入遊戲功能=====================================
		
		
		
		
		//====================================按鈕功能=====================================
		
		//按鈕事件
		private function btnHandler_menu(e:MouseEvent):void{
			var mcName:String = e.currentTarget.name.substr(4);//去除掉btn_
			switch(e.type){
				case "click":
					stopChannel(TSC);
					switch(mcName){
						case "LookingHolmes":
							removeBtn(e.currentTarget);
							EnterGame(mcName);
							
							break;
						case "English":
							removeBtn(e.currentTarget);
							EnterGame(mcName);
							
							break;
						default:
							break;
					}
					break;
				case "mouseOver":
					stopChannel(TSC);
					switch(mcName){
						case "MysteryIsland":
							startChannel( "snd_"+mcName);
							break;
						case "English":
							startChannel( "snd_"+mcName);
							break;
						default:
							break;
					}
					break;
				case "mouseOut":
					stopChannel(TSC);
					break;
				case "mouseDown":
					break;
				case "mouseUp":
					break;
				default:
					break;
			}
		}
		
		
		//選單按鈕功能
		private function addBtn(Mc):void{
			if( ! Mc.hasEventListener(MouseEvent.CLICK)){
				Mc.addEventListener(MouseEvent.CLICK , btnHandler_menu);
			}
			if( ! Mc.hasEventListener(MouseEvent.MOUSE_OVER)){
				Mc.addEventListener(MouseEvent.MOUSE_OVER , btnHandler_menu);
			}
			if( ! Mc.hasEventListener(MouseEvent.MOUSE_OUT)){
				Mc.addEventListener(MouseEvent.MOUSE_OUT , btnHandler_menu);
			}
			if( ! Mc.hasEventListener(MouseEvent.MOUSE_DOWN)){
				Mc.addEventListener(MouseEvent.MOUSE_DOWN , btnHandler_menu);
			}
			if( ! Mc.hasEventListener(MouseEvent.MOUSE_UP)){
				Mc.addEventListener(MouseEvent.MOUSE_UP , btnHandler_menu);
			}
			
		}
		
		private function removeBtn(Mc):void{
			if( Mc.hasEventListener(MouseEvent.CLICK)){
				Mc.removeEventListener(MouseEvent.CLICK , btnHandler_menu);
			}
			if( Mc.hasEventListener(MouseEvent.MOUSE_OVER)){
				Mc.removeEventListener(MouseEvent.MOUSE_OVER , btnHandler_menu);
			}
			if( Mc.hasEventListener(MouseEvent.MOUSE_OUT)){
				Mc.removeEventListener(MouseEvent.MOUSE_OUT , btnHandler_menu);
			}
			if( Mc.hasEventListener(MouseEvent.MOUSE_DOWN)){
				Mc.removeEventListener(MouseEvent.MOUSE_DOWN , btnHandler_menu);
			}
			if( Mc.hasEventListener(MouseEvent.MOUSE_UP)){
				Mc.removeEventListener(MouseEvent.MOUSE_UP , btnHandler_menu);
			}
			
		}
		
		//====================================按鈕功能=====================================
		
		//=================================語音功能========================================
		
		
		//語音結束時動作
		private function soundPlayEnd(e:Event):void{
			//移除偵聽
			e.currentTarget.removeEventListener( e.type , soundPlayEnd );
		}
		
		//語音開始並偵聽結束
		private function startChannel( str:String , loop:int = 1){
			//結束當前正在撥放的語音
			stopChannel(TSC);
			//取得要撥放的語音
			var tmpClass:Class = getDefinitionByName(str) as Class;
			TSnd = new tmpClass();
			//播放
			TSC = TSnd.play(1,loop);
			//偵聽結束
			TSC.addEventListener(Event.SOUND_COMPLETE , soundPlayEnd);
			
		}
		
		//音樂面板停止
		private function stopChannel(sc:SoundChannel){
			if(sc != null){
				sc.stop();
				if(sc.hasEventListener(Event.SOUND_COMPLETE) ){
					sc.removeEventListener(Event.SOUND_COMPLETE , soundPlayEnd);
				}
				sc = null;
			}
		}
		
		
		//=================================語音功能========================================
		
		//=================================其它功能========================================
		
		
		//陣列迴圈,陣列內容須為指標，Ary = 指定陣列 ,Fcn = 執行Function , val1 , val2 , val3 最多可放額外三個指定參數
		private function Ary_while(Ary:Array , Fcn:Function , val1 = null, val2 = null, val3 = null ):void{
			for( i = 0 ; i < Ary.length ; i ++ ){
				switch(true){
					case val3 != null : 
						Fcn(Ary[i] , val1 , val2 , val3);
						break;
					case val2 != null : 
						Fcn(Ary[i] , val1 , val2 );
						break;
					case val1 != null : 
						Fcn(Ary[i] , val1 );
						break;
					default:
						Fcn(Ary[i] );
						break;
				}
				
			}
		}
		
		
		
		
		//設置影片片段
		private function MovieClip_set(Mc:MovieClip ,Frame:int = 1, Show:Boolean = true , btnMode:Boolean = false):void{
			
			//Frame
			Mc.gotoAndStop(Frame);
			
			//visible
			Mc.visible = Show;
			
			//buttonMode
			Mc.buttonMode = btnMode;
			
		}
		
		
		//=================================其它功能========================================

	}

}

/*
mdm_As功能看這裡~
//名稱//參數//回傳值//註解
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
showMessage(str:String = ""):void顯示視窗訊息
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
getFileContant(path:String):String取得文件內容
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
getFileExists(path:String):Boolean取得指定路徑檔案是否存在
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
saveFileContant(path:String , str:String):void儲存文件內容
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
getForm(str:String):UIComponent取得Zinc視窗名稱
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
isAdmin():Boolean取得是否為系統管理員
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
getZincPath():String取得Zinc所在位置
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
getUserPath():String取得使用者暫存所在位置
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
getOsversion():String取得使用者windows版本 ->回傳只有XP win7 other;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
scanDrive():Array取得有容量的磁碟機 ->回傳只有字母較前面的兩個磁碟機;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
runFile(str:String):void開啟檔案
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
closeWindow():void關閉視窗
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
copyFileAsync(srcPath ,tarPath ):void複製檔案 > 貼上
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
setFileAttribs(Path:String , str:String):void指定文件屬性 ->詳細參閱mdm_As中註解
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
getCopyAry(setupRoot:String = ""):Array取得指定資料夾目標的所有檔案陣列 ->含要到達的路徑
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
end_copyFile(tarPath:String , setupRoot:String ):void移動檔案完畢後，建立捷徑等等事項
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
mkDir(pPath):void若目標資料夾不存在，建立資料夾。
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
mdmListener(Main:MovieClip,str:String):void偵聽mdm ->目前只有onComplete , onIOError
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
mdmRemoveListener(Main:MovieClip,str:String):void移除偵聽mdm ->目前只有onComplete , onIOError
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
*/