package As
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.text.TextField;
	import flash.media.*;
	import mdm.*;
	
	public class uninstall_excute extends MovieClip
	{
		private var installPath:String="";//讀取安裝位置

		private var fixPath_firstLayer:String = "巧連智光碟系列\\中年級版";//第一層目錄
		private var fixPath_secondLayer:String = "2月號尋找福爾摩斯";//第二層目錄
		private var fixPath:String = fixPath_firstLayer+"\\"+fixPath_secondLayer+"\\";

		private var fix_shortCutLayer:String = "巧連智中年級版\\2月號尋找福爾摩斯";//名稱
		private var fix_shortCutName:String = "尋找福爾摩斯";//名稱

		
		//聲音區
		private var btnSnd:Sound;
		private var btnSndChl:SoundChannel;

		private var btnVoiceSnd:Sound;
		private var btnVoiceSndChl:SoundChannel;

		//記錄有那些磁碟機可以安裝
		private var canDriveAry:Array=[];

		private var hasAdminPrivilages:Boolean;
		private var myVersion:String;//WINDOWS 版本號
		private var osVersion:String;//WINDOWS 詳細版本資訊
		
		private var currOS:String;//紀錄目前版本
		
		
		public function uninstall_excute()
		{
			mdm.Application.init();
			
			btnOK.addEventListener(MouseEvent.ROLL_OVER,btnEvent);
			btnOK.addEventListener(MouseEvent.ROLL_OUT,btnEvent);
			btnOK.addEventListener(MouseEvent.CLICK,closeMe);
			
			ininForm();
		
			//初始畫面
			do_Uninstall();

			
			mdm.Application.addEventListener("onFormClose", formCloseAct);
		}
		//關閉視窗
		private function formCloseAct(e:Event):void{
			mdm.Application.exit();
		}
		//////////////////////////////////////////////////
		
		private function ininForm(){
			//關閉FORM
			mdm.Application.enableExitHandler();
			mdm.Application.onFormClose = function(){   
								
				mdm.Application.exit();
			};			

			//ESC
			this.addEventListener(Event.ENTER_FRAME,chkFocus);
			this.addEventListener(KeyboardEvent.KEY_DOWN,onDown)
			stage.focus = this;
			
		}
		/////////事件
		private function onDown(ke:KeyboardEvent)
		{
			//mdm.Dialogs.prompt(ke.keyCode.toString());
			
			if (ke.keyCode==27){
				mdm.Application.exitWithCode(0);//離開應用程式
			}
		}
		private function chkFocus(e:Event){
			if (stage.focus!=this){
				stage.focus=this;
			}
		}
		//////////////////////////////////////////////////
		private function  do_Uninstall(){
			
			hasAdminPrivilages = mdm.System.isAdmin;
			//mdm.Dialogs.prompt("You can=="+hasAdminPrivilages);
			/*myVersion = mdm.System.verString;
			//mdm.Dialogs.prompt("myVersion=="+myVersion);
			osVersion = mdm.System.verStringDetail;			
			//mdm.Dialogs.prompt("myosVersion=="+osVersion);
			
			if (osVersion.indexOf("XP")>=0){//判斷是否有XP字樣
				currOS="XP";
			}else if (myVersion.indexOf("6.")>=0){//vista OR win 7
				currOS="win7";
			}*/

			
			//讀取檔案			
			//var windowsPath:String = "c:\\benesse\\";
			var windowsPath:String = mdm.System.Paths.personal
			
			var fileExist:Boolean = mdm.FileSystem.fileExists(windowsPath + "\\benesse\\"+fixPath_secondLayer+"\\setup.ini");
				//mdm.Dialogs.prompt("keyExists=="+keyExists.toString());
				if (fileExist){
					
					installPath=mdm.FileSystem.loadFile(windowsPath + "\\benesse\\"+fixPath_secondLayer+"\\setup.ini");
					//mdm.Dialogs.prompt("installPath=="+installPath);
					
					if (installPath==""){//沒安裝
					
					}else{//有安裝
						installPath = installPath.replace("InstallPath=","");
						
						//mdm.Dialogs.prompt("installPath_new=="+installPath);
						//fix_shortCutLayer:String = "巧連智低年級版\\4月號竹林輕功傳";//名稱
						//fix_shortCutName:String = "竹林輕功傳";//名稱
					
						//刪除桌面捷徑
						var tmpPath:String = mdm.System.Paths.desktop;
						var shortcutLink:String = tmpPath+"\\"+fix_shortCutName+".lnk";
					
						//mdm.Dialogs.prompt(shortcutLink);
					
						mdm.FileSystem.deleteFile(shortcutLink);
						
						//刪除英語單元捷徑
						/*var E_shortcutLink:String = tmpPath+"\\"+"5月號英語學習單元"+".lnk";
						
						mdm.FileSystem.deleteFile(E_shortcutLink);*/
						
						//刪除開始功能表
						var StartMenuPath:String;
						if (hasAdminPrivilages){
							StartMenuPath = mdm.System.Paths.allUsersPrograms;
						}else{
							StartMenuPath = mdm.System.Paths.programs;
						}
					
						StartMenuPath = StartMenuPath +"\\"+ fix_shortCutLayer;
						//mdm.Dialogs.prompt("StartMenuPath=="+StartMenuPath);
						mdm.FileSystem.deleteFolder(StartMenuPath, "noask");

						//刪除folder
						var delPath:String = installPath + fixPath ;
						var exists:Boolean = mdm.FileSystem.folderExists(delPath);
						//mdm.Dialogs.prompt("installPath=="+delPath.toString());
						//mdm.Dialogs.prompt("exists=="+exists.toString());
						if (exists){
							mdm.FileSystem.deleteFolder(delPath, "noask");
						}
					
						//刪除記錄檔--要刪除記錄,刪除安裝路徑ini檔
						mdm.FileSystem.deleteFile(windowsPath + "\\benesse\\"+fixPath_secondLayer+"\\setup.ini");
						//var recordPath:String = windowsPath ;
						//var existsRecord:Boolean = mdm.FileSystem.folderExists(recordPath);
						//if (existsRecord){
						//	mdm.FileSystem.deleteFolder(recordPath, "noask");
						//}
					
					}
					
				}
				//刪除記錄檔--要刪除記錄
				//mdm.FileSystem.deleteFile(windowsPath + "\\benesse\\Gift.ini");
				mdm.FileSystem.deleteFile(windowsPath + "\\benesse\\"+"ColaPact.ini");
				mdm.FileSystem.deleteFile(windowsPath + "\\benesse\\"+"TitleMovie.ini");
				mdm.FileSystem.deleteFile(windowsPath + "\\benesse\\"+fixPath_secondLayer+"\\FirstGrade.ini");
				mdm.FileSystem.deleteFile(windowsPath + "\\benesse\\"+fixPath_secondLayer+"\\SecondGrade.ini");
				mdm.FileSystem.deleteFile(windowsPath + "\\benesse\\"+fixPath_secondLayer+"\\English.ini");
				mdm.FileSystem.deleteFile(windowsPath + "\\benesse\\"+fixPath_secondLayer+"\\getCoke.ini");

		}

		private function btnEvent(me:MouseEvent){
			var ma=me.currentTarget;
			if (me.type=="rollOver"){
				//按鈕聲音
				//btnSnd = new _snd_btnOver();
				//btnSndChl = btnSnd.play();
				//按鈕語音
				//btnVoiceSnd = new _snd_OK();
				//btnVoiceSndChl = btnVoiceSnd.play();
				
			}else if (me.type=="rollOut"){
				//停止聲音
				if (btnSndChl){
					btnSndChl.stop();				
				}
				//停止聲音
				if (btnVoiceSndChl){
					btnVoiceSndChl.stop();				
				}
			}
			
		}
		private function closeMe(me:MouseEvent){
			mdm.Application.exitWithCode(0);;//離開應用程式
		}
		
		
	}


}