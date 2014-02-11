package As
{
	import ascb.drawing.Pen;
	import com.dncompute.graphics.GraphicsUtil;
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
		private var _colorNum:int = 0;
		private var _thicknessNum:int = 5;
		private var _typeNum:int = 1;
		
		public function MouseDraw(drawArea:DisplayObjectContainer,canvas:Canvas,panWidth:uint,penType:String,panel:MouseDrawPanel)
		{	
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			_drawArea = drawArea;	//可繪圖區域
			_canvas = canvas;		//實際放繪圖的元件
			_panWidth = panWidth;	//畫筆粗
			_panel = panel;			//控制面板:選色,粗細,樣式
			
			changePenType(penType);
			
			_drawArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown1);
			_panel.addEventListener("Change_Thickness", changeThickness);
			_panel.addEventListener("Change_Color", changeColor);
			_panel.addEventListener("Change_Type", ChangeType);
		}
		
		public function changePenType(penType:String):void {
			_penType = penType;		//畫筆類型
			if (_penType == "b") {
				_thicknessNum = 25;
				_colorNum = 16776960;
				_panel.gotoAndStop(2);
			}else if (_penType == "c") {
				_typeNum = 5;
			}else {
				_thicknessNum = 5;
				_colorNum = 0;
				_panel.gotoAndStop(1);
			}
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
				_newSprite.graphics.lineStyle(_thicknessNum, _colorNum);
				_newSprite.graphics.moveTo(_point.x, _point.y);
				
				if (_penType == "b") {
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove2);
				}else{
					stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
				}
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp1);
			}
		}
		
		private function onMouseUp1(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove2);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp1);
			if(_newSprite.width > 0) _canvas.canvasAdded();		//如果有畫,請Canvas更新步驟陣列stepArray
			trace("MouseDraw:", _drawArea.numChildren, _canvas.numChildren);
		}
		
		private function onMouseMove1(event:MouseEvent):void
		{
			var point:int = Point.distance(_point, new Point(mouseX, mouseY));
			var pen:Pen;
			if (_typeNum == 1) {
				//隨便畫
				//_newSprite.graphics.lineStyle(_thicknessNum, _colorNum);
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
				
				GraphicsUtil.drawArrow(_newSprite.graphics, _point,new Point(mouseX, mouseY),
				{shaftThickness:1,headWidth:40,headLength:40,
				shaftPosition:1,edgeControlPosition:.5});
			}else if (_typeNum == 15) {
				//畫圓圈
				_newSprite.graphics.clear();
				_newSprite.graphics.lineStyle(_thicknessNum, _colorNum);
				_newSprite.graphics.beginFill(0xFFFFFF);
				_newSprite.graphics.drawCircle(_point.x, _point.y, point);
				//_newSprite.graphics.endFill();
			}else if (_typeNum == 15) {
				//畫正方形
				_newSprite.graphics.clear();
				_newSprite.graphics.lineStyle(_thicknessNum, _colorNum);
				_newSprite.graphics.beginFill(0xFFFFFF);
				_newSprite.graphics.drawRect(_point.x, _point.y, mouseX - _point.x, mouseY - _point.y);
			}else if (_typeNum == 15) {
				//畫三角形
				pen = new Pen(_newSprite.graphics);
				pen.clear();
				pen.lineStyle(_thicknessNum, _colorNum);
				pen.beginFill(0xFFFFFF);
				pen.drawRegularPolygon(_point.x, _point.y, 3, point * 2, 30);
			}else if (_typeNum == 15) {
				//畫五角形
				pen = new Pen(_newSprite.graphics);
				pen.clear();
				pen.lineStyle(_thicknessNum, _colorNum);
				pen.beginFill(0xFFFFFF);
				pen.drawRegularPolygon(_point.x, _point.y, 5, point, -18);
			}else if (_typeNum == 5) {
				//畫星形
				pen = new Pen(_newSprite.graphics);
				pen.clear();
				pen.lineStyle(_thicknessNum, _colorNum);
				pen.beginFill(0xFFFFFF);
				pen.drawStar(_point.x, _point.y, 5, point/3, point);
			}
			
			_canvas.addChild(_newSprite);		//把繪圖物件放入Canvas
		}
		
		private function onMouseMove2(event:MouseEvent):void
		{
			//畫螢光直實線
			_newSprite.graphics.clear();
			_newSprite.graphics.lineStyle(_thicknessNum, _colorNum, .4);
			_newSprite.graphics.moveTo(_point.x, _point.y);
			_newSprite.graphics.lineTo(mouseX, mouseY);
			_canvas.addChild(_newSprite);		//把繪圖物件放入Canvas
		}
		
		private function onRemove(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			_drawArea.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown1);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove2);
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