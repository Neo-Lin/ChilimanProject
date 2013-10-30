package As
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	public class MouseDraw extends Sprite
	{
		private var _canvas:Canvas;
		private var _drawArea:DisplayObjectContainer;
		private var _panWidth:uint;
		private var _penType:String;
		private var _newSprite:Sprite;
		private var graphicsDataArray:Array = new Array();
		private var graphicsDataTemp:Array;
		private var graphicsDataSharedObject:SharedObject = SharedObject.getLocal("graphicsDataArray");
		
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
			var _s:Sprite = new Sprite
			_newSprite = _s; 
			_newSprite.graphics.lineStyle(_panWidth);
			_newSprite.graphics.moveTo(mouseX, mouseY);
			graphicsDataTemp = new Array();						//將筆畫存成array
			graphicsDataTemp.push(["lineStyle", _panWidth]);
			graphicsDataTemp.push(["moveTo", mouseX, mouseY]);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp1);
		}
		
		private function onMouseUp1(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp1);
			if(_newSprite.width > 0) _canvas.canvasAdded();		//如果有畫,請Canvas更新步驟陣列stepArray
			trace("MouseDraw:", _drawArea.numChildren, _canvas.numChildren);
			
			graphicsDataArray.push(graphicsDataTemp);			//存入Array
			graphicsDataSharedObject.data.graphicsData = graphicsDataArray;
			graphicsDataSharedObject.flush();  					//存到使用者PC
			
		}
		
		private function onMouseMove1(event:MouseEvent):void
		{
			_newSprite.graphics.lineTo(mouseX, mouseY);
			graphicsDataTemp.push(["lineTo", mouseX, mouseY]);
			_canvas.addChild(_newSprite);		//把繪圖物件放入Canvas
		}
		
		private function onRemove(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			_drawArea.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown1);
		}
		
	}

}