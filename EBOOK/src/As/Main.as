package As
{
	import As.Events.UndoManagerEvent;
	import avmplus.getQualifiedSuperclassName;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
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
		private var bookUrl:URLRequest = new URLRequest("book1.swf");
		public static var _undo:UndoManager=new UndoManager();
        public static var _redo:UndoManager=new UndoManager();     
		
		private var eBookDataSharedObject:SharedObject = SharedObject.getLocal("eBookData");
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(new Stats());
			trace(Capabilities.version, Capabilities.isDebugger, Capabilities.manufacturer);
			
			bookLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			bookLoader.load(bookUrl);
			pdf_mc.addChild(bookLoader);
			
			canvas_mc = new Canvas();
			addChild(canvas_mc);
			stage.addEventListener(UndoManagerEvent.PUSH_UNDO, goPushUndo);
			stage.addEventListener(UndoManagerEvent.CLEAR_REDO, goClearRedo);
			
			floating = new FloatingMemo();
			addChild(floating);
			
			goEvent();
			
			goCheckSave();
		}
		
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
		private function goCheckSave():void 
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
		}
		
		private function goEvent():void {
			zoomIn_mc.addEventListener(MouseEvent.CLICK, zoomInStart);
			draw_mc.addEventListener(MouseEvent.CLICK, drawStart);
			pick_mc.addEventListener(MouseEvent.CLICK, pickStart);
			ctrlZ_mc.addEventListener(MouseEvent.CLICK, ctrlZ);
			ctrlY_mc.addEventListener(MouseEvent.CLICK, ctrlY);
			eraser_mc.addEventListener(MouseEvent.CLICK, eraserStart);
			memo_mc.addEventListener(MouseEvent.CLICK, memoStart);
			save_mc.addEventListener(MouseEvent.CLICK, saveCanvas);
		}
		
		private function saveCanvas(e:MouseEvent):void 
		{
			eBookDataSharedObject.data.graphicsData = canvas_mc.goSave();
			eBookDataSharedObject.data.memoData = floating.goSave();
			
			/*trace(Memo(floating.getChildAt(0)).getData());
			var _m:Memo = new Memo(pdf_mc,Memo(floating.getChildAt(0)).getData());
			floating.addChild(_m);*/
			
			eBookDataSharedObject.flush();	//存入SharedObject
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
			draw_mc.removeEventListener(MouseEvent.CLICK, drawStart);
			canvas_mc.mouseChildren = false;
			canvas_mc.mouseEnabled = false;
			floating.mouseChildren = false;
			floating.mouseEnabled = false;
			pencil = new MouseDraw(pdf_mc, canvas_mc, 10, "a"); trace("Main:",pdf_mc.numChildren);
			pdf_mc.addChild(pencil);
			 trace("Main:",pdf_mc.numChildren);
		}
		
		//放大
		private function zoomInStart(e:MouseEvent):void 
		{ trace("zoomInStart!!!", this, rz);
			changeTool();
			zoomIn_mc.removeEventListener(MouseEvent.CLICK, zoomInStart);
			canvas_mc.mouseChildren = false;
			canvas_mc.mouseEnabled = false;
			floating.mouseChildren = false;
			floating.mouseEnabled = false;
			rz = new RectangleZoom(pdf_mc);
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
			canvas_mc.mouseChildren = true;
			canvas_mc.mouseEnabled = true;
			floating.mouseChildren = true;
			floating.mouseEnabled = true;
		}
	}
	
}