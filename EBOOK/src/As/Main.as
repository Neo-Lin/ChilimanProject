package As
{
	import As.Events.LoadingPageEvent;
	import As.Events.UndoManagerEvent;
	import avmplus.getQualifiedSuperclassName;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
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
		private var rz:RectangleZoom;	//放大功能
		private var pencil:MouseDraw;	//畫筆功能
		private var bookLoader:Loader = new Loader();
		private var bookUrl:URLRequest = new URLRequest("book1_1.swf");
		public static var _undo:UndoManager=new UndoManager();
        public static var _redo:UndoManager = new UndoManager();   
		private var loadingPage:LoadingPage;
		private var allPageData:Array = [];
		
		//private var eBookDataSharedObject:SharedObject = SharedObject.getLocal("eBookData");
		private var saveFile:File;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			//stage.nativeWindow.maximize();
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(LoadingPageEvent.LOAD_OPEN, showLoadingBar);
			stage.addEventListener(LoadingPageEvent.LOAD_COMPLETE, hideLoadingBar);
			stage.addEventListener(LoadingPageEvent.START_TURN_PAGE, hideCanvas);
			stage.addEventListener(LoadingPageEvent.STOP_TURN_PAGE, showCanvas);
			stage.addEventListener(LoadingPageEvent.STOP_TURN_PAGE_AND_CHANGE, changeCanvas);
			
			trace(Capabilities.version, Capabilities.isDebugger, Capabilities.manufacturer);
			
			/*bookLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			bookLoader.load(bookUrl);
			pdf_mc.addChild(bookLoader);*/
			
			//載入書本
			loadingPage = new LoadingPage();
			loadingPage.x = 17;
			loadingPage.y = 10;
			addChild(loadingPage);
			
			canvas_mc = new Canvas();
			addChild(canvas_mc);
			stage.addEventListener(UndoManagerEvent.PUSH_UNDO, goPushUndo);
			stage.addEventListener(UndoManagerEvent.CLEAR_REDO, goClearRedo);
			
			floating = new FloatingMemo();
			addChild(floating);
			
			followMouse_mc.mouseEnabled = false;
			
			addChild(new Stats());
			
			goEvent();
			
			//goCheckSave();
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
			floating.visible = canvas_mc.visible = false;
			allPageData = loadFileWindows_mc.saveArray;	 
			if (allPageData) {
				allPageData[loadingPage.bookNowPage] = [canvas_mc.goSave(), floating.goSave()];
			}
		}
		private function showCanvas(e:LoadingPageEvent):void 
		{
			floating.visible = canvas_mc.visible = true;
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
		
		//還原存檔的繪圖
		/*private function goCheckSave():void 
		{
			saveFile = new File(File.applicationDirectory.resolvePath("save/eBookData.ebk").nativePath);
			trace("還原存檔繪圖=============", saveFile.exists, File.applicationStorageDirectory.nativePath, File.applicationDirectory.nativePath);
			if (saveFile.exists) {	 //如果檔案存在
				var fileStream:FileStream = new FileStream(); 
				//開啟為讀取狀態
				fileStream.open(saveFile, FileMode.READ); 
				//讀檔
				var _a:Array = fileStream.readObject(); 
				fileStream.close();
				//還原存檔的繪圖
				if (_a[0].length > 0) {
					canvas_mc.reDrawSave(_a[0]);
				}
				if (_a[1].length > 0) {
					floating.reDrawSave(_a[1]);
				}
			}
		}	*/
			
		private function goPushUndo(e:UndoManagerEvent):void 
		{	
			if(_redo.canRedo()) _redo.clearRedo();
			_undo.pushUndo(e.tfo);
		}
		
		private function goClearRedo(e:UndoManagerEvent):void 
		{
			_redo.clearRedo();
		}
		
		//還原存檔的繪圖
		/*private function goCheckSave():void 
		{
			var eBookDataSharedObject:SharedObject = SharedObject.getLocal("eBookData");
			if (eBookDataSharedObject.data.graphicsData) {
				canvas_mc.reDrawSave(eBookDataSharedObject.data.graphicsData);
			}
			if (eBookDataSharedObject.data.memoData) {
				floating.reDrawSave(eBookDataSharedObject.data.memoData);
			}
		}
		
		private function loader_complete(e:Event):void 
		{
			var _lmc:MovieClip = e.currentTarget.content as MovieClip;
			var _n:uint = _lmc.numChildren;		
			for (var i = 0; i < _n; i++) {
				var _mc:Object = _lmc.getChildAt(i) as Object;
				//trace(getQualifiedSuperclassName(_mc));
				if (getQualifiedSuperclassName(_mc) == "flash.display::InteractiveObject") {
					trace(_mc.name);
				}else if (getQualifiedSuperclassName(_mc) == "flash.display::MovieClip") {
					trace(_mc.name);
				}
			}
		}*/
		
		private function goEvent():void {
			zoomIn_btn.addEventListener(MouseEvent.CLICK, zoomInStart);
			draw_btn.addEventListener(MouseEvent.CLICK, drawStart);
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
			/*eBookDataSharedObject.data.graphicsData = canvas_mc.goSave();
			eBookDataSharedObject.data.memoData = floating.goSave();
			eBookDataSharedObject.flush()*/;	//存入SharedObject
			
			allPageData[loadingPage.bookNowPage] = [canvas_mc.goSave(), floating.goSave()];
			saveFileWindows_mc.saveArray = allPageData;
			saveFileWindows_mc.initLine();
			addChild(saveFileWindows_mc);
			saveFileWindows_mc.visible = true;
		}
		
		//讀取舊檔
		private function loadCanvas(e:MouseEvent):void 
		{
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
			//還原存檔的繪圖
			if (allPageData && allPageData[loadingPage.bookNowPage]) {
				if (allPageData[loadingPage.bookNowPage][0].length > 0) {
					canvas_mc.reDrawSave(allPageData[loadingPage.bookNowPage][0]);
				}
				if (allPageData[loadingPage.bookNowPage][1].length > 0) {
					floating.reDrawSave(allPageData[loadingPage.bookNowPage][1]);
				}
			}
		}
		
		private function memoStart(e:MouseEvent):void 
		{
			changeTool();
			var _m:Memo = new Memo(pdf_mc);
			_m.x = 200;
			_m.y = 200;
			floating.addChild(_m);
		}
		
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
		
		//畫圖
		private function drawStart(e:MouseEvent):void 
		{	
			changeTool();
			changeMouse("draw");
			//draw_btn.removeEventListener(MouseEvent.CLICK, drawStart);
			canvas_mc.mouseChildren = false;
			canvas_mc.mouseEnabled = false;
			floating.mouseChildren = false;
			floating.mouseEnabled = false;
			addChild(drawPanel_mc);
			drawPanel_mc.visible = true;
			pencil = new MouseDraw(loadingPage, canvas_mc, 10, "a", drawPanel_mc); trace("Main:",pdf_mc.numChildren);
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
				pdf_mc.removeChild(pencil);
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
			changeMouse();
			canvas_mc.mouseChildren = true;
			canvas_mc.mouseEnabled = true;
			floating.mouseChildren = true;
			floating.mouseEnabled = true;
		}
		
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
	}
	
}