package As 
{
	import As.Events.LoadingPageEvent;
	import caurina.transitions.Tweener;
	import com.foxaweb.pageflip.PageFlip;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class LoadingPage extends Sprite 
	{
		private var pageXML:XML;
		private var xmlURL:URLRequest = new URLRequest("config_page.xml");
		private var xmlLoader:URLLoader = new URLLoader();
		
		private var bookLoader:Loader = new Loader();
		private var bookUrl:URLRequest = new URLRequest();
		private var bookNum:int = 0;		//紀錄目前載入到第幾頁,每次載入六頁(顯示的頁面及前後兩頁)
		private var _bookNowPage:int = 6;	//目前頁面號碼
		
		//放載入進來的頁面
		private var bookVector:Vector.<MovieClip> = new Vector.<MovieClip>();
		private var backLeftPage:MovieClip = new MovieClip();
		private var frontRightPage:MovieClip = new MovieClip();
		private var backRightPage:MovieClip = new MovieClip();
		private var frontLeftPage:MovieClip = new MovieClip();
		
		private var _render:Shape = new Shape();
		private var page0:BitmapData; 
		private var page1:BitmapData; 
		private var mousePoint:Point = new Point();				//記錄放開書頁時的滑鼠位置
		private var dragPoint:Point;							//翻書的起始點(左下或右下)
		private var autoTurnPagePoint:Point = new Point();;		//書頁自動恢復的位置(翻左頁跟右頁不同)
		private var autoTurnPageTxt:String;						//記錄翻書狀態
		private var loadNextList:Array;							//記錄翻頁後要載入的頁面
		
		public function LoadingPage() 
		{
			xmlLoader.addEventListener(Event.COMPLETE, xmlComplete);
			xmlLoader.load(xmlURL);
			
			bookLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bookLoaderComplete);
			bookLoader.contentLoaderInfo.addEventListener(Event.INIT, bookLoaderInit);
			bookLoader.contentLoaderInfo.addEventListener(Event.OPEN, bookLoaderOpen);
			bookLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, bookLoaderError);
			
			addChild(backLeftPage);
			addChild(backRightPage);
			addChild(frontLeftPage);
			addChild(frontRightPage);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, turnPage);
			
		}
		
		//放開書頁
		private function stopTurnPage(e:MouseEvent):void 
		{
			this.removeEventListener(MouseEvent.MOUSE_UP, stopTurnPage);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, startTurnPage);
			this.addEventListener(Event.ENTER_FRAME, autoResumePage);
			mousePoint.x = mouseX;
			mousePoint.y = mouseY;
			//如果是從右翻到左就偏移x,因為右邊的頁面有往右移一頁的寬度,但計算x還是從0開始
			if (dragPoint.x == 1) mousePoint.x -= page0.width;
			
			//檢查是否翻頁成功,以更新bookVector
			if (autoTurnPageTxt == "l_right") {	//trace("翻頁成功L");
				renewBookVectorL();
			}else if (autoTurnPageTxt == "r_left") {	//trace("翻頁成功R");
				renewBookVectorR();
			}
			
			Tweener.addTween(mousePoint, { x:autoTurnPagePoint.x, y:autoTurnPagePoint.y, time:.5, onComplete:finishTweener} );
		}
		private function finishTweener():void 
		{
			this.removeEventListener(Event.ENTER_FRAME, autoResumePage);
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.STOP_TURN_PAGE));
			if (frontLeftPage.numChildren > 0) frontLeftPage.removeChildAt(0);
			if (frontRightPage.numChildren > 0) frontRightPage.removeChildAt(0);
			frontLeftPage.addChild(bookVector[2]);
			frontRightPage.addChild(bookVector[3]);
			removeChild(_render);
		}
		//書頁自動恢復
		private function autoResumePage(e:Event):void 
		{
			goFlip(mousePoint.x, mousePoint.y);
		}
		
		//自動翻頁
		public function autoTurnPage(type:String):void 
		{	
			if (Tweener.isTweening(mousePoint)) return;
			
			if (type == "L") {
				//若是第一頁就return
				if (frontLeftPage.name == "0") return;
				turnRight();
				mousePoint.x = 0;
				mousePoint.y = page0.height;
				changeAutoTurnPage("l_right");
			}else if (type == "R") {
				//若是最後一頁就return
				if (int(frontRightPage.name) == pageXML.book.page.length() - 1) return;
				turnLeft();
				mousePoint.x = page0.width;
				mousePoint.y = page0.height;
				changeAutoTurnPage("r_left");
			}
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.START_TURN_PAGE));
			addChild(_render);	//顯示翻書
			this.addEventListener(Event.ENTER_FRAME, autoResumePage);
			Tweener.addTween(mousePoint, { x:autoTurnPagePoint.x, time:.5, onComplete:finishAutoTurnPage} );
		}
		private function finishAutoTurnPage():void 
		{	
			if (autoTurnPageTxt == "l_right") {
				renewBookVectorL();
			}else if (autoTurnPageTxt == "r_left") {
				renewBookVectorR();
			}
			finishTweener();
		}
		
		//按下書頁,開始翻頁
		private function turnPage(e:MouseEvent):void 
		{
			//如果翻頁動作中就return
			if (Tweener.isTweening(mousePoint)) return;
			//觸發翻書的位置在左下跟右下,如果在範圍外就return
			if ((mouseX > 100 && mouseX < page0.width * 2 - 100) || mouseY < page0.height - 100) return;
			
			this.removeEventListener(Event.ENTER_FRAME, autoResumePage);
			if (mouseX < page0.width) {	//左下
				//若是第一頁就return
				if (frontLeftPage.name == "0") return;
				turnRight();
			}else {	//右下
				//若是最後一頁就return
				if (int(frontRightPage.name) == pageXML.book.page.length() - 1) return;
				turnLeft();
			}
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.START_TURN_PAGE));
			autoTurnPageTxt = "";
			this.addEventListener(MouseEvent.MOUSE_UP, stopTurnPage);
			addChild(_render);	//顯示翻書
			goFlip(mouseX - _render.x, mouseY);
			this.addEventListener(MouseEvent.MOUSE_MOVE, startTurnPage);
		}
		//繪製翻頁效果
		private function startTurnPage(e:MouseEvent):void 
		{
			goFlip(mouseX - _render.x, mouseY);
			//判斷是否達到翻頁標準
			if (dragPoint.x == 0) {	//從左翻到右
				if (mouseX < page0.width) {	
					changeAutoTurnPage("l_left");
				}else {	
					changeAutoTurnPage("l_right");
				}
			}else if (dragPoint.x == 1){	//從右翻到左
				if (mouseX < page0.width) {	
					changeAutoTurnPage("r_left");
				}else {	
					changeAutoTurnPage("r_right");
				}
			}
		}
		//左翻或右翻頁面自動恢復的位置不同
		private function changeAutoTurnPage(_s:String) {
			if (_s == "l_left") {
				autoTurnPagePoint.x = 0;
				autoTurnPagePoint.y = page0.height;
			}else if (_s == "l_right") {
				autoTurnPagePoint.x = page0.width * 2;
				autoTurnPagePoint.y = page0.height;
			}else if (_s == "r_left") {
				autoTurnPagePoint.x = -page0.width;
				autoTurnPagePoint.y = page0.height;
			}else if (_s == "r_right") {
				autoTurnPagePoint.x = page0.width;
				autoTurnPagePoint.y = page0.height;
			}
			autoTurnPageTxt = _s;
		}
		
		//顯示下一頁,繪製翻頁畫面,開始翻頁時要做的事情
		private function turnLeft():void 
		{
			if (backRightPage.numChildren > 0) backRightPage.removeChildAt(0);
			backRightPage.addChild(bookVector[5]);
			page0.draw(frontRightPage);
			if(frontRightPage.numChildren > 0) frontRightPage.removeChildAt(0);
			page1.draw(bookVector[4]);
			
			dragPoint = new Point(1, 1);
			_render.x = page0.width;
			autoTurnPagePoint.x = page0.width;
			autoTurnPagePoint.y = page0.height;
		}
		private function turnRight():void 
		{	
			if (backLeftPage.numChildren > 0) backLeftPage.removeChildAt(0);
			backLeftPage.addChild(bookVector[0]);	
			page0.draw(frontLeftPage);
			if (frontLeftPage.numChildren > 0) frontLeftPage.removeChildAt(0);
			page1.draw(bookVector[1]);
			
			dragPoint = new Point(0, 1);
			_render.x = 0;
			autoTurnPagePoint.x = 0;
			autoTurnPagePoint.y = page0.height;
		}
		
		//更新存放頁面的bookVector陣列,確定翻書成功之後要做的事情
		private function renewBookVectorR():void 
		{
			bookVector[0] = bookVector[2];
			bookVector[1] = bookVector[3];
			bookVector[2] = bookVector[4];
			bookVector[3] = bookVector[5];
			frontLeftPage.name = String(int(frontLeftPage.name) + 2);
			frontRightPage.name = String(int(frontRightPage.name) + 2);
			_bookNowPage = int(frontLeftPage.name);
			if (int(frontRightPage.name) + 2 <= pageXML.book.page.length()) {
				loadNextList = [int(frontLeftPage.name) + 2, int(frontRightPage.name) + 2];
				loadNextPage();
			}else {
				bookVector[4] = null;
				bookVector[5] = null;
			}
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.STOP_TURN_PAGE_AND_CHANGE));
		}
		private function renewBookVectorL():void 
		{
			bookVector[4] = bookVector[2];
			bookVector[5] = bookVector[3];
			bookVector[2] = bookVector[0];
			bookVector[3] = bookVector[1];
			frontLeftPage.name = String(int(frontLeftPage.name) - 2);
			frontRightPage.name = String(int(frontRightPage.name) - 2);
			_bookNowPage = int(frontLeftPage.name);
			if (int(frontLeftPage.name) - 2 >= 0) {
				loadNextList = [int(frontLeftPage.name) - 2, int(frontRightPage.name) - 2];
				loadNextPage();
			}else {
				bookVector[0] = null;
				bookVector[1] = null;
			}
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.STOP_TURN_PAGE_AND_CHANGE));
		}
		
		//載入下一個或上一個頁面(維持六面)
		private function loadNextPage():void 
		{
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.LOAD_OPEN));
			bookLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadNextPageComplete);
			bookUrl.url = pageXML.book.page[loadNextList.shift()].@pageUrl;
			bookLoader.load(bookUrl);
		}
		private function loadNextPageComplete(e:Event):void 
		{
			if (autoTurnPageTxt == "l_right") {
				if (loadNextList.length >= 1) {	//載入第一個
					bookVector[0] = bookLoader.content as MovieClip;
					bookUrl.url = pageXML.book.page[loadNextList.shift()].@pageUrl;
					bookLoader.load(bookUrl);
				}else {	//載入第二個
					bookVector[1] = bookLoader.content as MovieClip;
					bookLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadNextPageComplete);
					stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.LOAD_COMPLETE));
				}
			}else if (autoTurnPageTxt == "r_left") {
				if (loadNextList.length >= 1) {	//載入第一個
					bookVector[4] = bookLoader.content as MovieClip;
					bookUrl.url = pageXML.book.page[loadNextList.shift()].@pageUrl;
					bookLoader.load(bookUrl);
				}else {	//載入第二個
					bookVector[5] = bookLoader.content as MovieClip;
					bookLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadNextPageComplete);
					stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.LOAD_COMPLETE));
				}
			}
		}
		
		private function xmlComplete(e:Event):void 
		{
			xmlLoader.removeEventListener(Event.COMPLETE, xmlComplete);
			pageXML = XML(xmlLoader.data);
			trace("LoadingPage:", pageXML.book.page.length(), pageXML.book.page[0].@pageUrl);
			
			//若一開始載入第一頁,bookVector就從第2個位置開始放載入的頁面(因為沒有上一頁)
			if (_bookNowPage == 0) {
				bookNum = 2;
				bookVector[0] = null;
				bookVector[1] = null;
			}
			//從要開啟的頁面的前一頁開始載入
			if (_bookNowPage >= 2){
				_bookNowPage -= 2;
			}
			
			backRightPage.x = pageXML.@width;
			frontRightPage.x = pageXML.@width;
			
			page0 = new BitmapData(pageXML.@width, pageXML.@height, false);
			page1 = new BitmapData(pageXML.@width, pageXML.@height, false);
			//開始載入頁面
			startLoadingPage();
		}
		
		//開始載入頁面
		private function startLoadingPage():void 
		{
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.LOAD_OPEN));
			bookUrl.url = pageXML.book.page[_bookNowPage].@pageUrl;
			bookLoader.load(bookUrl);
		}
		
		private function bookLoaderComplete(e:Event):void 
		{	
			bookVector[bookNum] = bookLoader.content as MovieClip;
			//addChild(bookVector[_bookNowPage]);
			if (bookNum == 2) {
				if (frontLeftPage.numChildren > 0) frontLeftPage.removeChildAt(0);
				frontLeftPage.addChild(bookVector[bookNum]);
				frontLeftPage.name = String(_bookNowPage);
			}else if (bookNum == 3) {
				if (frontRightPage.numChildren > 0) frontRightPage.removeChildAt(0);
				frontRightPage.addChild(bookVector[bookNum]);
				frontRightPage.name = String(_bookNowPage);
			}
			//載入未滿六頁而且還有頁面可以載入
			if (bookNum < 5 && _bookNowPage+1 < pageXML.book.page.length()) {
				bookNum++;
				_bookNowPage++;
				startLoadingPage();
			}else {
				//bookVector[_bookNowPage].x = bookVector[_bookNowPage].width;
				_bookNowPage = int(frontLeftPage.name);
				bookNum = 1;
				bookLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, bookLoaderComplete);
				stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.LOAD_COMPLETE));
				stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.STOP_TURN_PAGE));
			}
		}
		
		private function bookLoaderError(e:IOErrorEvent):void 
		{
			//trace("====IOErrorEvent");
		}
		
		private function bookLoaderOpen(e:Event):void 
		{
			//trace("===bookLoaderOpen");
		}
		
		private function bookLoaderInit(e:Event):void 
		{
			//trace("===bookLoaderInit");
		}
		
		public function get bookNowPage():int 
		{
			return _bookNowPage;
		}
		
		public function get pageDataXML():XML 
		{
			return pageXML;
		}
		
		public function gotoPage(_n:int):void{
			_bookNowPage = _n;
			bookNum = 0;
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.STOP_TURN_PAGE_AND_CHANGE));
			xmlComplete(null);
			bookLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bookLoaderComplete);
			stage.dispatchEvent(new LoadingPageEvent(LoadingPageEvent.STOP_TURN_PAGE));
		}
		
		private function goFlip(_x:Number = 20, _y:Number = 20):void {
			_render.graphics.clear(); 
			var o:Object=PageFlip.computeFlip(	new Point(_x, _y),	// flipped point
									dragPoint,		// of bottom-right corner
									page0.width,		// size of the sheet
									page1.height,
									true,					// in horizontal mode
									1);					// sensibility to one 
           //trace(o.pPoints);
			PageFlip.drawBitmapSheet(o,					// computeflip returned object
									_render,					// target
									page0,		// bitmap page 0
									page1);		// bitmap page 1
			
			//renderArray = o.pPoints;
		}
	}
}