package 
{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Main extends Sprite 
	{
		private var conn:SQLConnection;
		private var _accountId = [];
		private var _clessId = [];
		private var _ioId = ["","支出","收入"];
		
		[Embed(source = "../bin/icon/msgIcon/All-3.png")]
		private var btn:Class;
		
		public function Main():void 
		{
			addEventListener(Event.REMOVED_FROM_STAGE, kill);
			
			//"記帳本匯出"按鈕
			var _bm:Bitmap = new btn();
			var _btn:MovieClip = new MovieClip();
			_btn.addChild(_bm);
			_btn.buttonMode = true;
			_btn.x = stage.stageWidth / 2 - (_btn.width / 2);
			_btn.y = 70;
			_btn.addEventListener(MouseEvent.CLICK, goLoad);
			addChild(_btn);
			
			//說明文字
			var _txt:TextField = new TextField();
			_txt.autoSize = TextFieldAutoSize.CENTER
			_txt.x = stage.stageWidth / 2 - (_txt.width / 2);
			_txt.y = 20;
			_txt.text = "請按下 \"記帳本匯出\" 按鈕，並選擇您想匯出的存檔。";
			addChild(_txt);
		}
		
		//選擇存檔
		private function goLoad(e:Event):void 
		{
			var zfile:File=File.documentsDirectory;
			//var zfile:File=File.desktopDirectory;
			var aryType:Array=new Array(new FileFilter("匯入檔 (*.EMSGBILL)", "*.EMSGBILL"));
				
			zfile.addEventListener(Event.SELECT, restoreBak);
			zfile.browseForOpen("選擇匯入檔",aryType);
		}
		
		//取得存檔並轉回db檔
		private function restoreBak(e:Event):void 
		{
			var bakfile:File = e.target as File;
				
			//取得存檔
			var stream:FileStream = new FileStream();
			stream.open(bakfile, FileMode.READ);
			//寫入ByteArray
			var content:ByteArray =new ByteArray();
			stream.readBytes(content);
			stream.close();
			
			//轉成db檔(建立一個temp.db)
			var tempDB:File =  new File(File.documentsDirectory.nativePath+"/temp.db");
			var dbStream:FileStream=new FileStream();
			dbStream.open(tempDB,FileMode.WRITE);
			dbStream.writeBytes(content,0,content.length); 
			dbStream.close();
			//tempDB.deleteFile();
			
			//開啟db檔
			conn = new SQLConnection();
			conn.addEventListener(SQLEvent.OPEN, openHandler);
			conn.open(tempDB);
		}
		
		private function openHandler(event:SQLEvent):void{
			readDB(setAccountType, "SELECT AccountId, AccountName FROM AccountTable");
			readDB(setClessType, "SELECT ClessId, ClessName FROM ClessTable");
			readDB(resultHandler, "SELECT AccountId, ClessId, IOId, InputDate, Money, Note FROM BillTable");
		}
		
		private function readDB(_f:Function, _selectTxt:String):void {
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = conn;
			statement.text = _selectTxt;
			statement.addEventListener(SQLEvent.RESULT, _f);
			statement.execute();
		}
		
		private function resultHandler(event:SQLEvent):void{
			var statement:SQLStatement = event.target as SQLStatement;
			var data:Array = statement.getResult().data;
			var _s:String = "";
			for (var i:int = 0; i < data.length; i++) {
				_s += _accountId[data[i].AccountId] + 
					"," + _clessId[data[i].ClessId] + 
					"," + _ioId[data[i].IOId] + 
					"," + new Date(data[i].InputDate).getFullYear() + "/" + Number(new Date(data[i].InputDate).getMonth()+1) + "/" + new Date(data[i].InputDate).getDate() + 
					"," + data[i].Money + 
					"," + data[i].Note + "\n";
				trace("帳戶名稱:" + _accountId[data[i].AccountId] + 
					" ,記帳類型:" + _clessId[data[i].ClessId] + 
					" ,收支類型:" + _ioId[data[i].IOId] + 
					" ,記帳日期:" + new Date(data[i].InputDate).getFullYear() + "/" + Number(new Date(data[i].InputDate).getMonth()+1) + "/" + new Date(data[i].InputDate).getDate() + 
					" ,帳目金額:" + data[i].Money + 
					" ,Note:" + data[i].Note);
			}
			//匯出csv
			var tempCSV:File =  new File(File.documentsDirectory.nativePath+"/e管家記帳本.csv");
			var csvStream:FileStream=new FileStream();
			csvStream.open(tempCSV,FileMode.WRITE);
			csvStream.writeMultiByte(_s,"UTF8"); 
			csvStream.close();
			
			//說明文字
			var _txt:TextField = new TextField();
			_txt.autoSize = TextFieldAutoSize.CENTER
			_txt.x = stage.stageWidth / 2 - (_txt.width / 2);
			_txt.y = 140;
			_txt.text = "您的記帳本已經匯出到：" + File.documentsDirectory.nativePath.toString() + "/e管家記帳本.csv。";
			addChild(_txt);
			
			//寫入CSV檔案路徑
			writeTxt();
			//開啟CSV檔
			openCSV();
		}
		
		//將使用者選擇的檔案路徑寫進fscommand資料夾裡的openFile.txt,讓openFile.exe可以讀取外部檔案
		private function writeTxt():void {
			var saveFile:File = new File(File.applicationDirectory.resolvePath("fscommand/openFile.txt").nativePath);
			//開啟為寫入狀態
			var fileStream:FileStream = new FileStream();
			fileStream.open(saveFile, FileMode.WRITE); 
			//存檔,必須存成ANSI才可以正確讀取中文路徑
			fileStream.writeMultiByte(File.documentsDirectory.nativePath.toString() + "/e管家記帳本.csv", "ANSI");
			//fileStream.writeUTFBytes(e.currentTarget.nativePath); 
			fileStream.close();
		}
		
		private function openCSV():void {
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo(); 
			var file:File = File.applicationDirectory.resolvePath("fscommand/openFile.exe"); 
			nativeProcessStartupInfo.executable = file; 
			var process:NativeProcess = new NativeProcess(); 
			process.start(nativeProcessStartupInfo); 
		}
		
		//取得所有帳戶名稱
		private function setAccountType(event:SQLEvent):void {
			var statement:SQLStatement = event.target as SQLStatement;
			var data:Array = statement.getResult().data;
			for (var i:int = 0; i < data.length; i++) {
				_accountId[data[i].AccountId] = data[i].AccountName;
			}
			//trace("_array:", _accountId);
		}
		//取得所有記帳類型
		private function setClessType(event:SQLEvent):void {
			var statement:SQLStatement = event.target as SQLStatement;
			var data:Array = statement.getResult().data;
			for (var i:int = 0; i < data.length; i++) {
				_clessId[data[i].ClessId] = data[i].ClessName;
			}
			//trace("_array:", _clessId);
		}
		
		private function kill(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
			conn.close();
		}
		
	}
	
}