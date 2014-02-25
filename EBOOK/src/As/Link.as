package As 
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.fscommand;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Link extends Sprite 
	{
		private var process:NativeProcess;
		private var tempTitle:String = "";
		private var tempLink:String = "";
		private var tempX:Number;
		private var tempY:Number;
		private var isInitForData:Boolean = false;
		
		public function Link() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			//initForData就跳出
			if (isInitForData) return;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, followMouse);
		}
		
		private function followMouse(e:MouseEvent):void 
		{	
			stage.addEventListener(MouseEvent.CLICK, startLink);
			this.x = stage.mouseX;
			this.y = stage.mouseY;
		}
		
		private function startLink(e:MouseEvent = null):void 
		{
			if (stage) {
				stage.removeEventListener(MouseEvent.CLICK, startLink);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, followMouse);
			}
			linkMc_mc.addEventListener(MouseEvent.MOUSE_DOWN, goDrag);
			linkMc_mc.addEventListener(MouseEvent.MOUSE_UP, goLink);
			linkMc_mc.addEventListener(MouseEvent.MOUSE_OVER, showBtn);
			area_mc.addEventListener(MouseEvent.MOUSE_MOVE, hideBtn);
			edit_btn.addEventListener(MouseEvent.CLICK, goEdit);
			delete_btn.addEventListener(MouseEvent.CLICK, kill);
			
			//若連結還沒設定,就跳出"設定連結視窗",沒有帶事件(initForData)就不用
			if (linkPanel_mc.link_txt.text.length < 1 && e) {
				linkPanel_mc.visible = true;
			}
			
			linkPanel_mc.addEventListener(MouseEvent.CLICK, settingLink);
		}
		
		//建立存檔的連結,提供給LinkManage使用,Array內容看getData
		public function initForData(_a:Array):void {
			isInitForData = true;
			this.x = _a[0];
			this.y = _a[1];
			title_txt.text = linkPanel_mc.title_txt.text = _a[2];
			linkPanel_mc.link_txt.text = _a[3];
			startLink();
		}
		
		//顯示"編輯","刪除"按鈕
		private function hideBtn(e:MouseEvent):void 
		{
			edit_btn.visible = false;
			delete_btn.visible = false;
		}
		private function showBtn(e:MouseEvent):void 
		{
			edit_btn.visible = true;
			delete_btn.visible = true;
		}
		
		//跳出"設定連結視窗"
		private function goEdit(e:MouseEvent):void 
		{
			tempTitle = linkPanel_mc.title_txt.text;
			tempLink = linkPanel_mc.link_txt.text;
			linkPanel_mc.visible = true;
		}
		
		//移動圖示
		private function goDrag(e:MouseEvent):void 
		{
			tempX = this.x;
			tempY = this.y;
			this.startDrag();
		}
		private function goLink(e:MouseEvent):void 
		{
			this.stopDrag();
			//如果沒有設定連結或是有移動就跳出
			if (linkPanel_mc.link_txt.text.length == 0 ||
			(tempX != this.x && tempY != this.y)) return;
			//開啟連結
			writeTxt();
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo(); 
			var file:File = File.applicationDirectory.resolvePath("fscommand/openFile.exe"); 
			nativeProcessStartupInfo.executable = file; 
			process = new NativeProcess(); 
			process.start(nativeProcessStartupInfo); 
		}
		
		//"設定連結視窗"的功能
		private function settingLink(e:MouseEvent):void {	
			if (e.target.name == "close_btn") {
				linkPanel_mc.title_txt.text = tempTitle;
				linkPanel_mc.link_txt.text = tempLink;
				linkPanel_mc.visible = false;
			}else if (e.target.name == "ok_btn") {
				title_txt.text = linkPanel_mc.title_txt.text;
				//writeTxt();
				linkPanel_mc.visible = false;
			}else if (e.target.name == "favorites_btn") {
				
			}else if (e.target.name == "browse_btn") {
				//設定路徑
				var file:File = File.desktopDirectory;
				//var file:File = new File(File.desktopDirectory.nativePath);
				//trace(File.documentsDirectory.nativePath,File.desktopDirectory.nativePath,File.userDirectory.nativePath);
				//偵聽檔案存檔完成
				file.addEventListener(Event.SELECT, fileSelect);
				file.browseForOpen("請選擇要鏈結的檔案:");
			}else if (e.target.name == "title_txt") {
				
			}else if (e.target.name == "link_txt") {
				
			}
		}
		
		//將使用者選擇的檔案路徑寫進fscommand資料夾裡的openFile.txt,讓openFile.exe可以讀取外部檔案
		private function writeTxt():void {
			var saveFile:File = new File(File.applicationDirectory.resolvePath("fscommand/openFile.txt").nativePath);
			//開啟為寫入狀態
			var fileStream:FileStream = new FileStream();
			fileStream.open(saveFile, FileMode.WRITE); 
			//存檔,必須存成ANSI才可以正確讀取中文路徑
			fileStream.writeMultiByte(linkPanel_mc.link_txt.text, "ANSI");
			//fileStream.writeUTFBytes(e.currentTarget.nativePath); 
			fileStream.close();
		}
		
		private function fileSelect(e:Event):void 
		{	
			e.currentTarget.removeEventListener(Event.SELECT, fileSelect);
			linkPanel_mc.link_txt.text = e.currentTarget.nativePath;
			if(linkPanel_mc.title_txt.text.length == 0) linkPanel_mc.title_txt.text = e.currentTarget.name;
		}
		
		//提供外部取得資料
		public function getData():Array {
			return [this.x,this.y,linkPanel_mc.title_txt.text,linkPanel_mc.link_txt.text];
		}
		
		//移除連結功能
		private function kill(e:MouseEvent):void 
		{
			linkMc_mc.removeEventListener(MouseEvent.MOUSE_DOWN, goDrag);
			linkMc_mc.removeEventListener(MouseEvent.MOUSE_UP, goLink);
			linkMc_mc.removeEventListener(MouseEvent.MOUSE_OVER, showBtn);
			area_mc.removeEventListener(MouseEvent.MOUSE_MOVE, hideBtn);
			edit_btn.removeEventListener(MouseEvent.CLICK, goEdit);
			delete_btn.removeEventListener(MouseEvent.CLICK, kill);
			linkPanel_mc.removeEventListener(MouseEvent.CLICK, settingLink);
			parent.removeChild(this);
		}
	}
}