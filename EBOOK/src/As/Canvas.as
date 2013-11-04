package As 
{
	import flash.display.GraphicsPath;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flashx.undo.UndoManager;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Canvas extends Sprite 
	{
		private var nowStep:uint = 0;
		private var stepArray:Array = new Array();		//新增物件會放入此陣列,對應步驟數nowStep
		
		public static var _undo:UndoManager=new UndoManager();
        public static var _redo:UndoManager=new UndoManager();     
        public static var PrevX:Number=0;
        public static var PrevY:Number = 0;
		
		private var graphicsDataArray:Array = new Array();
		private var graphicsDataSharedObject:SharedObject = SharedObject.getLocal("graphicsDataArray");
		
		public function Canvas() 
		{
			
		}
		
		public function canvasAdded(changeFrom:Sprite = null):void 
		{	
			if (nowStep != stepArray.length) {	//步驟數與陣列數量不相等,表示undo過
				goClear();
			}
			nowStep ++;
			stepArray.push(getChildAt(numChildren - 1));	//將繪圖物件放進array
			var _shape:Object = getChildAt(numChildren - 1);
			var operation:TransformOperation = new TransformOperation(_shape,_shape.x,_shape.y,_shape.x,_shape.y,false,true);
			_undo.pushUndo(operation);
			getChildAt(numChildren - 1).addEventListener(MouseEvent.MOUSE_DOWN, goDrag);
			getChildAt(numChildren - 1).addEventListener(MouseEvent.MOUSE_UP, finishDrag);		
		}
		
		//加入新物件時,若有undo過,就把紀錄的redo跟相關物件清除
		private function goClear():void {	//上一步ctrlZ之後又加入新繪圖或刪除繪圖
			for (; stepArray.length > nowStep; ) {		//把之前的繪圖都刪除(顯示物件列表跟array)
				if (stepArray[nowStep]) { 	//如果不是null代表不是移動,有物件需刪除
					removeChild(stepArray[nowStep]); 
				}
				stepArray.splice(nowStep, 1); 
			} trace("goClear");
			_redo.clearRedo();
		}
		
		//移動繪圖物件====================================
		private function goDrag(e:MouseEvent):void 
		{	
			e.currentTarget.startDrag();
			PrevX = e.currentTarget.x;		//紀錄移動前的位置
			PrevY = e.currentTarget.y;
		}
		
		private function finishDrag(e:MouseEvent):void 
		{	
			e.currentTarget.stopDrag();
			if (e.currentTarget.x != PrevX || e.currentTarget.y != PrevY) {	 //有移動位置才需要增加undo	
				if (nowStep != stepArray.length) {	//步驟數與陣列數量不相等,表示undo過
					goClear();
				}
				stepArray.push(null);		//移動並沒有新增物件,所以放入null
				nowStep ++;
				var operation:TransformOperation = new TransformOperation(e.currentTarget,PrevX,PrevY,e.currentTarget.x,e.currentTarget.y,true,true);
				_undo.pushUndo(operation);
				
				//先寫這邊方便測試,已經可以抓到繪圖的方法,存檔的時候抓目前場景上visible=true的物件取出繪圖方法存到電腦裡
				/*trace(e.currentTarget.graphics.readGraphicsData());
				var v:Vector.<IGraphicsData> = e.currentTarget.graphics.readGraphicsData();
				if (v[1] as GraphicsPath) trace("is!!!!");
				var p:GraphicsPath = v[1] as GraphicsPath;
				trace(p.commands,p.data);*/
				//修改SharedObject裡的物件位置
				//this.getChildIndex(e.currentTarget as Sprite)
			}
		}
		//====================================移動繪圖物件
		
		//上一步
		public function ctrlZ():void {
			if (nowStep > 0) {	
				_redo.pushRedo(_undo.peekUndo());
				_undo.undo();
				nowStep--;
			}
		}
		
		//下一步
		public function ctrlY():void {
			if (nowStep < stepArray.length) {
				_undo.pushUndo(_redo.peekRedo());
				_redo.redo();
				nowStep++;
			}
		}
		
		//橡皮擦
		public function eraser():void {
			for (var i:uint = 0; i < numChildren; i++) {
				if (getChildAt(i).hitTestPoint(mouseX, mouseY, true) && getChildAt(i).visible == true) {	trace(getChildAt(i).name,i);
					if (nowStep != stepArray.length) {	//步驟數與陣列數量不相等,表示undo過
						goClear();
					}
					nowStep ++;
					getChildAt(i).visible = false;
					stepArray.push(null);		//刪除並沒有新增物件,所以放入null
					var operation:TransformOperation = new TransformOperation(getChildAt(i),getChildAt(i).x,getChildAt(i).y,getChildAt(i).x,getChildAt(i).y,true,false);
					_undo.pushUndo(operation);
					
					break;
				}
			}
		}
		
		public function reDrawSave():void {
			graphicsDataArray = graphicsDataSharedObject.data.graphicsData;
			
			trace("graphicsDataArray.length:", graphicsDataArray.length);
			
			/*var _i:uint = graphicsDataArray.length;
			var _j:uint;
			for (var i:uint = 0; i < _i; i++) {
				_j = graphicsDataArray[i].length;
				var _s:Sprite = new Sprite();
				for (var j:uint = 0; j < _j; j++) {
					if (graphicsDataArray[i][j][0] == "lineStyle") {
						_s.graphics.lineStyle(graphicsDataArray[i][j][1]);
					}else if (graphicsDataArray[i][j][0] == "moveTo") {
						_s.graphics.moveTo(graphicsDataArray[i][j][1], graphicsDataArray[i][j][2]);
					}else if (graphicsDataArray[i][j][0] == "lineTo") {
						_s.graphics.lineTo(graphicsDataArray[i][j][1], graphicsDataArray[i][j][2]);
					}else if (graphicsDataArray[i][j][0] == "XY") {
						_s.x = graphicsDataArray[i][j][1];
						_s.y = graphicsDataArray[i][j][2];
					}
				}
				if (_s.width > 0) {
					_canvas.addChild(_s);		//把繪圖物件放入Canvas
					_canvas.canvasAdded();		//請Canvas更新步驟陣列stepArray
				}
			}*/
		}
		
		public function goSave():void 
		{
			var _n:uint = this.numChildren; 
			for (var i:int = 0; i < _n; i++) {		//取得所有場景物件的IGraphicsData
				//trace(Sprite(this.getChildAt(i)).graphics.readGraphicsData());
				var v:Vector.<IGraphicsData> = Sprite(this.getChildAt(i)).graphics.readGraphicsData();
				var graphicsDataTemp:Array = new Array();
				var j:uint = v.length;
				for (var _j:int = 0; _j < j; _j++) {
					if (v[_j] as GraphicsPath) {	//判斷是否為GraphicsPath
						var p:GraphicsPath = v[_j] as GraphicsPath;	//取出commands(動作代號)跟data(動作路徑))
						graphicsDataTemp.push(p.commands,p.data);
						trace("graphicsDataTemp::::::",p.commands,p.data);
					}else if (v[_j] as GraphicsStroke) {
						var gs:GraphicsStroke = v[_j] as GraphicsStroke;
						if (gs.fill) {		//一組筆劃很奇怪的會帶兩個GraphicsStroke,其中一個才有正確的fill屬性,所以要判斷
							var gsf:GraphicsSolidFill = gs.fill as GraphicsSolidFill;	//取出thickness(筆粗)跟color)
							graphicsDataTemp.push(gs.thickness, gsf.color);
							trace("graphicsDataTemp::::::",gs.thickness, gsf.color);
						}
						//trace(gs.caps,gs.fill,gs.joints,gs.miterLimit,gs.pixelHinting,gs.scaleMode,gs.thickness);
					}
				}
				graphicsDataArray.push(graphicsDataTemp);	
				trace("graphicsDataArray:",graphicsDataArray.length, graphicsDataArray);
			}
			graphicsDataSharedObject.data.graphicsData = graphicsDataArray;
			graphicsDataSharedObject.flush();	//存入SharedObject
			
			/*if (stepArray.length > 0) {
				graphicsDataArray = graphicsDataSharedObject.data.graphicsData;
				graphicsDataTemp = graphicsDataArray;
				trace("1:",stepArray.length);
				trace("2:",graphicsDataArray.length);
				trace("3:",graphicsDataTemp.length);
				var _n:uint = stepArray.length;
				for (var i:int = _n-1; i >= 0; i--) { trace(stepArray[i]);
					if (stepArray[i] && !stepArray[i].visible) {	trace("--");
						graphicsDataTemp.splice(i, 1);
					}
				}
				graphicsDataSharedObject.data.graphicsData = graphicsDataTemp;
				graphicsDataSharedObject.flush(); 
			}*/
		}
	}
}