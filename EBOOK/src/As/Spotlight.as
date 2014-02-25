package As 
{
	import ascb.drawing.Pen;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import ui.FreeTran;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Spotlight extends Sprite 
	{
		//蓋在課本上的半透明黑底
		private var _alphaBmd:BitmapData;
		private var _alphaBm:Bitmap;
		//複製課本圖片
		private var _maskBmd:BitmapData;
		private var _maskBm:Bitmap;
		//遮色片
		private var _mask:Sprite = new Sprite();
		
		private var _point:Point;
		private var _m:Matrix;
		//private var mt:MorphTool = new MorphTool();
		private var mt:FreeTran = new FreeTran();
		private var close_btn:Close_BTN = new Close_BTN();
		
		public function Spotlight(_x:Number, _y:Number, _w:Number, _h:Number) 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			close_btn.width = close_btn.height = 40;
			close_btn.x = _w - 25;
			close_btn.y = _y + 15;
			
			_m = new Matrix(1, 0, 0, 1, -_x, -_y);
			this.x = _x;
			this.y = _y;
			_alphaBmd = new BitmapData(_w, _h, true, 0xdd000000);
			_alphaBm = new Bitmap(_alphaBmd);
			
			_maskBmd = new BitmapData(_w, _h);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_maskBmd.draw(parent, _m);
			_maskBm = new Bitmap(_maskBmd);
			_maskBm.mask = _mask;
			addChild(_alphaBm);
			addChild(_maskBm);
			addChild(_mask);
			addChild(close_btn);
			
			close_btn.addEventListener(MouseEvent.CLICK, kill);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onMouseMove(e:MouseEvent):void 
		{
			var point:int = Point.distance(new Point(), new Point(mouseX - _point.x, mouseY - _point.y));
			var pen:Pen = new Pen(_mask.graphics);
			pen.clear();
			pen.lineStyle(5, 0);
			pen.beginFill(0xFFFFFF);
			pen.drawEllipse(_point.x, _point.y, point, point);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_point = new Point(mouseX, mouseY);
		}
		
		private function onMouseUp(e:MouseEvent):void 
		{
			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			addChild(mt);
			mt.dragPic(_mask);
		}
		
		private function kill(e:MouseEvent):void 
		{
			close_btn.removeEventListener(MouseEvent.CLICK, kill);
			mt.pic = null;
			parent.removeChild(this);
		}
		
	}

}