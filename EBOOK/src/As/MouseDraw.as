package As
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class MouseDraw extends Sprite
	{
		private var _canvas:Canvas;
		private var _drawArea:DisplayObjectContainer;
		private var _panWidth:uint;
		private var _penType:String;
		private var _newSprite:Sprite;
		private var _point:Point;
		
		public function MouseDraw(drawArea:DisplayObjectContainer,canvas:Canvas,panWidth:uint,penType:String)
		{	
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			_drawArea = drawArea;	//可繪圖區域
			_canvas = canvas;		//實際放繪圖的元件
			_panWidth = panWidth;	//畫筆粗
			_penType = penType;		//畫筆類型
			
			_drawArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown1);
		}
		
		private function onMouseDown1(event:MouseEvent):void
		{
			if (stage) {
				_point = new Point(mouseX, mouseY);
				var _s:Sprite = new Sprite
				_newSprite = _s; 
				_newSprite.graphics.lineStyle(_panWidth);
				_newSprite.graphics.moveTo(_point.x, _point.y);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp1);
			}
		}
		
		private function onMouseUp1(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp1);
			if(_newSprite.width > 0) _canvas.canvasAdded();		//如果有畫,請Canvas更新步驟陣列stepArray
			trace("MouseDraw:", _drawArea.numChildren, _canvas.numChildren);
		}
		
		private function onMouseMove1(event:MouseEvent):void
		{
			//畫直虛線
			/*_newSprite.graphics.clear();
			_newSprite.graphics.lineStyle(5);
			drawDashed(_newSprite.graphics, _point, new Point(mouseX, mouseY), 5, 20);*/
			//畫直實線
			/*_newSprite.graphics.clear();
			_newSprite.graphics.lineStyle(5);
			_newSprite.graphics.moveTo(_point.x, _point.y);
			_newSprite.graphics.lineTo(mouseX, mouseY);*/
			//隨便畫
			_newSprite.graphics.lineTo(mouseX, mouseY);
			
			_canvas.addChild(_newSprite);		//把繪圖物件放入Canvas
		}
		
		private function onRemove(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			_drawArea.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown1);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp1);
		}
		
		/**
		 * 畫虛線
		 * 
		 * @param graphics <b> Graphics</b> 
		 * @param beginPoint <b> Point </b> 
		 * @param endPoint <b> Point </b> 
		 * @param width  <b> Number </b> 虛線的長度
		 * @param grap  <b> Number </b> 虛線的空隙
		 */
		static public function drawDashed(graphics:Graphics, beginPoint:Point, endPoint:Point, width:Number, grap:Number):void
		{
		   if (!graphics || !beginPoint || !endPoint || width <= 0 || grap <= 0) return;
		   var Ox:Number = beginPoint.x;
		   var Oy:Number = beginPoint.y;
		   var radian:Number = Math.atan2(endPoint.y - Oy, endPoint.x - Ox);
		   var totalLen:Number = Point.distance(beginPoint, endPoint);
		   var currLen:Number = 0;
		   var x:Number, y:Number;
		   
		   while (currLen <= totalLen)
		   {
			x = Ox + Math.cos(radian) * currLen;
			y = Oy +Math.sin(radian) * currLen;
			graphics.moveTo(x, y);
			currLen += width;
			if (currLen > totalLen) currLen = totalLen;
			x = Ox + Math.cos(radian) * currLen;
			y = Oy +Math.sin(radian) * currLen;
			graphics.lineTo(x, y);
			currLen += grap;
		   }
		}
	}

}