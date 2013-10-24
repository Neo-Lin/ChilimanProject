package As
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Main extends Sprite 
	{
		private var canvas_mc:Canvas;	//畫布,undo,redo
		private var rz:RectangleZoom;	//放大功能
		private var pencil:MouseDraw;	//畫筆功能
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(new Stats());
			
			canvas_mc = new Canvas();
			addChild(canvas_mc);
			
			goEvent();
		}
		
		private function goEvent():void {
			zoomIn_mc.addEventListener(MouseEvent.CLICK, zoomInStart);
			draw_mc.addEventListener(MouseEvent.CLICK, drawStart);
			pick_mc.addEventListener(MouseEvent.CLICK, pickStart);
			ctrlZ_mc.addEventListener(MouseEvent.CLICK, ctrlZ);
			ctrlY_mc.addEventListener(MouseEvent.CLICK, ctrlY);
			eraser_mc.addEventListener(MouseEvent.CLICK, eraserStart);
			memo_mc.addEventListener(MouseEvent.CLICK, memoStart);
		}
		
		private function memoStart(e:MouseEvent):void 
		{
			changeTool();
			var _m:Memo = new Memo();
			_m.x = 200;
			_m.y = 200;
			addChild(_m);
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
			canvas_mc.ctrlY();
		}
		
		//上一步
		private function ctrlZ(e:MouseEvent):void 
		{
			canvas_mc.ctrlZ();
		}
		
		//選擇工具
		private function pickStart(e:MouseEvent):void 
		{
			changeTool();
			canvas_mc.mouseChildren = true;
			canvas_mc.mouseEnabled = true;
		}
		
		//畫圖
		private function drawStart(e:MouseEvent):void 
		{
			changeTool();
			draw_mc.removeEventListener(MouseEvent.CLICK, drawStart);
			canvas_mc.mouseChildren = false;
			canvas_mc.mouseEnabled = false;
			pencil = new MouseDraw(pdf_mc, canvas_mc, 10, "a"); trace("Main:",pdf_mc.numChildren);
			pdf_mc.addChild(pencil);
			 trace("Main:",pdf_mc.numChildren);
		}
		
		//放大
		private function zoomInStart(e:MouseEvent):void 
		{ trace("zoomInStart!!!", this, rz);
			changeTool();
			zoomIn_mc.removeEventListener(MouseEvent.CLICK, zoomInStart);
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
		}
	}
	
}