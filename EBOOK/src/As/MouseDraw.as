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
		private var _panel:MouseDrawPanel;
		private var _colorNum:int = 1;
		private var _thicknessNum:int = 5;
		private var _typeNum:int = 1;
		
		public function MouseDraw(drawArea:DisplayObjectContainer,canvas:Canvas,panWidth:uint,penType:String,panel:MouseDrawPanel)
		{	
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			_drawArea = drawArea;	//可繪圖區域
			_canvas = canvas;		//實際放繪圖的元件
			_panWidth = panWidth;	//畫筆粗
			_penType = penType;		//畫筆類型
			_panel = panel;			//控制面板:選色,粗細,樣式
			
			_drawArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown1);
			_panel.addEventListener("Change_Thickness", changeThickness);
			_panel.addEventListener("Change_Color", changeColor);
			_panel.addEventListener("Change_Type", ChangeType);
		}
		
		private function changeThickness(e:Event):void 
		{	
			_thicknessNum = _panel.thicknessNum * 5;
		}
		
		private function changeColor(e:Event):void 
		{
			_colorNum = _panel.colorNum;
		}
		
		private function ChangeType(e:Event):void 
		{
			_typeNum = _panel.typeNum;
		}
		
		private function onMouseDown1(event:MouseEvent):void
		{
			if (stage && this.visible) {
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
			if (_typeNum == 1) {
				//隨便畫
				_newSprite.graphics.lineStyle(_thicknessNum, _colorNum);
				_newSprite.graphics.lineTo(mouseX, mouseY);
			}else if (_typeNum == 2) {
				//畫直虛線
				_newSprite.graphics.clear();
				_newSprite.graphics.lineStyle(_thicknessNum, _colorNum);
				drawDashed(_newSprite.graphics, _point, new Point(mouseX, mouseY), 5 * _thicknessNum, 5 * _thicknessNum);
			}else if (_typeNum == 3) {
				//畫直實線
				_newSprite.graphics.clear();
				_newSprite.graphics.lineStyle(_thicknessNum, _colorNum);
				_newSprite.graphics.moveTo(_point.x, _point.y);
				_newSprite.graphics.lineTo(mouseX, mouseY);
			}else if (_typeNum == 4) {
				//畫箭頭
				_newSprite.graphics.clear();
				_newSprite.graphics.lineStyle(_thicknessNum, _colorNum);
				_newSprite.graphics.moveTo(_point.x, _point.y);
				//_newSprite.graphics.lineTo(mouseX, mouseY);
				//trace(Math.sin(mouseY)*180,Math.cos(mouseX)*180);
				var a:Number = Point.distance(_point, new Point(mouseX, mouseY));
				var b:Number = 20;
				var A:Number=100*2*Math.PI/360;
				//var c:Number = Math.sqrt(a * a + b * b);
				trace(a, b, A);
				//var x = (a * a + b * b - c * c) / (2 * a);
				//var y = Math.sqrt(b * b - x * x);
				//_newSprite.graphics.lineTo(_point.x+a,_point.y);
				_newSprite.graphics.lineTo(mouseX, mouseY);
				_newSprite.graphics.lineTo(mouseX+b*Math.cos(A),mouseY+b*Math.sin(A));
				//_newSprite.graphics.lineTo(_point.x, _point.y);
			}
			
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