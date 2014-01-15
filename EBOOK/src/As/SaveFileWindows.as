package As 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class SaveFileWindows extends Sprite 
	{
		private var listAmount:int = 3;		//有幾個存檔欄位
		private var tempFileLine:MovieClip;	//暫存選取的存檔欄位
		private var _saveArray:Array;		//要存檔的Array
		private var saveFile:File;
		
		public function SaveFileWindows() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			changeName_mc.visible = q_mc.visible = changeName_btn.visible = delete_btn.visible = save_btn.visible = false;
			save_btn.addEventListener(MouseEvent.CLICK, goSave);
			delete_btn.addEventListener(MouseEvent.CLICK, goDelete);
			//更改檔名
			changeName_btn.addEventListener(MouseEvent.CLICK, goChangeName);
			q_mc.addEventListener(MouseEvent.CLICK, startDelete);
			changeName_mc.addEventListener(MouseEvent.CLICK, startChangeName);
			changeName_mc.fileName_txt.addEventListener(Event.CHANGE, userInput);
			
			initLine();
			changeLine();
		}
		
		//更改檔名
		private function goChangeName(e:MouseEvent):void 
		{
			changeName_mc.fileName_txt.text = tempFileLine.fileName_txt.text;
			changeName_mc.fileName_txt.setSelection(0, changeName_mc.fileName_txt.length);
			this.stage.focus = changeName_mc.fileName_txt;
			changeName_mc.visible = true;
			changeName_mc.ok_btn.visible = true;
		}
		//輸入框內容改變
		private function userInput(e:Event):void 
		{
			if (e.currentTarget.length == 0) {	//若是空的就隱藏確定按鈕
				changeName_mc.ok_btn.visible = false;
			}else {
				changeName_mc.ok_btn.visible = true;
			}
		}
		private function startChangeName(e:MouseEvent):void 
		{
			
			if (e.target.name == "ok_btn") {
				//開舊檔
				saveFile = new File(File.applicationDirectory.resolvePath("save/" + tempFileLine.fileName_txt.text + ".ebk").nativePath);
				var fileStream:FileStream = new FileStream(); 
				//開啟為讀取狀態
				fileStream.open(saveFile, FileMode.READ); 
				//讀檔
				var _a:Array = fileStream.readObject(); 
				fileStream.close();
				
				//刪除更名前檔案
				saveFile.deleteFile();
				
				//存新檔
				saveFile = new File(File.applicationDirectory.resolvePath("save/" + changeName_mc.fileName_txt.text + ".ebk").nativePath);
				//開啟為寫入狀態
				fileStream.open(saveFile, FileMode.WRITE); 
				//存檔
				fileStream.writeObject(_a); 
				fileStream.close();
				
				tempFileLine.fileName_txt.text = changeName_mc.fileName_txt.text;
				changeName_mc.visible = false;
				
			}else if (e.target.name == "no_btn") {
				changeName_mc.visible = false;
			}
		}
		
		private function goDelete(e:MouseEvent):void 
		{
			if (tempFileLine.fileName_txt.length == 0) return;
			
			q_mc.visible = true;
			q_mc.fileName_txt.text = tempFileLine.fileName_txt.text;
		}
		private function startDelete(e:MouseEvent):void 
		{	
			if (e.target.name == "ok_btn") {
				q_mc.visible = false;
				saveFile = new File(File.applicationDirectory.resolvePath("save/" + tempFileLine.fileName_txt.text + ".ebk").nativePath);
				saveFile.deleteFile();
				delete_btn.visible = save_btn.visible = changeName_btn.visible = false;
				tempFileLine.fileNameInput_txt.visible = true;
				tempFileLine.fileName_txt.text = "";
				tempFileLine.fileTime_txt.text = "";
				tempFileLine = null;
				changeLine();
			}else if (e.target.name == "no_btn") {
				q_mc.visible = false;
			}
		}
			
		private function goSave(e:MouseEvent):void 
		{
			if (tempFileLine.fileNameInput_txt.visible && tempFileLine.fileNameInput_txt.length == 0) {
				return;
			}else {
				if (tempFileLine.fileNameInput_txt.visible) {
					tempFileLine.fileName_txt.text = tempFileLine.fileNameInput_txt.text;
				}
				var myDate:Date = new Date();
				tempFileLine.fileTime_txt.text = myDate.getFullYear() + "/" + (myDate.month + 1) + "/" + myDate.date + "   " + myDate.hours + ":" + myDate.minutes + ":" + (myDate.seconds + 1);
			}
			
			saveFile = new File(File.applicationDirectory.resolvePath("save/" + tempFileLine.fileName_txt.text + ".ebk").nativePath);
			trace("存檔=============", File.applicationStorageDirectory.nativePath, File.applicationDirectory.nativePath);
			var fileStream:FileStream = new FileStream(); 
			//開啟為寫入狀態
			fileStream.open(saveFile, FileMode.WRITE); 
			//存檔
			fileStream.writeObject(_saveArray); 
			fileStream.close();
			
			parent.removeChild(this);
		}
		
		private function initLine():void {
			for (var i:int = 1; i <= listAmount; i++) {
				var _mc:MovieClip = this["fileLine" + i + "_mc"];
				_mc.addEventListener(MouseEvent.MOUSE_OVER, lineMouseOver);
				_mc.addEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
				_mc.addEventListener(MouseEvent.CLICK, lineClick);
			}
		}
		
		private function changeLine():void {
			for (var i:int = 1; i <= listAmount; i++) {
				var _mc:MovieClip = this["fileLine" + i + "_mc"];
				_mc.frame_mc.gotoAndStop(1);
				_mc.addEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
				if (_mc.fileName_txt.length > 0) {
					_mc.fileNameInput_txt.visible = false;
				}else if (tempFileLine != _mc) {
					_mc.fileNameInput_txt.text = "請輸入檔名";
				}
			}
		}
		
		private function lineClick(e:MouseEvent):void 
		{
			tempFileLine = e.currentTarget as MovieClip;
			changeLine();
			tempFileLine.frame_mc.gotoAndStop(2);
			tempFileLine.removeEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
			
			//輸入框取得焦點
			tempFileLine.fileNameInput_txt.text = "";
			this.stage.focus = tempFileLine.fileNameInput_txt;
			
			if (tempFileLine.fileName_txt.length > 0) {
				changeName_btn.visible = delete_btn.visible = save_btn.visible = true;
			}else {
				changeName_btn.visible = delete_btn.visible = false;
				save_btn.visible = true;
			}
		}
		
		private function lineMouseOut(e:MouseEvent):void 
		{
			e.currentTarget.frame_mc.gotoAndStop(1);
		}
		
		private function lineMouseOver(e:MouseEvent):void 
		{
			e.currentTarget.frame_mc.gotoAndStop(2);
		}
		
		public function set saveArray(value:Array):void 
		{
			_saveArray = value;
		}
		
	}

}