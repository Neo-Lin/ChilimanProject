package As
{
	import As.Events.LoadingPageEvent;
	import As.Events.UndoManagerEvent;
	import avmplus.getQualifiedSuperclassName;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import net.hires.debug.Stats;
	import flashx.undo.UndoManager;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Main extends Sprite 
	{
		private var canvas_mc:Canvas;	//畫布,undo,redo
		private var floating:FloatingMemo;	//覆蓋在畫布上:便利貼
		private var linkManage:LinkManage;
		private var rz:RectangleZoom;	//放大功能
		private var pencil:MouseDraw;	//畫筆功能
		private var bookLoader:Loader = new Loader();
		private var bookUrl:URLRequest = new URLRequest("book1_1.swf");
		public static var _undo:UndoManager=new UndoManager();
        public static var _redo:UndoManager = new UndoManager();   
		private var loadingPage:LoadingPage;	//載入書本頁面
		private var allPageData:Array = [];
		private var bm:BookMark;	//書籤功能
		
		private var saveFile:File;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			//stage.nativeWindow.maximize();
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(LoadingPageEvent.LOAD_OPEN, showLoadingBar);
			stage.addEventListener(LoadingPageEvent.LOAD_COMPLETE, hideLoadingBar);
			stage.addEventListener(LoadingPageEvent.START_TURN_PAGE, hideCanvas);	//開始翻頁隱藏畫布
			stage.addEventListener(LoadingPageEvent.STOP_TURN_PAGE, showCanvas);	//沒有翻頁,顯示畫布
			stage.addEventListener(LoadingPageEvent.STOP_TURN_PAGE_AND_CHANGE, changeCanvas);	//翻頁結束,更新畫布
			
			trace(Capabilities.version, Capabilities.isDebugger, Capabilities.manufacturer);
			
			//載入書本
			loadingPage = new LoadingPage();
			loadingPage.x = 17;
			loadingPage.y = 10;
			addChild(loadingPage);
			
			//書籤功能
			bm = new BookMark();
			bm.addEventListener("go_page", bookMarkGoPage); //前往書籤
			bm.addEventListener("renew_list", goPageListBookMark); //按確定關閉新增書籤面板bookMarkPanel_mc
			bm.addEventListener("delete_list", checkBookMark); //刪除打勾或全部書籤
			tag_mc.addEventListener(MouseEvent.CLICK, showBookMark);
			bm.visible = tag_mc.visible = false;
			bm.x = (stage.stageWidth - bm.width) / 2;
			bm.y = (stage.stageHeight - bm.height) / 2;
			this.addChild(bm);
			this.addChild(tag_mc);
			
			bookListAndMark_mc.pageList_btn.addEventListener(MouseEvent.CLICK, goPageList);
			bookListAndMark_mc.bookmark_btn.addEventListener(MouseEvent.CLICK, goPageListBookMark);
			
			canvas_mc = new Canvas();
			addChild(canvas_mc);
			stage.addEventListener(UndoManagerEvent.PUSH_UNDO, goPushUndo);
			stage.addEventListener(UndoManagerEvent.CLEAR_REDO, goClearRedo);
			
			floating = new FloatingMemo();
			addChild(floating);
			
			linkManage = new LinkManage();
			addChild(linkManage);
			
			followMouse_mc.mouseEnabled = false;
			
			//addChild(new Stats());
			
			goEvent();
		}
		
		//載入頁面繪圖及答案貼
		private function changeCanvas(e:LoadingPageEvent):void 
		{
			startLoadCanvas(null);
		}
		//按下書角開始翻書-隱藏繪圖及答案貼,暫儲存繪圖及答案貼,取消所有使用中工具
		private function hideCanvas(e:LoadingPageEvent):void 
		{
			changeTool();
			linkManage.visible = floating.visible = canvas_mc.visible = tag_mc.visible = false;
			allPageData = loadFileWindows_mc.saveArray;	 
			if (allPageData) {
				allPageData[loadingPage.bookNowPage] = [canvas_mc.goSave(), floating.goSave(), linkManage.goSave()];
			}
		}
		private function showCanvas(e:LoadingPageEvent):void 
		{
			linkManage.visible = floating.visible = canvas_mc.visible = true;
			//檢查有無書籤,有就顯示
			checkBookMark();
		}
		
		//顯示/隱藏載入中圖示
		private function showLoadingBar(e:LoadingPageEvent):void 
		{
			addChild(_bar);
			_bar.visible = true;
		}
		private function hideLoadingBar(e:LoadingPageEvent):void 
		{
			_bar.visible = false;
		}
		
		//增加可復原的步驟紀錄
		private function goPushUndo(e:UndoManagerEvent):void 
		{	
			if(_redo.canRedo()) _redo.clearRedo();
			_undo.pushUndo(e.tfo);
		}
		//刪除可重作的步驟紀錄
		private function goClearRedo(e:UndoManagerEvent):void 
		{
			_redo.clearRedo();
		}
		
		private function goEvent():void {
			zoomIn_btn.addEventListener(MouseEvent.CLICK, zoomInStart);
			draw_btn.addEventListener(MouseEvent.CLICK, drawStart);
			lightPen_btn.addEventListener(MouseEvent.CLICK, drawStart);
			pick_btn.addEventListener(MouseEvent.CLICK, pickStart);
			ctrlZ_btn.addEventListener(MouseEvent.CLICK, ctrlZ);
			ctrlY_btn.addEventListener(MouseEvent.CLICK, ctrlY);
			eraser_btn.addEventListener(MouseEvent.CLICK, eraserStart);
			memo_btn.addEventListener(MouseEvent.CLICK, memoStart);
			save_btn.addEventListener(MouseEvent.CLICK, saveCanvas);
			load_btn.addEventListener(MouseEvent.CLICK, loadCanvas);
			prevPage_btn.addEventListener(MouseEvent.CLICK, goPrevPage);
			nextPage_btn.addEventListener(MouseEvent.CLICK, goNextPage);
			Minimize_btn.addEventListener(MouseEvent.CLICK, goMinimize);
			close_btn.addEventListener(MouseEvent.CLICK, goClose);
			pageList_btn.addEventListener(MouseEvent.CLICK, goPageList);
			bookmark_btn.addEventListener(MouseEvent.CLICK, goBookMark);
			allClear_btn.addEventListener(MouseEvent.CLICK, goAllClear);
			windowsMode_btn.addEventListener(MouseEvent.CLICK, goWindowsMode);
			changeBtnView(windowsMode_btn);
			drawCircle_btn.addEventListener(MouseEvent.CLICK, drawStart);
			link_btn.addEventListener(MouseEvent.CLICK, linkStart);
			spotlight_btn.addEventListener(MouseEvent.CLICK, goSpotlight);
			textMemo_btn.addEventListener(MouseEvent.CLICK, goTextMemo);
		}
		
		//便利貼
		private function goTextMemo(e:MouseEvent):void 
		{
			var tmo:TextMemo = new TextMemo();
			linkManage.addChild(tmo);
		}
		
		//聚光燈
		private function goSpotlight(e:MouseEvent):void 
		{
			var sl:Spotlight = new Spotlight(18, 10, 990, 675);
			addChild(sl);
		}
		
		//連結
		private function linkStart(e:MouseEvent):void 
		{
			var _l:Link = new Link();
			linkManage.addChild(_l);
		}
		
		//視窗模式切換
		private function goWindowsMode(e:MouseEvent):void 
		{
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				//stage.nativeWindow.maximize();
			}else {
				//stage.nativeWindow.restore();
				stage.displayState = StageDisplayState.NORMAL; 
			}
			changeBtnView(e.currentTarget as SimpleButton);
		}
		
		//全部刪除
		private function goAllClear(e:MouseEvent):void 
		{
			var _a = canvas_mc.allClear().concat(floating.allClear());
			var operation:TransformOperation = new TransformOperation(_a, 0, 0, 0, 0, true, false);
			stage.dispatchEvent(new UndoManagerEvent(UndoManagerEvent.PUSH_UNDO, false, operation));
		}
		
		//書籤
		private function goBookMark(e:MouseEvent):void 
		{
			changeTool();
			bm.visible = true
			this.addChild(bm);
			bm.pageNumber = loadingPage.bookNowPage;
			bm.showMode = "";
			bm.loadBookMark();
		}
		private function bookMarkGoPage(e:Event):void 
		{
			loadingPage.gotoPage(e.currentTarget.showPageNumber);
			bm.visible = false;
		}
		//顯示書籤內容
		private function showBookMark(e:MouseEvent):void 
		{
			bm.showMode = "only";
			bm.lookbookMark(loadingPage.bookNowPage);
		}
		//檢查有無書籤,有就顯示
		private function checkBookMark(e:Event = null):void {
			if (bm.getMarkXML.list.bookmark.(@pageNumber == loadingPage.bookNowPage).length() > 0) {
				tag_mc.visible = true;
			}else {
				tag_mc.visible = false;
			}
		}
		
		//目錄
		private function goPageList(e:MouseEvent):void 
		{
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.START_TURN_PAGE));
			loadingPage.visible = false;
			clearList();
			bookListAndMark_mc.bg_mc.gotoAndStop(1);
			var _n:int = loadingPage.pageDataXML.list.lesson.length();
			var _i:int;
			for (var i:int = 0; i < _n; i++) {
				var _l:ListBtn = new ListBtn();
				_l.lessonName_txt.text = loadingPage.pageDataXML.list.lesson[i].@lessonName;
				_i = int(loadingPage.pageDataXML.list.lesson[i].@lessonPageNumber);
				_l.lessonPageNumber_txt.text = loadingPage.pageDataXML.book.page[_i].@pageNumber;
				_l.name = loadingPage.pageDataXML.list.lesson[i].@lessonPageNumber;
				_l.y = 45 * i;
				bookListAndMark_mc.list_mc.addChild(_l);
				_l.addEventListener(MouseEvent.MOUSE_OVER, listBtnMOver);
				_l.addEventListener(MouseEvent.MOUSE_OUT, listBtnMOut);
				_l.addEventListener(MouseEvent.CLICK, listBtnClick);
			}
		}
		private function listBtnClick(e:MouseEvent):void 
		{	
			//若點選書籤的"備忘"按鈕
			if (e.target.name == "show_btn") {
				bm.showMode = "only";
				bm.lookbookMark(e.currentTarget.name);
				return;
			}
			loadingPage.visible = true;
			loadingPage.gotoPage(int(e.currentTarget.name));
		}
		private function listBtnMOver(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop(2);
		}
		private function listBtnMOut(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop(1);
		}
		
		//目錄頁的書籤
		private function goPageListBookMark(e:Event):void 
		{
			clearList();
			bookListAndMark_mc.bg_mc.gotoAndStop(2);
			var _n:int = bm.getMarkXML.list.bookmark.length();
			var _i:int;
			for (var i:int = 0; i < _n; i++) {
				var _l:PageMarkListBtn = new PageMarkListBtn();
				_l.title_txt.text = bm.getMarkXML.list.bookmark[i].@title;
				_l.date_txt.text = bm.getMarkXML.list.bookmark[i].@thisDate;
				_i = int(bm.getMarkXML.list.bookmark[i].@pageNumber);
				_l.pageNumber_txt.text = String(_i+1);
				_l.name = bm.getMarkXML.list.bookmark[i].@pageNumber;
				_l.y = 45 * i;
				bookListAndMark_mc.list_mc.addChild(_l);
				_l.addEventListener(MouseEvent.MOUSE_OVER, listBtnMOver);
				_l.addEventListener(MouseEvent.MOUSE_OUT, listBtnMOut);
				_l.addEventListener(MouseEvent.CLICK, listBtnClick);
			}
			if(loadingPage.visible)	checkBookMark();
		}
		
		//清除bookListAndMark_mc.list_mc
		private function clearList():void {
			var _n:int = bookListAndMark_mc.list_mc.numChildren;
			for (var i:int = 0; i < _n; i++) {
				var _mc:MovieClip = bookListAndMark_mc.list_mc.getChildAt(0);
				bookListAndMark_mc.list_mc.removeChild(_mc);
			}
		}
		
		//上一頁/下一頁
		private function goPrevPage(e:MouseEvent):void 
		{
			loadingPage.autoTurnPage("L");
		}
		private function goNextPage(e:MouseEvent):void 
		{
			loadingPage.autoTurnPage("R");
		}
		
		//存檔
		private function saveCanvas(e:MouseEvent):void 
		{
			changeTool();
			saveFileWindows_mc.bookMark = bm;
			//把goSave()得到的array再包起來,配合現在頁面的編號存在相對應的array格子裡
			allPageData[loadingPage.bookNowPage] = [canvas_mc.goSave(), floating.goSave(), linkManage.goSave()];
			saveFileWindows_mc.saveArray = allPageData;
			saveFileWindows_mc.initLine();
			addChild(saveFileWindows_mc);
			saveFileWindows_mc.visible = true;
		}
		
		//讀取舊檔
		private function loadCanvas(e:MouseEvent):void 
		{
			changeTool();
			loadFileWindows_mc.bookMark = bm;
			loadFileWindows_mc.initLine();
			addChild(loadFileWindows_mc);
			loadFileWindows_mc.visible = true;
			loadFileWindows_mc.addEventListener("you_can_take_array", startLoadCanvas);
		}
		private function startLoadCanvas(e:Event):void 
		{	
			allPageData = loadFileWindows_mc.saveArray;	
			_undo.clearAll();
			_redo.clearAll();
			canvas_mc.canvasRemove();
			floating.memosRemove();
			linkManage.memosRemove();
			//還原存檔的繪圖
			if (allPageData && allPageData[loadingPage.bookNowPage]) {
				if (allPageData[loadingPage.bookNowPage][0].length > 0) {
					canvas_mc.reDrawSave(allPageData[loadingPage.bookNowPage][0]);
				}
				if (allPageData[loadingPage.bookNowPage][1].length > 0) {
					floating.reDrawSave(allPageData[loadingPage.bookNowPage][1]);
				}
				if (allPageData[loadingPage.bookNowPage][2].length > 0) {	//連結,便利貼
					linkManage.reDrawSave(allPageData[loadingPage.bookNowPage][2]);
				}
			}
		}
		
		//答案貼
		private function memoStart(e:MouseEvent):void 
		{
			changeTool();
			var _m:Memo = new Memo(pdf_mc);
			_m.x = 200;
			_m.y = 200;
			floating.addChild(_m);
		}
		
		//橡皮擦
		private function eraserStart(e:MouseEvent):void 
		{
			changeTool();
			changeMouse("eraser");
			addEventListener(Event.ENTER_FRAME, goHitTest);
		}
		private function goHitTest(e:Event):void 
		{
			if (canvas_mc.hitTestPoint(mouseX, mouseY, true)) {
				trace("hit!!!");
				canvas_mc.eraser();
			}
		}
		
		//下一步
		private function ctrlY(e:MouseEvent):void 
		{
			if (_redo.canRedo()) {
				if(!TransformOperation(_redo.peekRedo()).affectObj is Memo) canvas_mc.ctrlY();
				_undo.pushUndo(_redo.peekRedo());
				_redo.redo();
			}
		}
		//上一步
		private function ctrlZ(e:MouseEvent):void 
		{
			if (_undo.canUndo()) {	//trace(TransformOperation(_undo.peekUndo()).affectObj is Memo);
				if(!TransformOperation(_undo.peekUndo()).affectObj is Memo) canvas_mc.ctrlZ();
				_redo.pushRedo(_undo.peekUndo());
				_undo.undo();
			}
		}
		
		//選擇工具
		private function pickStart(e:MouseEvent):void 
		{
			changeTool();
		}
		
		//畫圖 螢光筆
		private function drawStart(e:MouseEvent):void 
		{	
			changeTool();
			changeMouse("draw");
			canvas_mc.mouseChildren = false;
			canvas_mc.mouseEnabled = false;
			floating.mouseChildren = false;
			floating.mouseEnabled = false;
			addChild(drawPanel_mc);
			drawPanel_mc.visible = true;
			if (pencil) {
				pencil.visible = true;
				if (e.currentTarget.name == "lightPen_btn") { //螢光筆
					changeMouse("lightPen");
					pencil.changePenType("b");
				}else if (e.currentTarget.name == "drawCircle_btn") { //圓
					changeMouse("drawCircle");
					pencil.changePenType("c");
				}else {
					pencil.changePenType("a");
				}
			}else if (e.currentTarget.name == "lightPen_btn") { //螢光筆
				changeMouse("lightPen");
				pencil = new MouseDraw(loadingPage, canvas_mc, 10, "b", drawPanel_mc); trace("Main:", pdf_mc.numChildren);
			}else if (e.currentTarget.name == "drawCircle_btn") { //圓
				changeMouse("drawCircle");
				pencil = new MouseDraw(loadingPage, canvas_mc, 10, "c", drawPanel_mc); trace("Main:", pdf_mc.numChildren);
			}else {
				pencil = new MouseDraw(loadingPage, canvas_mc, 10, "a", drawPanel_mc); trace("Main:", pdf_mc.numChildren);
			}
			pdf_mc.addChild(pencil);
			 trace("Main:",pdf_mc.numChildren);
		}
		
		//放大
		private function zoomInStart(e:MouseEvent):void 
		{ trace("zoomInStart!!!", this, rz);
			changeTool();
			changeMouse("zoomIn");
			zoomIn_btn.removeEventListener(MouseEvent.CLICK, zoomInStart);
			canvas_mc.mouseChildren = false;
			canvas_mc.mouseEnabled = false;
			floating.mouseChildren = false;
			floating.mouseEnabled = false;
			rz = new RectangleZoom(loadingPage, followMouse_mc);
			this.addChild(rz);	
			
			trace("Main:", rz.x,this.numChildren);
		}
		
		private function changeTool(e:MouseEvent = null):void 
		{	
			try 
			{ 
				pencil.visible = false;
			} 
			catch (err:Error) 
			{ 
				trace("pdf_mc沒在場景上");
			} 
			try 
			{ 
				this.removeChild(rz);
			} 
			catch (err:Error) 
			{ 
				trace("rz沒在場景上");
			} 
			removeEventListener(Event.ENTER_FRAME, goHitTest);
			goEvent();
			drawPanel_mc.visible = false;
			changeMouse();
			canvas_mc.mouseChildren = true;
			canvas_mc.mouseEnabled = true;
			floating.mouseChildren = true;
			floating.mouseEnabled = true;
		}
		
		//變換鼠標樣式
		private function changeMouse(_s:String = null):void {
			if (!_s) { 
				followMouse_mc.gotoAndStop(1);
				followMouse_mc.visible = false;
				followMouse_mc.x = followMouse_mc.y = 0;
				Mouse.show(); 
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,redrawCursor);
			}else {
				addChild(followMouse_mc);
				stage.addEventListener(MouseEvent.MOUSE_MOVE,redrawCursor); 			
				Mouse.hide(); 
				followMouse_mc.gotoAndStop(_s);
				followMouse_mc.visible = true;
			}
		}
		private function redrawCursor(event:MouseEvent):void 
		{ 
			followMouse_mc.x = event.stageX; 
			followMouse_mc.y = event.stageY; 
		}
		
		//關閉程式
		private function goClose(e:MouseEvent):void 
		{
			stage.nativeWindow.close();
		}
		//最小化程式
		private function goMinimize(e:MouseEvent):void 
		{
			stage.nativeWindow.minimize();
		}
		
		//依據目前視窗模式來改變windowsMode_btn按鈕外觀
		private function changeBtnView(_b:SimpleButton):void {
			if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
				(((_b.upState as Sprite).getChildAt(2)) as MovieClip).visible = false;
				(((_b.overState as Sprite).getChildAt(2)) as MovieClip).visible = false;
				(((_b.downState as Sprite).getChildAt(2)) as MovieClip).visible = false;
				(((_b.upState as Sprite).getChildAt(1)) as MovieClip).visible = true;
				(((_b.overState as Sprite).getChildAt(1)) as MovieClip).visible = true;
				(((_b.downState as Sprite).getChildAt(1)) as MovieClip).visible = true;
			}else {
				(((_b.upState as Sprite).getChildAt(2)) as MovieClip).visible = true;
				(((_b.overState as Sprite).getChildAt(2)) as MovieClip).visible = true;
				(((_b.downState as Sprite).getChildAt(2)) as MovieClip).visible = true;
				(((_b.upState as Sprite).getChildAt(1)) as MovieClip).visible = false;
				(((_b.overState as Sprite).getChildAt(1)) as MovieClip).visible = false;
				(((_b.downState as Sprite).getChildAt(1)) as MovieClip).visible = false;
			}
		}
		
	}
	
}