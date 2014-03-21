package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
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
		private var _ul_:int;		//上傳型態 1:立即上傳 2:按下確認鍵才上傳
		
		public function FileUpLoad() 
		{
			SetupExternalInterface();
			//取得flashvars的參數
			_ul_type = root.loaderInfo.parameters.ul_type;
			_ul_q = root.loaderInfo.parameters.ul_q;
			_ul_ex = root.loaderInfo.parameters.ul_ex;
			_ul_size = root.loaderInfo.parameters.ul_size;
			_ul_ = root.loaderInfo.parameters.ul_;
			
			addEventListener(MouseEvent.CLICK, SelectFile);
			
			var _txt:TextField = new TextField();
			_txt.height = 300;
			_txt.text = "ul_type = " + _ul_type + "\n" +
						"ul_q = " + _ul_q + "\n" +
						"ul_ex = " + _ul_ex + "\n" +
						"ul_size = " + _ul_size + "\n" +
						"ul_ = " + _ul_;
			addChild(_txt);
		}
		
		private function SelectFile(e:MouseEvent):void  {
			this.fileBrowserOne = new FileReference();
			this.fileBrowserOne.addEventListener(Event.SELECT, this.Select_One_Handler);
			this.fileBrowserOne.addEventListener(Event.CANCEL,  this.DialogCancelled_Handler);
			_ul_ex = "*.jpg";
			try {
				this.fileBrowserOne.browse([new FileFilter("單張照片上傳", _ul_ex)]);
			} catch (ex:Error) {
				this.Debug("Exception: " + ex.toString());
			}
		}
		
		private function Select_One_Handler(e:Event):void 
		{
			
		}
		
		private function DialogCancelled_Handler(e:Event):void 
		{
			
		}
		
		private function SetupExternalInterface():void {
			try {
				//ExternalInterface.addCallback("ul_type", this.ul_type);
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