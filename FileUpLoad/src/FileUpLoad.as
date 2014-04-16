package  
{
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class FileUpLoad extends Sprite 
	{
		private var debugEnabled:Boolean;
		private var fileBrowserMany:FileReferenceList = new FileReferenceList();
		private var fileBrowserOne:FileReference = null;
		private var _ul_type:int;	//上傳類型 1:單檔 2:選擇多檔
		private var _ul_q:int;		//上傳數量限制
		private var _ul_ex:String;	//上傳型別(副檔名)
		private var _ul_size:int;	//上傳檔案大小限制
		private var _ul_cb:int = 1;	//上傳型態 1:立即上傳 2:按下確認鍵才上傳
        private var _ul_url:String;	//上傳網址
		private var _fileList = [];
        private var _file:FileReference;
		
		public function FileUpLoad() 
		{
			SetupExternalInterface();
			//取得flashvars的參數
			_ul_type = root.loaderInfo.parameters.ul_type;
			_ul_q = root.loaderInfo.parameters.ul_q;
			_ul_ex = root.loaderInfo.parameters.ul_ex;
			_ul_size = root.loaderInfo.parameters.ul_size;
			if (root.loaderInfo.parameters.ul_cb) {
				_ul_cb = root.loaderInfo.parameters.ul_cb;
			}
			if (root.loaderInfo.parameters.ul_url)
            {
                this._ul_url = root.loaderInfo.parameters.ul_url;
            }
			
			//測試用
			//if(ExternalInterface.available) ExternalInterface.call("ul_cb_select","test");
			_ul_ex = "*.jpg"; _ul_type = 1; _ul_url = "http://localhost";
			var _txt:TextField = new TextField();
			_txt.height = 300;
			_txt.text = "ul_type = " + _ul_type + "\n" +
						"ul_q = " + _ul_q + "\n" +
						"ul_ex = " + _ul_ex + "\n" +
						"ul_size = " + _ul_size + "\n" +
						"ul_cb = " + _ul_cb + "\n" +
						"ul_url = " + _ul_url;
			addChild(_txt);
			
			if (_ul_type == 1) {	//單檔
				addEventListener(MouseEvent.CLICK, SelectFile);
			}else if(_ul_type == 2) {	//多檔
				addEventListener(MouseEvent.CLICK, SelectFiles);
			}
			
			this.fileBrowserMany.addEventListener(Event.SELECT, this.Select_Many_Handler);
			this.fileBrowserMany.addEventListener(Event.CANCEL, this.DialogCancelled_Handler);
			
		}
		
		private function SelectFiles(e:MouseEvent):void 
		{
			try {
				this.fileBrowserMany.browse([new FileFilter("Image " + _ul_ex, _ul_ex)]);
			} catch (ex:Error) {
				this.Debug("Exception: " + ex.toString());
			}
		}
		
		private function Select_Many_Handler(e:Event):void 
		{
			trace("Select_Many_Handler", _ul_cb);
			_fileList = e.currentTarget.fileList;
			
			//回傳已選擇檔案-序號,檔名,大小,狀態
			if (ExternalInterface.available) {
				var _i:int;
				for each(var f:FileReference in _fileList) {
					_i++;
					ExternalInterface.call("ul_cb_select", _i, f.name, f.size, "1");
				}
			}
			
			if (_ul_cb == 1) {	//立即上傳
				load_Many();
			}
		}
		
		//上傳檔案(多檔)
		private function load_Many():void {
			var _i:int;
			for each(var f:FileReference in _fileList) {
				_i++;
				trace(_i, f.name, f.size);
				f.addEventListener(Event.OPEN, manyUpLoadStart);
				f.addEventListener(ProgressEvent.PROGRESS, manyUpLoading);
				f.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, manyUpLoadComplete);
				f.upload(new URLRequest("http://localhost"));
			}
		}
		
		private function manyUpLoadStart(e:Event):void 
		{
			trace(e.currentTarget.name + " 開始上傳!!");
		}
		private function manyUpLoading(e:ProgressEvent):void 
		{
			trace(e.currentTarget.name + " 上傳中....");
			if (ExternalInterface.available) ExternalInterface.call("ul_cb_status", e.currentTarget.name, "1");
			trace("已上傳:" + e.bytesLoaded, "總大小:" + e.bytesTotal, "進度:" + e.bytesLoaded / e.bytesTotal * 100);
			if (ExternalInterface.available) ExternalInterface.call("ul_cb_kb", e.currentTarget.name, e.bytesLoaded / e.bytesTotal * 100);
		}
		private function manyUpLoadComplete(e:DataEvent):void 
		{
			trace(e.currentTarget.name + " 上傳完畢!!");
			if (ExternalInterface.available) ExternalInterface.call("ul_cb_status", e.currentTarget.name, "2");
		}
		
		private function SelectFile(e:MouseEvent):void  {
			this.fileBrowserOne = new FileReference();
			this.fileBrowserOne.addEventListener(Event.SELECT, this.Select_One_Handler);
			this.fileBrowserOne.addEventListener(Event.CANCEL,  this.DialogCancelled_Handler);
			
			try {
				this.fileBrowserOne.browse([new FileFilter("Image " + _ul_ex, _ul_ex)]);
			} catch (ex:Error) {
				this.Debug("Exception: " + ex.toString());
			}
		}
		
		private function Select_One_Handler(e:Event):void 
		{
			trace("Select_One_Handler");
            this._file = e.currentTarget as FileReference;
            if (ExternalInterface.available)
            {
                ExternalInterface.call("ul_cb_select", "1", this._file.name, this._file.size, "1");
            }
            if (this._ul_cb == 1)
            {
                this.load_One();
            }
		}
		
		//上傳檔案(單檔)
		private function load_One():void
        {
            this._file.addEventListener(Event.OPEN, this.manyUpLoadStart);
            this._file.addEventListener(ProgressEvent.PROGRESS, this.manyUpLoading);
            this._file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.manyUpLoadComplete);
            this._file.upload(new URLRequest(this._ul_url));
            return;
        }
		
		private function DialogCancelled_Handler(e:Event):void 
		{
			
		}
		
		//js呼叫檔案上傳
		private function start_upload() : void
        {
            if (this._ul_type == 1)
            {
                this.load_One();
            }
            else if (this._ul_type == 2)
            {
                this.load_Many();
            }
		}
		
		//設定讓js呼叫的函式
		private function SetupExternalInterface():void {
			try {
				ExternalInterface.addCallback("start_upload", this.start_upload);
			} catch (ex:Error) {
				this.Debug("Callbacks where not set: " + ex.message);
				return;
			}
		}
		
		private function Debug(msg:String):void {
			try {
				if (this.debugEnabled) {
					var lines:Array = msg.split("\n");
					for (var i:Number=0; i < lines.length; i++) {
						lines[i] = "SWF DEBUG: " + lines[i];
					}
						//ExternalCall.Debug(this.debug_Callback, lines.join("\n"));
				}
			} catch (ex:Error) {
				// pretend nothing happened
				trace(ex);
			}
		}
	}

}