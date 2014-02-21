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
		public function Link() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, followMouse);
		}
		
		private function followMouse(e:MouseEvent):void 
		{	
			stage.addEventListener(MouseEvent.CLICK, startLink);
			this.x = stage.mouseX;
			this.y = stage.mouseY;
		}
		
		private function startLink(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.CLICK, startLink);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, followMouse);
			linkMc_mc.addEventListener(MouseEvent.MOUSE_DOWN, goDrag);
			linkMc_mc.addEventListener(MouseEvent.MOUSE_UP, noDrag);
			linkMc_mc.addEventListener(MouseEvent.CLICK, goLink);
			linkMc_mc.addEventListener(MouseEvent.MOUSE_OVER, showBtn);
			area_mc.addEventListener(MouseEvent.MOUSE_MOVE, hideBtn);
			edit_btn.addEventListener(MouseEvent.CLICK, goEdit);
			delete_btn.addEventListener(MouseEvent.CLICK, kill);
			
			//若連結還沒設定,就跳出"設定連結視窗"
			if (linkPanel_mc.link_txt.text.length < 1) {
				linkPanel_mc.visible = true;
			}
			
			linkPanel_mc.addEventListener(MouseEvent.CLICK, settingLink);
		}
		
		//開啟連結
		private function goLink(e:MouseEvent):void 
		{	trace("開啟連結");
			fscommand("exec", "openFile.exe");
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
			linkPanel_mc.visible = true;
		}
		
		//移動圖示
		private function goDrag(e:MouseEvent):void 
		{
			this.startDrag();
		}
		private function noDrag(e:MouseEvent):void 
		{
			this.stopDrag();
		}
		
		//"設定連結視窗"的功能
		private function settingLink(e:MouseEvent):void {	
			if (e.target.name == "close_btn") {
				linkPanel_mc.visible = false;
			}else if (e.target.name == "ok_btn") {
				
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
		
		private function fileSelect(e:Event):void 
		{	
			linkPanel_mc.link_txt.text = e.currentTarget.nativePath;
			linkPanel_mc.title_txt.text = e.currentTarget.name;
			var saveFile:File = new File(File.applicationDirectory.resolvePath("fscommand/openFile.txt").nativePath);
			//開啟為寫入狀態
			var fileStream:FileStream = new FileStream();
			fileStream.open(saveFile, FileMode.WRITE); 
			//存檔
			trace();
			fileStream.writeUTFBytes(e.currentTarget.nativePath); 
			fileStream.close();
			/*var request:URLRequest = new URLRequest(e.currentTarget.nativePath);
			navigateToURL(request);*/
			
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo(); 
			var file:File = File.applicationDirectory.resolvePath("fscommand/openFile.exe"); 
			nativeProcessStartupInfo.executable = file; 
			/*var processArgs:Vector.<String> = new Vector.<String>(); 
			processArgs.push("hello"); 
			nativeProcessStartupInfo.arguments = processArgs; */
			process = new NativeProcess(); 
			//process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData); 
			process.start(nativeProcessStartupInfo); 
		}
		
		/*public function onOutputData(event:ProgressEvent):void 
		{ 
			var stdOut:ByteArray = process.standardOutput; 
			var data:String = stdOut.readUTFBytes(process.standardOutput.bytesAvailable); 
			trace("Got: ", data); 
		}*/
		
		//移除連結功能
		private function kill(e:MouseEvent):void 
		{
			
		}
	}
}