package As
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.text.TextField;
	import mdm.*;
	
	public class Uninstall extends MovieClip
	{
		//本檔案只做複製的動作:
		//把真正的移除執行檔複製到系統暫存資料夾，再呼叫
		//避免直接執行會無法完整刪除執行檔所在資料夾
		
		
		//反安裝執行檔名
		var unFileName:String="uninstall_excute.exe";
		//TEMP路徑
		//var myTempPath:String = mdm.System.Paths.temp;
		//固定路徑
		//var myTempPath:String = "c:\\benesse\\";
		var myTempPath:String;
		
		//目前執行路徑
		var unFilePath:String;
		
		
		public function Uninstall()
		{
			mdm.Application.init();
			
			//初始
			init();

		}
		
		private function  init(){
			
			//將反安裝執行檔複製到TEMP
			
			//mdm.Dialogs.prompt(myTempPath.toString());
			//mdm.Dialogs.prompt((myTempPath+"\\"+unFileName).toString());
			//mdm.Dialogs.prompt((unFilePath+unFileName).toString());
			
			mdm.FileSystem.addEventListener("onComplete", onDeleteComplete);
			mdm.FileSystem.addEventListener("onIOError", onDeleteError);
			
			myTempPath = mdm.System.Paths.personal + "\\benesse\\"; //改成我的文件底下
			//目前執行路徑
			if(mdm.Application.path != null){
				unFilePath = mdm.Application.path.replace("\\\\","\\");
			}
			
			var exists:Boolean = mdm.FileSystem.folderExists(myTempPath+"uninstall\\");
			//mdm.Dialogs.prompt(exists.toString());
			if (exists){
				mdm.FileSystem.deleteFolderAsync(myTempPath+"uninstall\\", "noask");
			}else{
				//移除檔案刪除事件
				mdm.FileSystem.removeEventListener("onComplete", onDeleteComplete);
				mdm.FileSystem.removeEventListener("onIOError", onDeleteError);
			
				//增加檔案複製事件
				mdm.FileSystem.addEventListener("onComplete", onCopyComplete);
				mdm.FileSystem.addEventListener("onIOError", onCopyError);
			
				//執行建立資料夾
				mdm.FileSystem.makeFolder(myTempPath+"uninstall\\");
				//執行複製
				mdm.FileSystem.copyFileAsync(unFilePath+unFileName, myTempPath+"uninstall\\"+unFileName);
			}
			//
			//mdm.FileSystem.copyFileAsync(unFilePath+unFileName, myTempPath+unFileName);
			
			//執行TEMP的反安裝檔
			
			mdm.Application.addEventListener("onFormClose", formCloseAct);
		}
		//關閉視窗
		private function formCloseAct(e:Event):void{
			mdm.Application.exit();
		}
		
		//////////////////////////////////////////////////
		private function onDeleteComplete(event:Event):void
		{	
			//成功之後，
			//移除檔案刪除事件
			mdm.FileSystem.removeEventListener("onComplete", onDeleteComplete);
			mdm.FileSystem.removeEventListener("onIOError", onDeleteError);
			
			//增加檔案複製事件
			mdm.FileSystem.addEventListener("onComplete", onCopyComplete);
			mdm.FileSystem.addEventListener("onIOError", onCopyError);
			
			//執行建立資料夾
			mdm.FileSystem.makeFolder(myTempPath+"uninstall\\");
			//執行複製
			mdm.FileSystem.copyFileAsync(unFilePath+unFileName, myTempPath+"uninstall\\"+unFileName);
			
		}
		
		private function onDeleteError(event:Event):void
		{
			mdm.Dialogs.prompt("Error To Delete");
			mdm.Dialogs.prompt(myTempPath+unFileName);
			//把自己關閉
			mdm.Application.exit();
		}


		//////////////////////////////////////////////////
		private function onCopyComplete(event:Event):void
		{
			// operation completed/finished
			//mdm.Dialogs.prompt("OK To Copy");
			//成功複製之後，執行
			mdm.System.exec(myTempPath+"uninstall\\"+unFileName);
			//把自己關閉
			mdm.Application.exit();
			
		}
		
		private function onCopyError(event:Event):void
		{
			//mdm.Dialogs.prompt("Error To Copy");
			//成功複製之後，執行
			mdm.System.exec(myTempPath+"uninstall\\"+unFileName);
			//把自己關閉
			mdm.Application.exit();
		}

		
	}


}