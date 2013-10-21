package As 
{
	import caurina.transitions.Tweener;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * 把這個類別addChild至場景後,可以使用它的方法,在場景上框出範圍並且放大
	 * @author Splendor
	 */
	public class RectangleZoom extends Sprite
	{
		private var thisParent:DisplayObjectContainer;
		private var rectXY:Point;
		private var rectSave:Shape;
		private var bd:BitmapData;
		private var bm:Bitmap;
		private var startDraw:Boolean = false;  //是否框選過
		
		public function RectangleZoom(_parent:DisplayObjectContainer) //_parent為要框選放大的對象
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			thisParent = _parent;
			this.mouseEnabled = false;
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			thisParent.addEventListener(MouseEvent.MOUSE_DOWN, onMD); 
		}
		
		private function onMD(e:MouseEvent):void 
		{
			thisParent.addEventListener(MouseEvent.MOUSE_UP, onMU);
			if (startDraw) {
				bd.dispose(); 
				this.removeChild(bm);
				startDraw = false;
			}else {
				areaStart();
				thisParent.addEventListener(MouseEvent.MOUSE_MOVE, onMM);
			}
			
		}
		
		private function onMM(e:MouseEvent):void 
		{ 
			areaDraw();
			startDraw = true;
		}
		
		private function onMU(e:MouseEvent):void 
		{ trace("onMU");
			thisParent.removeEventListener(MouseEvent.MOUSE_UP, onMU);
			thisParent.removeEventListener(MouseEvent.MOUSE_MOVE, onMM);
			if(startDraw) areaZoom();
		}
		
		public function areaStart() { 
			//記錄滑鼠開始拖曳位置
			rectXY = new Point();
			rectXY.x = mouseX;
			rectXY.y = mouseY;
		}
		
		public function areaDraw() {
			//畫矩形
			this.graphics.clear();
			this.graphics.lineStyle(2, 0xFFFFFF);
			this.graphics.drawRect(rectXY.x, rectXY.y, this.mouseX - rectXY.x, this.mouseY - rectXY.y);
			//記錄矩形的位置'大小
			rectSave = new Shape();
			rectSave.x = rectXY.x;
			rectSave.y = rectXY.y;
			rectSave.graphics.drawRect(0, 0, this.mouseX - rectXY.x, this.mouseY - rectXY.y);
		}
		
		public function areaZoom() { 
			//記錄滑鼠結束拖曳位置
			rectXY.x = mouseX;
			rectXY.y = mouseY;
			//偏移量
			var myMatrix:Matrix = new Matrix();
            rectSave.x < rectXY.x ? myMatrix.tx = 0-rectSave.x : myMatrix.tx = 0-rectXY.x;
            rectSave.y < rectXY.y ? myMatrix.ty = 0-rectSave.y : myMatrix.ty = 0-rectXY.y;
			//draw出矩形範圍的畫面
			trace("zoom::",this.width);
			bd = new BitmapData(this.width, this.height); 
			this.graphics.clear(); 
			bd.draw(stage, myMatrix);
			bm = new Bitmap(bd);
			bm.smoothing = true;
			this.addChild(bm);
			rectSave.x < rectXY.x ? bm.x = rectSave.x : bm.x = rectXY.x;
			rectSave.y < rectXY.y ? bm.y = rectSave.y : bm.y = rectXY.y;
			//算出放到最大的數值
			rectSave.width = stage.stageWidth;	
			rectSave.scaleY = rectSave.scaleX;
			if (rectSave.height > stage.stageHeight) {
				rectSave.height = stage.stageHeight;
				rectSave.scaleX = rectSave.scaleY;
			}	
			
			Tweener.addTween(bm, { scaleX:rectSave.scaleX, scaleY:rectSave.scaleY, x:(stage.stageWidth-rectSave.width) / 2, y:(stage.stageHeight-rectSave.height) / 2, time:1} );
		}
		
		private function onRemove(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			thisParent.removeEventListener(MouseEvent.MOUSE_DOWN, onMD);
			this.graphics.clear();
			Tweener.removeAllTweens();
			if (startDraw) {
				bd.dispose();
				this.removeChild(bm);
			}
			trace("RectangleZoom remove");
		}
		
	}

}