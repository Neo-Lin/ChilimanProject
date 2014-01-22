package As 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class LoadFileWindows extends Sprite 
	{
		private var listAmount:int = 6;		//有幾個存檔欄位
		private var tempFileLine:MovieClip;	//暫存選取的存檔欄位
		private var _saveArray:Array = [];		//要存檔的Array
		private var allListArray:Array = new Array();		//存檔欄位列表
		private var saveFile:File;
		private var fileStream:FileStream = new FileStream();
		
		public function LoadFileWindows() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			changeName_mc.visible = q_mc.visible = changeName_btn.visible = delete_btn.visible = open_btn.visible = false;
			close_btn.addEventListener(MouseEvent.CLICK, goClose);
			//save_btn.addEventListener(MouseEvent.CLICK, goSave);
			//saveAs_btn.addEventListener(MouseEvent.CLICK, goSave);
			open_btn.addEventListener(MouseEvent.CLICK, goOpen);
			delete_btn.addEventListener(MouseEvent.CLICK, goDelete);
			//確認刪除存檔的詢問框
			q_mc.addEventListener(MouseEvent.CLICK, startDelete);
			//更改檔名
			changeName_btn.addEventListener(MouseEvent.CLICK, goChangeName);
			//輸入新檔名的視窗
			changeName_mc.addEventListener(MouseEvent.CLICK, startChangeName);
			changeName_mc.fileName_txt.addEventListener(Event.CHANGE, userInput);
			//開啟舊檔
			openAs_btn.addEventListener(MouseEvent.CLICK, goOpenOld);
			
			initLine();
			changeLine();
		}
		
		//開啟舊檔
		private function goOpenOld(e:MouseEvent):void 
		{
			var txtFilter:FileFilter = new FileFilter("Text", "*.ebk");
			saveFile = new File();
			saveFile.browseForOpen("Open", [txtFilter]);
			saveFile.addEventListener(Event.SELECT, fileSelected);
		}
		private function fileSelected(e:Event):void 
		{
			_saveArray = loadPcFile(saveFile);
			this.dispatchEvent(new Event("you_can_take_array"));
			goClose(null);
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
		//檔名輸入框內容改變
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
				var _a:Array = loadPcFile(saveFile);
				
				//刪除更名前檔案
				saveFile.deleteFile();
				
				//存新檔
				saveFile = new File(File.applicationDirectory.resolvePath("save/" + changeName_mc.fileName_txt.text + ".ebk").nativePath);
				savePcFile(saveFile, _a);
				
				tempFileLine.fileName_txt.text = changeName_mc.fileName_txt.text;
				changeName_mc.visible = false;
				
				//更新存檔欄位列表
				renewAllListArray();
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
				delete_btn.visible = open_btn.visible = changeName_btn.visible = false;
				tempFileLine.fileName_txt.text = "";
				tempFileLine.fileTime_txt.text = "";
				//更新存檔欄位列表
				renewAllListArray();
				tempFileLine = null;
				changeLine();
			}else if (e.target.name == "no_btn") {
				q_mc.visible = false;
			}
		}
		
		private function goOpen(e:MouseEvent):void 
		{
			saveFile = new File(File.applicationDirectory.resolvePath("save/" + tempFileLine.fileName_txt.text + ".ebk").nativePath);
			_saveArray = loadPcFile(saveFile);
			this.dispatchEvent(new Event("you_can_take_array"));
			goClose(null);
		}
		
		/*private function goSave(e:MouseEvent):void 
		{
			if (tempFileLine.fileNameInput_txt.visible && tempFileLine.fileNameInput_txt.length == 0) {
				return;
			}else {
				if (tempFileLine.fileNameInput_txt.visible) {
					tempFileLine.fileName_txt.text = tempFileLine.fileNameInput_txt.text;
				}
			}
			
			saveFile = new File(File.applicationDirectory.resolvePath("save/" + tempFileLine.fileName_txt.text + ".ebk").nativePath);
			if (e.currentTarget.name == "save_btn") {	//存檔
				trace("存檔=============", File.applicationStorageDirectory.nativePath, File.applicationDirectory.nativePath);
				savePcFile(saveFile, _saveArray);
				var myDate:Date = new Date();
				tempFileLine.fileTime_txt.text = myDate.fullYear + "/" + (myDate.month + 1) + "/" + myDate.date + "   " + myDate.hours + ":" + myDate.minutes + ":" + (myDate.seconds + 1);
			}else if (e.currentTarget.name == "saveAs_btn") {	//另存新檔
				var ba:ByteArray = new ByteArray();
				ba.writeObject(_saveArray);
				saveFile.save(ba);
			}
			
			//更新存檔欄位列表
			renewAllListArray();
			
			parent.removeChild(this);
		}*/
		
		//初始化存檔欄位
		public function initLine():void {
			saveFile = new File(File.applicationDirectory.resolvePath("save/ebkList").nativePath);
			if (saveFile.exists) {	 //如果檔案存在
				allListArray = loadPcFile(saveFile);
			}
			for (var i:int = 1; i <= listAmount; i++) {
				var _mc:MovieClip = this["fileLine" + i + "_mc"];
				_mc.fileNameInput_txt.visible = false;
				_mc.addEventListener(MouseEvent.MOUSE_OVER, lineMouseOver);
				_mc.addEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
				_mc.addEventListener(MouseEvent.CLICK, lineClick);
				if (allListArray[i]) {	
					_mc.fileName_txt.text = allListArray[i][0];
					_mc.fileTime_txt.text = allListArray[i][1];
				}
			}
		}
		
		//取消所有存檔欄位的選取狀態
		private function changeLine():void {
			for (var i:int = 1; i <= listAmount; i++) {
				var _mc:MovieClip = this["fileLine" + i + "_mc"];
				_mc.frame_mc.gotoAndStop(1);
				_mc.addEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
			}
		}
		
		//切換存檔欄位
		private function lineClick(e:MouseEvent):void 
		{
			tempFileLine = e.currentTarget as MovieClip;
			if (tempFileLine.fileName_txt.length > 0) {	//存檔欄位有資料才可選取
				changeLine();
				tempFileLine.frame_mc.gotoAndStop(2);
				tempFileLine.removeEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
				changeName_btn.visible = delete_btn.visible = open_btn.visible = true;
			}else {
				changeName_btn.visible = delete_btn.visible = open_btn.visible = false;
			}
		}
		
		private function loadPcFile(_f:File):Array {
			//開啟為讀取狀態
			fileStream.open(saveFile, FileMode.READ); 
			//讀檔
			var _a:Array = fileStream.readObject(); 
			fileStream.close();
			
			return _a;
		}
		private function savePcFile(_f:File, _a:Array) {
			//開啟為寫入狀態
			fileStream.open(saveFile, FileMode.WRITE); 
			//存檔
			fileStream.writeObject(_a); 
			fileStream.close();
		}
		
		//更新存檔欄位列表
		private function renewAllListArray():void {
			allListArray[tempFileLine.name.substr(8, 1)] = [tempFileLine.fileName_txt.text, tempFileLine.fileTime_txt.text];
			saveFile = new File(File.applicationDirectory.resolvePath("save/ebkList").nativePath);
			savePcFile(saveFile, allListArray);
		}
		
		//存檔欄位滑入滑出
		private function lineMouseOut(e:MouseEvent):void 
		{
			e.currentTarget.frame_mc.gotoAndStop(1);
		}
		private function lineMouseOver(e:MouseEvent):void 
		{
			e.currentTarget.frame_mc.gotoAndStop(2);
		}
		
		//讓Main能取得開啟舊檔的Array
		public function get saveArray():Array 
		{
			return _saveArray;
		}
		
		//關閉自己
		private function goClose(e:MouseEvent):void 
		{
			tempFileLine = null;
			parent.removeChild(this);
		}
	}

}