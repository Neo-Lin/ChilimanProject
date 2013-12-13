package As.mdm {
/*****************************************************************************************
'		撰寫人員：CheinYu
'		撰寫日期：20120830
'		程式功能：巧連智 / 12月光碟 / 整合 / Setup
'		使用參數：None
'		資　　料：
'		修改人員：
'		修改日期：
'		註　　解：需使用到MDM功能的功能集中在一起，方便以後製作不需從頭看起。
				  偵聽動作特殊處理；無法不載入mdm而進行mdm偵聽功能，故加入參數movieClip,使完成動作時，執行指定MovieClip的Function。
*****************************************************************************************/
	import mdm.*;
	import flash.display.MovieClip;//特別為偵聽功能import;
	//import fl.core.UIComponent;
	

	public class mdm_As{
		
		///共用
		public var windows_firstLayer:String = "";//使用者系統快取資料夾第一層目錄
		public var installPath:String="";//讀取安裝位置
		public var fixPath_firstLayer:String = "";//第一層目錄
		public var fixPath_secondLayer:String = "";//光碟單元名稱
		public var fixPath:String = "";//區分版本使用路徑
		public var fix_shortCutLayer:String = "";//開始功能列使用路徑名稱
		public var fix_shortCutName:String = "";//捷徑使用名稱
		public var windowsFolder:String = "";//使用者系統快取資料夾名稱
		public var windowsPath:String = "";//使用者系統快取資料夾路徑
		
		
		private var fileExist:Boolean;//取得指定路徑檔案是否存在
		private var folderExist:Boolean;//取得指定路徑資料夾是否存在
		
		private var i,j,k:int = 0;
		
		
		//private var AllSwfAry:Array = [['','','5月號英語學習單元.ico',123580],['','','English.exe',8522390],['','','MysteryIsland.exe',9600552],['','','uninstall.exe',7383378],['','','uninstall_excute.exe',7444897],['','','前進神祕島.ico',121846],['Swf','Swf','E00_desc.swf',388406],['Swf','Swf','E00_game.swf',478770],['Swf','Swf','E01_ani1.swf',886835],['Swf','Swf','E01_desc.swf',245517],['Swf','Swf','E01_game1.swf',470003],['Swf','Swf','E01_story1.swf',731078],['Swf','Swf','E01_story2.swf',57456],['Swf','Swf','E02_ani1.swf',410625],['Swf','Swf','E02_ani2.swf',826591],['Swf','Swf','E02_desc.swf',383350],['Swf','Swf','E02_game1.swf',716934],['Swf','Swf','E02_game2.swf',716933],['Swf','Swf','E02_game3.swf',716934],['Swf','Swf','E02_story1.swf',228649],['Swf','Swf','E02_story2.swf',433687],['Swf','Swf','E02_story3.swf',732226],['Swf','Swf','E02_story4.swf',63823],['Swf','Swf','EEND_game.swf',154848],['Swf','Swf','ET01_game.swf',173823],['Swf','Swf','ET02_game.swf',155330],['Swf','Swf','EX_leave.swf',144154],['Swf','Swf','E_toolbar.swf',207822],['Swf','Swf','G01_ani1.swf',1688352],['Swf','Swf','G01_desc.swf',189349],['Swf','Swf','G01_game.swf',416723],['Swf','Swf','G02_desc.swf',922768],['Swf','Swf','G02_game.swf',654251],['Swf','Swf','G02_qdesc.swf',249234],['Swf','Swf','G02_qdesc2.swf',241832],['Swf','Swf','G02_ques.swf',883223],['Swf','Swf','G03_ani1.swf',1183900],['Swf','Swf','G04_desc.swf',426354],['Swf','Swf','G04_game.swf',841576],['Swf','Swf','G04_qdesc.swf',329558],['Swf','Swf','G04_qdesc2.swf',329558],['Swf','Swf','G04_ques.swf',771643],['Swf','Swf','G05_ani1.swf',2508825],['Swf','Swf','G05_desc.swf',1020621],['Swf','Swf','G05_game.swf',1164195],['Swf','Swf','G06_desc.swf',241019],['Swf','Swf','G06_game.swf',763198],['Swf','Swf','G06_qdesc.swf',153897],['Swf','Swf','G06_qdesc2.swf',153897],['Swf','Swf','G06_ques.swf',787194],['Swf','Swf','G07_ani1.swf',568221],['Swf','Swf','G07_desc.swf',231661],['Swf','Swf','G07_game.swf',480300],['Swf','Swf','G08_desc.swf',355885],['Swf','Swf','G08_game.swf',721012],['Swf','Swf','G08_qdesc.swf',384883],['Swf','Swf','G08_qdesc2.swf',363342],['Swf','Swf','G08_ques.swf',1010929],['Swf','Swf','G09_ani1.swf',683964],['Swf','Swf','G09_desc.swf',288283],['Swf','Swf','G09_game.swf',304670],['Swf','Swf','G10_ani2.swf',2783955],['Swf','Swf','G10_desc.swf',376255],['Swf','Swf','G10_game.swf',1372455],['Swf','Swf','G10_qdesc.swf',144600],['Swf','Swf','G10_qdesc2.swf',139892],['Swf','Swf','G10_ques.swf',961884],['Swf','Swf','GC_change.swf',108513],['Swf','Swf','GM_desc.swf',543279],['Swf','Swf','GM_game.swf',1659122],['Swf','Swf','GQ_desc.swf',348696],['Swf','Swf','GQ_game.swf',651665],['Swf','Swf','GX_exit.swf',580978],['Swf','Swf','loading.swf',13684],['Swf','Swf','Tip_other.swf',346419],['Swf','Swf','toolbar.swf',106099]];
		private var AllSwfAry:Array = [['', '', 'LookingHolmes.exe', 8867211], ['', '', 'Looking Holmes.ico', 152456], ['', '', '221B.swf', 3731707], ['', '', '221B_EX.swf', 872756], ['', '', 'G00.swf', 4734055], ['', '', 'G00_G_EX.swf', 1364443], ['', '', 'index.swf', 299089], ['', '', 'indexMV.swf', 1886879], ['', '', 'OpenSave.swf', 198886], 
		['', '', 'G01.swf', ], ['', '', 'G01_EVENT.swf', ], ['', '', 'G01_G_EX.swf', ], ['', '', 'G01_INTO.swf', ], ['', '', 'G01_Q.swf', ], ['', '', 'G01_Q_EX.swf', ],
		['', '', 'G02.swf', ], ['', '', 'G02_EVENT.swf', ], ['', '', 'G02_G_EX.swf', ], ['', '', 'G02_INTO.swf', ], ['', '', 'G02_Q.swf', ], ['', '', 'G02_Q_EX.swf', ],
		['', '', 'G03.swf', ], ['', '', 'G03_EVENT.swf', ], ['', '', 'G03_G_EX.swf', ], ['', '', 'G03_INTO.swf', ], ['', '', 'G03_Q.swf', ], ['', '', 'G03_Q_EX.swf', ],
		['', '', 'G04.swf', ], ['', '', 'G04_EVENT.swf', ], ['', '', 'G04_G_EX.swf', ], ['', '', 'G04_INTO.swf', ], ['', '', 'G04_Q.swf', ], ['', '', 'G04_Q_EX.swf', ],
		['','','uninstall.exe',],['','','uninstall_excute.exe',]
		/*['','','',],['','','',],['','','',],['','','',],['','','',],['','','',],['','','',],['','','',],['','','',],['','','',]*/];
		
		
		//	fLayer = 第一層目錄 subject = 單元名稱 scLayer = 開始功能列使用的路徑 scName = 捷徑的名稱 wLayer = 暫存資料夾名稱
		public function mdm_As(fLayer:String = "",subject:String = "",scLayer:String = "",scName:String = "",wLayer:String = "") {
			// constructor code
			fixPath_firstLayer = fLayer ;
			fixPath_secondLayer = subject ;
			fix_shortCutLayer = scLayer ;
			fix_shortCutName = scName ;
			windowsFolder = wLayer;
			loaded();
		}
		//初始設定
		private function loaded():void{
			initValue();
			mdm.Application.addEventListener("onFormClose", formCloseAct);
		}
		//關閉視窗
		private function formCloseAct(e:Event):void{
			mdm.Application.exit();
		}
		
		//初始取得資訊
		private function initValue():void{
			mdm.Application.init();//使用MDM必須
			windows_firstLayer = mdm.System.Paths.personal + "\\" + windowsFolder +"\\";
			windowsPath = mdm.System.Paths.personal + "\\" + windowsFolder +"\\"+ fixPath_secondLayer+"\\";
			fixPath = fixPath_firstLayer +"\\"+ fixPath_secondLayer+"\\";
			fileExist = false;
			folderExist = false;
		}
		
		
		/*----------------------------------------較單純的MDM功能----------------------------------------------*/
		
		//=======================================顯示訊息使用功能=======================================
		//顯示視窗訊息給使用者
		public function showMessage(str:String = ""):void{
			mdm.Dialogs.prompt(str);//指定訊息
		}
		
		//=======================================存取文件使用功能=======================================
		
		//取得指定路徑文件內容
		public function getFileContant(path:String):String{
			return mdm.FileSystem.loadFile(path);
		}
		
		//儲存指定路徑文件內容 path=路徑&名稱 str=儲存內容(全部)
		public function saveFileContant(path:String , str:String):void{
			mdm.FileSystem.saveFile( path , "");
			mdm.FileSystem.appendFileAsync( path , str);
		}
		
		//取得指定路徑檔案是否存在
		public function getFileExists(path:String ):Boolean{
			return mdm.FileSystem.fileExists(path);
		}
		
		//=====================================取得系統資訊使用功能=====================================
		
		
		//取得使用者是否為管理員
		public function isAdmin():Boolean{
			return mdm.System.isAdmin;
		}
		
		
		//取得.zinc所在位置
		public function getZincPath():String{
			return mdm.Application.path;
		}
		
		//取得使用者暫存檔案位置
		public function getUserPath():String{
			return mdm.System.Paths.personal;
		}
		
		//取得檔案大小
		public function getFileSize(path:String):int{
			return mdm.FileSystem.getFileSize(path);//bytes
		}
		
		
		
		
		//取得使用者Windows版本
		public function getOsversion():String{
			var myVersion:String = mdm.System.verString;
			var osVersion:String = mdm.System.verStringDetail;			
			
			if (osVersion.indexOf("XP")>=0){//判斷是否有XP字樣
				return "XP";
			}else if (myVersion.indexOf("6.")>=0){//vista OR win 7
				return "win7";
			}
			return "other";
		}
		
		
		//找尋可用磁碟機
		public function scanDrive():Array{
			var DriveAry:Array=["c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"];//所有磁碟機
			var canDriveAry:Array = new Array();//記錄有空間的磁碟
			//將有空間的磁碟記錄起來
			for (i=0;i< DriveAry.length;i++){
				var getFreeSpace:Number = mdm.System.getFreeSpace(DriveAry[i]);//取得容量
				//mdm.Dialogs.prompt(getFreeSpace.toString());
				if (getFreeSpace>0){
					if (canDriveAry.length<2){//只記錄前兩個
						canDriveAry.push({drive:DriveAry[i],free:Math.floor(getFreeSpace/1024)});
					}else{
						break;
					}
				} 
			}
			return canDriveAry;
		}
		
		
		//=======================================使用系統功能=======================================
		
		//開啟檔案exe.doc.jpg想到的應該都打得開 限用Windows和Mac。
		public function runFile(str:String):void{
			mdm.System.exec(str);//指定檔案路徑名稱
		}
		
		//關閉視窗
		public function closeWindow():void{
			mdm.Application.exit();
		}
		
		//複製移動檔案，參數srcPath來源路徑，tarPath移動路徑，需加上//+檔案名稱;
		public function copyFileAsync(srcPath ,tarPath ):void{
			mdm.FileSystem.copyFileAsync( srcPath , tarPath );
		}
		
		//設置檔案格式 參數Path:為指定檔案，str:指定格式
		//設置檔案格式 +A設置存檔屬性 +H設置隱藏屬性 +R設置只讀屬性 +S設置系統屬性 -A會取消存檔屬性 -H會取消隱藏屬性 -R可清除只讀屬性 -S系統屬性會取消
		public function setFileAttribs(Path:String , str:String):void{
			mdm.FileSystem.setFileAttribs(Path , str);
		}
		
		//刪除指定文件，或資料夾
		public function deleteFile( Path:String , type:String = "file"):void{
			switch( type ){
				case "file":
					//檔案
					mdm.FileSystem.deleteFileAsync(Path);
					break;
				case "folder":
					//文件
					mdm.FileSystem.deleteFolderAsync(Path, "noask");
					break;
			}
		}
		
		//設置mdm系統視窗顯示及初始隱藏 str:mdm的視窗命名 , act:執行動作 close=關閉 show=顯示 hide=隱藏
		public function setForm(str:String , act:String ):void{
			//取得指定的系統視窗
			var tmpForm = mdm.Forms.getFormByName(str);
			switch(act){
				case "close":
					tmpForm.close();
					break;
				case "show":
					tmpForm.show();
					break;
				case "hide":
					tmpForm.goToFrame(1);
					tmpForm.hide();
					break;
				default:
					break;
			}
		}
		
		
		
		/*----------------------------------------複雜的MDM功能----------------------------------------------*///Ex:光碟安裝較複雜的行程。
		
		//=======================================安裝光碟使用功能=======================================
		
		
		//判斷硬碟空間是否足夠
		public function testFreeSize(Drive:String):Boolean{
			
			var srcPath:String = mdm.Application.path.replace("\\\\","\\") + "Data\\";//要被複製的路徑

			//總共要複製檔案的大小
			var totSize:int = mdm.FileSystem.getFolderSize(srcPath); //in KB.
			var totSize_MB:int = int(totSize / 1024);//(KB to MB)

			//判斷目的地的磁碟大小是否夠用
			var tarDrive = Drive.substring(0,1);
			var freeSpace:Number = int(mdm.System.getFreeSpace(tarDrive));

			if (totSize_MB > freeSpace){
				return false;
			}
			return true;
		}
		
		
		
		//取得複製檔案陣列，內容包含檔案路徑、移動路徑、檔案名稱、檔案大小
		public function getCopyAry(setupRoot:String = ""):Array{
			
			var tarPath:String = setupRoot + fixPath;//安裝的路徑
				
			//以該路徑為根目錄，將來源檔案依照資料夾一個一個複製
			var srcPath:String = mdm.Application.path.replace("\\\\","\\") + "bin\\";//要被複製的路徑
			
			//直接先建立好最上層資料夾與單元資料夾
			mkDir(setupRoot + fixPath_firstLayer );
			mkDir(setupRoot + fixPath_firstLayer + "\\" + fixPath_secondLayer );
			
			
			//設置複製路徑
			var tmpInt:int =  AllSwfAry.length;
			for( var i = 0 ; i < tmpInt ; i ++ ){
				AllSwfAry[i][0] = srcPath + AllSwfAry[i][0] + "\\"
				AllSwfAry[i][1] = tarPath + AllSwfAry[i][1] + "\\"
			}
			
			//掃描來源資料夾,將資訊寫入copyFileAry <<<<<//改成tmpCopyAry ,由外部檔案取得Ary在執行複製動作		Yu 20120831
			var tmpCopyAry:Array = new Array();
			
			getCopyFile( srcPath , tarPath , tmpCopyAry );
			
			//return tmpCopyAry;
			return AllSwfAry;

		}
		
		//檔案複製完要做的事情
		public function end_copyFile(tarPath:String , setupRoot:String ):void{
			
			//建桌面捷徑
				var appPath:String = tarPath + "LookingHolmes.exe"; //目標
				var appFolder:String = tarPath;//開始位置
				var shortcutText:String = fix_shortCutName;//註解
				//var iconPath:String = mdm.Application.path + mdm.Application.filename;//ICON路徑--使用目前執行檔
				var iconPath:String = tarPath + "Looking Holmes.ico";//ICON路徑--使用目前執行檔
				var iconRes:Number = 0;//使用第幾個ICON
				
				
				//英文的
				/*var E_appPath:String = tarPath + "English.exe"; //目標
				var E_appFolder:String = tarPath;//開始位置
				var E_shortcutText:String = "5月號英語學習單元";//註解
				var E_iconPath:String = tarPath + "5月號英語學習單元.ico";//ICON路徑--使用目前執行檔
				var E_iconRes:Number = 0;//使用第幾個ICON*/
			
				//建立捷徑之前要確定目標檔存在，否則會無法建立
				var tmpPath:String = mdm.System.Paths.desktop;
				var shortcutLink:String = tmpPath+"\\"+fix_shortCutName+".lnk";
				mdm.FileSystem.createShortcut(appPath, appFolder, shortcutText, iconPath, iconRes, shortcutLink);
				
			
				/*var E_shortcutLink:String = tmpPath+"\\"+"5月號英語學習單元"+".lnk";
				mdm.FileSystem.createShortcut(E_appPath, E_appFolder, E_shortcutText, E_iconPath, E_iconRes, E_shortcutLink);*/
					
					
			//建開始功能表
				var StartMenuPath:String;
				if (mdm.System.isAdmin){
					StartMenuPath = mdm.System.Paths.allUsersPrograms;
				}else{
					StartMenuPath = mdm.System.Paths.programs;
				}
					
				StartMenuPath = StartMenuPath +"\\"+ fix_shortCutLayer;
				mkDir(StartMenuPath);
				   //複製桌面捷徑到開始功能表
				mdm.FileSystem.copyFile(shortcutLink, StartMenuPath+"\\"+fix_shortCutName+".lnk");
				//mdm.FileSystem.copyFile(E_shortcutLink, StartMenuPath+"\\"+"5月號英語學習單元"+".lnk");
				//建立移除執行檔的捷徑
				appPath = tarPath + "uninstall.exe"; //目標
				shortcutText = "移除"+fix_shortCutName;//註解
				shortcutLink = StartMenuPath+"\\移除"+fix_shortCutName+".lnk";
				mdm.FileSystem.createShortcut(appPath, appFolder, shortcutText, iconPath, iconRes, shortcutLink);
				
		}

		
		///傳入路徑，偵測資料夾是否存在，建立該路徑的資料夾。
		public function mkDir(pPath):void
		{
			if (pPath == "")
			{
				return;
			}

			var pathAry:Array = pPath.split("\\");
			var tPath = "";

			for (i=0; i<pathAry.length; i++)
			{
				if (tPath == "")
				{
					tPath = pathAry[i];
				}
				else
				{
					tPath = tPath + "\\" + pathAry[i];

				}
				if (! mdm.FileSystem.folderExists(tPath))
				{
					mdm.FileSystem.makeFolder(tPath);
				}
			}
		}
		
		
		
		/*---------------------------------------------MDM偵聽功能----------------------------------------------*/
		//Ex:固定執行指定MovieClip的mdmHeader
		//依據Event.Type字串區別偵聽回傳類型
		
		//=======================================新增移除偵聽功能=======================================
		
		//mdm偵聽程式，參數Main載入執行function的物件；str:偵聽的功能。
		public function mdmListener(Main:MovieClip,str:String):void{
			switch(str){
				case "onComplete":
					mdm.FileSystem.addEventListener("onComplete", Main.mdmHandler);
					break;
				case "onIOError":
					mdm.FileSystem.addEventListener("onIOError", Main.mdmHandler);
					break;
				default:
					break;
			}
		}
		
		//mdm移除偵聽程式，參數Main載入執行function的物件；str:偵聽的功能。
		public function mdmRemoveListener(Main:MovieClip,str:String):void{
			switch(str){
				case "onComplete":
					mdm.FileSystem.removeEventListener("onComplete", Main.mdmHandler);
					break;
				case "onIOError":
					mdm.FileSystem.removeEventListener("onIOError", Main.mdmHandler);
					break;
				default:
					break;
			}
		}
		
		
		
		
		
		
		//=======================================私用功能，不提供其他AS呼叫=======================================
		
		
		//增加迴圈查找指定資料夾內所有資料夾，並建立資料夾，使用於取得複製檔案陣列				//Yu,20120831
		private function getCopyFile(srcPath:String,tarPath:String,Ary:Array):void{
			//showMessage(srcPath)
			//掃描來源資料夾,將資訊寫入copyFileAry
			//1.先掃檔案//用預先抓好的檔案名稱
			//addFileToCopyAry(srcPath,tarPath,Ary);
			//2.掃描資料夾
			var srcFolders:Array = mdm.FileSystem.getFolderList(srcPath);
			if(srcFolders.length > 0){
				for (i = 0; i < srcFolders.length; i++ ){
					//取得該資料夾//怪異現象，使用mkDir後，srcFolders[i]會變成空白的。
					var tmpStr:String = srcFolders[i];
					mkDir(tarPath + tmpStr);//依搜尋到的子資料建立資料夾;
					
					var tmpSrcPath = srcPath + tmpStr + "\\";
					var tmpTarPath = tarPath + tmpStr + "\\";
					
					
					//用子路徑迴圈執行此function，##如果沒資料就會停止迴圈##
					getCopyFile(tmpSrcPath,tmpTarPath,Ary);
				}
			}
		}
		
		
		//將要COPY的檔案加入陣列--傳入路徑
		private function addFileToCopyAry(pSrcPath:String,pTarPath:String,pAry:Array):void{
			//取得資料夾內所有檔案
			var tmpFiles:Array = mdm.FileSystem.getFileList(pSrcPath,"*.*");
			for (var i=0; i<tmpFiles.length; i++){
				var tmpSize:Number = mdm.FileSystem.getFileSize(pSrcPath + tmpFiles[i]);//bytes
				//var tmpSize:Number = AllSwfAry[i][3];
				var tmpAry=new Array();
				tmpAry.push(pSrcPath);
				//from;
				tmpAry.push(pTarPath);
				//to;
				tmpAry.push(tmpFiles[i]);
				//fileName;
				tmpAry.push(tmpSize);
				//fileSize;

				pAry.push(tmpAry);
			}
		}
	}
}
