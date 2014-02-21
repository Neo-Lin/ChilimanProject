package As 
{
	import As.Events.LoadingPageEvent;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Neo
	 * bookMarkPanel_mc 新增書籤
	 * list_mc 放書籤列表的容器
	 */
	public class BookMark extends Sprite 
	{
		private var _pageNumber:int;
		private var _showPageNumber:int;
		private var markXML:XML;
		private var _fireName:String;
		private var _url:String = "Bookmark.xml";
		private var xmlURL:URLRequest = new URLRequest(_url);
		private var xmlLoader:URLLoader = new URLLoader();
		private var _showMode:String;
		private var myDate:Date = new Date();
		
		private	var deleteMark_btn:SimpleButton;
		private	var allDeleteMark_btn:SimpleButton;
		private	var newMark_btn:SimpleButton;
		private	var close_btn:SimpleButton;
		private var list_mc:MovieClip;
		
		public function BookMark(fireName:String = null) 
		{
			deleteMark_btn = bookMarkList_mc.deleteMark_btn;
			allDeleteMark_btn = bookMarkList_mc.allDeleteMark_btn;
			newMark_btn = bookMarkList_mc.newMark_btn;
			close_btn = bookMarkList_mc.close_btn;
			list_mc = bookMarkList_mc.list_mc;
			
			initBookMark();
		}
		
		public function initBookMark(fireName:String = null) {
			if (fireName) xmlURL.url = fireName + _url;
			xmlLoader.addEventListener(Event.COMPLETE, xmlComplete);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			xmlLoader.load(xmlURL);
		}
		
		private function xmlComplete(e:Event):void 
		{
			xmlLoader.removeEventListener(Event.COMPLETE, xmlComplete);
			markXML = XML(xmlLoader.data);
			if (xmlURL.url == "Bookmark.xml") {
				delete markXML.list.*;
			}
			//trace("BookMark:::::", markXML.list.length(), markXML.list.bookmark.length(), markXML.list.bookmark.(@pageNumber == _pageNumber).length());
			
			deleteMark_btn.addEventListener(MouseEvent.CLICK, deleteMark);
			allDeleteMark_btn.addEventListener(MouseEvent.CLICK, allDeleteMark);
			newMark_btn.addEventListener(MouseEvent.CLICK, newMark);
			bookMarkPanel_mc.addEventListener(MouseEvent.CLICK, markPanel);
			addEventListener(Event.REMOVED_FROM_STAGE, kill);
			close_btn.addEventListener(MouseEvent.CLICK, goClose);
			stage.addEventListener(LoadingPageEvent.START_TURN_PAGE, goClose);	//開始翻頁關閉書籤
		}
		
		//更新列表list_mc
		public function loadBookMark():void 
		{
			var _n:int = markXML.list.bookmark.length();
			var _l:BookMarkListBtn;
			var _ln:int = list_mc.numChildren;
			//若list_mc不是空的就先清空
			if (_ln > 0) {
				for (var j:int = 0; j < _ln; j++) {
					_l = list_mc.getChildAt(0) as BookMarkListBtn;
					_l.removeEventListener(MouseEvent.CLICK, listBtn);
					list_mc.removeChild(_l);
				}
			}
			
			for (var i:int = 0; i < _n; i++) {
				_l = new BookMarkListBtn();
				_l.name = markXML.list.bookmark[i].@pageNumber;
				_l.pageNumber_txt.text = String(int(_l.name) + 1);
				_l.title_txt.text = markXML.list.bookmark[i].@title;
				_l.x = 7;
				_l.y = 7 + 7 * i + _l.height * i;
				_l.addEventListener(MouseEvent.CLICK, listBtn);
				list_mc.addChild(_l);
			}
			
			//若有加入過書籤就把"新增書籤"按鈕隱藏
			if (markXML.list.bookmark.(@pageNumber == _pageNumber).length() >= 1) {
				newMark_btn.visible = false;
			}else {
				newMark_btn.visible = true;
			}
		}
		
		//列表內的條列按鈕功能BookMarkListBtn
		private function listBtn(e:MouseEvent):void 
		{
			if (e.target.name == "checkBox_mc") {	//勾選
				if (e.target.currentFrameLabel == "0") {
					e.target.gotoAndStop(4);
				}else {
					e.target.gotoAndStop(0);
				}
			}else if (e.target.name == "go_btn") {	//前往書籤
				_showPageNumber = int(e.currentTarget.name);
				dispatchEvent(new Event("go_page"));
			}else if (e.target.name == "show_btn") {	//查看書籤內容
				lookbookMark(int(e.currentTarget.name));
			}
		}
		
		//查看書籤內容
		public function lookbookMark(showPageNumber:int):void {
			_showPageNumber = showPageNumber;
			bookMarkPanel_mc.visible = this.visible = true;
			bookMarkPanel_mc.page_txt.text = String(_showPageNumber + 1);
			bookMarkPanel_mc.title_txt.text = markXML.list.bookmark.(@pageNumber == _showPageNumber).@title;
			bookMarkPanel_mc.text_txt.text = markXML.list.bookmark.(@pageNumber == _showPageNumber).@text;
		}
		
		//新增書籤面板功能bookMarkPanel_mc
		private function markPanel(e:MouseEvent):void 
		{
			if (e.target.name == "ok_btn") {	//確定
				//若有加入過書籤就覆蓋並關閉
				if (markXML.list.bookmark.(@pageNumber == _showPageNumber).length() > 0) {
					markXML.list.bookmark.(@pageNumber == _showPageNumber).@title = bookMarkPanel_mc.title_txt.text;
					markXML.list.bookmark.(@pageNumber == _showPageNumber).@text = bookMarkPanel_mc.text_txt.text;
					markXML.list.bookmark.(@pageNumber == _showPageNumber).@thisDate = myDate.fullYear + "/" + (myDate.month + 1) + "/" + myDate.date;
					//_pageNumber = -1;
				}else {
					//新增XML
					var _x:XML = <bookmark title={bookMarkPanel_mc.title_txt.text} text={bookMarkPanel_mc.text_txt.text} pageNumber={_pageNumber} thisDate={myDate.fullYear + "/" + (myDate.month + 1) + "/" + myDate.date} />;
					markXML.list.appendChild(_x);
				}
				dispatchEvent(new Event("renew_list"));
				//XML存檔
				saveXML();
				//關閉
				closeMarkPanel();
				//更新列表
				loadBookMark();
			}else if (e.target.name == "close_btn") {	//取消
				closeMarkPanel();
			}
		}
		
		//XML存檔
		private function saveXML():void {
			var fileXML = new File(File.applicationDirectory.resolvePath(xmlURL.url).nativePath);
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(fileXML, FileMode.WRITE);
			fileStream.writeUTFBytes(markXML); 
			fileStream.close();
		}
		
		//關閉新增書籤面板
		private function closeMarkPanel():void {
			bookMarkPanel_mc.visible = false;
			bookMarkPanel_mc.title_txt.text = "";
			bookMarkPanel_mc.text_txt.text = "";
		}
		
		//跳出新增書籤面板
		private function newMark(e:MouseEvent):void 
		{
			bookMarkPanel_mc.visible = true;
			//顯示目前頁碼
			_showPageNumber = _pageNumber;
			bookMarkPanel_mc.page_txt.text = String(_showPageNumber + 1);
		}
		
		//刪除勾選的條列
		private function deleteMark(e:MouseEvent):void 
		{
			var _l:BookMarkListBtn;
			var _ln:int = list_mc.numChildren;
			//若list_mc不是空的才檢查勾選框
			if (_ln > 0) {
				for (var j:int = 0; j < _ln; j++) {
					_l = list_mc.getChildAt(j) as BookMarkListBtn;
					if (_l.checkBox_mc.currentFrameLabel == "1") {
						//刪除有勾選的條列
						delete markXML.list.bookmark.(@pageNumber == _l.name)[0];
						list_mc.removeChild(_l);
						_ln--;
						j--;
					}
				}
				//XML存檔
				saveXML();
				//更新列表
				loadBookMark();
				dispatchEvent(new Event("delete_list"));
			}
		}
		
		//刪除所有條列
		private function allDeleteMark(e:MouseEvent):void 
		{
			//清空書籤
			delete markXML.list.*;
			//XML存檔
			saveXML();
			//更新列表
			loadBookMark();
			dispatchEvent(new Event("delete_list"));
		}
		
		private function goClose(e:Event):void 
		{	
			//parent.removeChild(this);
			this.visible = false;
		}
		
		private function kill(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
			var _l:BookMarkListBtn;
			var _ln:int = list_mc.numChildren;
			//若list_mc不是空的就先清空
			if (_ln > 0) {
				for (var j:int = 0; j < _ln; j++) {
					_l = list_mc.getChildAt(0) as BookMarkListBtn;
					_l.removeEventListener(MouseEvent.CLICK, listBtn);
					list_mc.removeChild(_l);
				}
			}
			deleteMark_btn.removeEventListener(MouseEvent.CLICK, deleteMark);
			allDeleteMark_btn.removeEventListener(MouseEvent.CLICK, allDeleteMark);
			newMark_btn.removeEventListener(MouseEvent.CLICK, newMark);
			bookMarkPanel_mc.removeEventListener(MouseEvent.CLICK, markPanel);
			close_btn.removeEventListener(MouseEvent.CLICK, goClose);
			stage.removeEventListener(LoadingPageEvent.START_TURN_PAGE, goClose);
		}
		
		//傳出使用者點選要前往的書籤頁碼
		public function get showPageNumber():int 
		{
			return _showPageNumber;
		}
		
		//傳入使用者目前的頁碼
		public function set pageNumber(value:int):void 
		{
			_pageNumber = value;
		}
		
		//傳出書籤XML
		public function get getMarkXML():XML {
			return markXML;
		}
		
		//顯示模式
		public function set showMode(value:String):void 
		{
			_showMode = value;
			if (_showMode == "only") {
				bookMarkList_mc.visible = false;
			}else {
				bookMarkList_mc.visible = true;
			}
		}
		
		//接收目前的存檔名稱並且存檔
		public function set fireNameSave(value:String):void 
		{
			_fireName = value.slice(0,value.indexOf("."));
			xmlURL.url = _fireName + _url;
			trace("====bm.fireName:",xmlURL.url);
			saveXML();
		}
		
		//接收目前的存檔名稱並且載入檔案
		public function set fireNameLoad(value:String):void 
		{
			_fireName = value.slice(0,value.indexOf("."));
			initBookMark(_fireName);
			loadBookMark();
		}
		
		private function errorHandler(e:IOErrorEvent):void {
			markXML = <content><list></list></content>;
            trace("Had problem loading the XML File.",markXML);
        }
	}
	/*打開bookMarkPanel_mc有兩種方式
	一種是點新增書籤,這時_showPageNumber=一開始傳進來的pageNumber,也就是使用者目前所在頁面.
	一種是點書籤列表的"備忘"按鈕或是點書本左上角的書籤圖示,這時_showPageNumber=傳入lookbookMark的數字*/
}