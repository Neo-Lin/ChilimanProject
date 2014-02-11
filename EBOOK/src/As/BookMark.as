package As 
{
	import flash.display.Sprite;
	import flash.events.Event;
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
		private var showPageNumber:int;
		private var markXML:XML;
		private var xmlURL:URLRequest = new URLRequest("bookmark.xml");
		private var xmlLoader:URLLoader = new URLLoader();
		
		public function BookMark(pageNumber:int) 
		{
			xmlLoader.addEventListener(Event.COMPLETE, xmlComplete);
			xmlLoader.load(xmlURL);
			
			_pageNumber = pageNumber;
		}
		
		private function xmlComplete(e:Event):void 
		{
			xmlLoader.removeEventListener(Event.COMPLETE, xmlComplete);
			markXML = XML(xmlLoader.data);
			trace("BookMark:::::", markXML.list.length(), markXML.list.bookmark.length(), markXML.list.bookmark.(@pageNumber == _pageNumber).length());
			
			deleteMark_btn.addEventListener(MouseEvent.CLICK, deleteMark);
			allDeleteMark_btn.addEventListener(MouseEvent.CLICK, allDeleteMark);
			newMark_btn.addEventListener(MouseEvent.CLICK, newMark);
			bookMarkPanel_mc.addEventListener(MouseEvent.CLICK, markPanel);
			close_btn.addEventListener(MouseEvent.CLICK, goClose);
			
			loadBookMark();
		}
		
		//更新列表
		private function loadBookMark():void 
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
				_l.name = _l.pageNumber_txt.text = markXML.list.bookmark[i].@pageNumber;
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
		
		//條列按鈕功能
		private function listBtn(e:MouseEvent):void 
		{
			if (e.target.name == "checkBox_mc") {	//勾選
				if (e.target.currentFrameLabel == "0") {
					e.target.gotoAndStop(4);
				}else {
					e.target.gotoAndStop(0);
				}
			}else if (e.target.name == "go_btn") {	//前往書籤
				
			}else if (e.target.name == "show_btn") {	//查看書籤內容
				showPageNumber = int(e.currentTarget.name);
				bookMarkPanel_mc.visible = true;
				bookMarkPanel_mc.page_txt.text = showPageNumber + 1;
				bookMarkPanel_mc.title_txt.text = markXML.list.bookmark.(@pageNumber == showPageNumber).@title;
				bookMarkPanel_mc.text_txt.text = markXML.list.bookmark.(@pageNumber == showPageNumber).@text;
			}
		}
		
		//新增書籤面板功能
		private function markPanel(e:MouseEvent):void 
		{
			if (e.target.name == "ok_btn") {	//確定
				//若有加入過書籤就覆蓋並關閉
				if (markXML.list.bookmark.(@pageNumber == showPageNumber).length() >= 1) {
					markXML.list.bookmark.(@pageNumber == showPageNumber).@title = bookMarkPanel_mc.title_txt.text;
					markXML.list.bookmark.(@pageNumber == showPageNumber).@text = bookMarkPanel_mc.text_txt.text;
					showPageNumber = -1;
				}else {
					//新增XML
					var _x:XML = <bookmark title={bookMarkPanel_mc.title_txt.text} text={bookMarkPanel_mc.text_txt.text} pageNumber={_pageNumber} />;
					markXML.list.appendChild(_x);
				}
				
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
			var fileXML = new File(File.applicationDirectory.resolvePath("bookmark.xml").nativePath);
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
			bookMarkPanel_mc.page_txt.text = _pageNumber + 1;
		}
		
		private function deleteMark(e:MouseEvent):void 
		{
			
		}
		
		private function allDeleteMark(e:MouseEvent):void 
		{
			markXML = <content><list></list></content>;
			//XML存檔
			saveXML();
			//更新列表
			loadBookMark();
		}
		
		private function goClose(e:MouseEvent):void 
		{
			parent.removeChild(this);
		}
	}

}