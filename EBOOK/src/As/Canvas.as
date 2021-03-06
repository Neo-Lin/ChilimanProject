package As 
{
	import As.Events.UndoManagerEvent;
	import flash.display.DisplayObject;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
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
		
		private var mt:MorphTool;
		
		//public static var _undo:UndoManager=new UndoManager();
        //public static var _redo:UndoManager=new UndoManager();     
        public static var PrevX:Number=0;
        public static var PrevY:Number = 0;
		
		private var graphicsDataArray:Array = new Array();
		//private var graphicsDataSharedObject:SharedObject = SharedObject.getLocal("graphicsDataArray");
		
		public function Canvas() 
		{
			
		}
		
		public function canvasAdded(_penType:String = null):void 
		{	
			if (nowStep != stepArray.length) {	//步驟數與陣列數量不相等,表示undo過
				goClear();
			}
			nowStep ++;
			var _shape:Object = getChildAt(numChildren - 1);
			var operation:TransformOperation = new TransformOperation(_shape,_shape.x,_shape.y,_shape.x,_shape.y,false,true);
			stepArray.push(_shape);	//將繪圖物件放進array
			//_undo.pushUndo(operation);
			stage.dispatchEvent(new UndoManagerEvent(UndoManagerEvent.PUSH_UNDO, false, operation));
			_shape.addEventListener(MouseEvent.MOUSE_DOWN, goDrag);
			_shape.addEventListener(MouseEvent.MOUSE_UP, finishDrag);		
			if (_penType == "c") {	//若是形狀物件,要加入變色變形的功能
				_shape.addEventListener(MouseEvent.MOUSE_DOWN, goShapeDrag);
			}
		}
		
		public function canvasRemove():void {
			stepArray.length = 0;
			var _n:int = numChildren;
			for (var i:int = 0; i < _n; i++) {
				getChildAt(0).removeEventListener(MouseEvent.MOUSE_DOWN, goDrag);
				getChildAt(0).removeEventListener(MouseEvent.MOUSE_UP, finishDrag);	
				removeChildAt(0);
			}
		}
		
		//加入新物件時,若有undo過,就把紀錄的redo跟相關物件清除
		private function goClear():void {	//上一步ctrlZ之後又加入新繪圖或刪除繪圖
			for (; stepArray.length > nowStep; ) {		//把之前的繪圖都刪除(顯示物件列表跟array)
				if (stepArray[nowStep]) { 	//如果不是null代表不是移動,有物件需刪除
					removeChild(stepArray[nowStep]); 
				}
				stepArray.splice(nowStep, 1); 
			} 
			//_redo.clearRedo();
			stage.dispatchEvent(new UndoManagerEvent(UndoManagerEvent.CLEAR_REDO));
		}
		
		//移動繪圖物件====================================
		//形狀
		private function goShapeDrag(e:MouseEvent):void 
		{	
			mt = new MorphTool();
			addChild(mt);
			mt.init(e.currentTarget as DisplayObject);
		}
		
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
				//_undo.pushUndo(operation);
				stage.dispatchEvent(new UndoManagerEvent(UndoManagerEvent.PUSH_UNDO, false, operation));
			}
		}
		//====================================移動繪圖物件
		
		//上一步
		public function ctrlZ():void {
			if (nowStep > 0) {	
				/*_redo.pushRedo(_undo.peekUndo());
				_undo.undo();*/
				nowStep--;
			}
		}
		
		//下一步
		public function ctrlY():void {
			if (nowStep < stepArray.length) {
				/*_undo.pushUndo(_redo.peekRedo());
				_redo.redo();*/
				nowStep++;
			}
		}
		
		//橡皮擦
		public function eraser():void {
			var _n:uint = this.numChildren; 
			for (var i:uint = 0; i < _n; i++) {
				if (getChildAt(i).hitTestPoint(mouseX, mouseY, true) && getChildAt(i).visible == true) {	trace(getChildAt(i).name,i);
					if (nowStep != stepArray.length) {	//步驟數與陣列數量不相等,表示undo過
						goClear();
					}
					nowStep ++;
					getChildAt(i).visible = false;
					stepArray.push(null);		//刪除並沒有新增物件,所以放入null
					var operation:TransformOperation = new TransformOperation(getChildAt(i),getChildAt(i).x,getChildAt(i).y,getChildAt(i).x,getChildAt(i).y,true,false);
					//_undo.pushUndo(operation);
					stage.dispatchEvent(new UndoManagerEvent(UndoManagerEvent.PUSH_UNDO, false, operation));
					
					break;
				}
			}
		}
		
		//全部刪除
		public function allClear():Array {
			var _a = [];
			var _n:uint = this.numChildren; 
			for (var i:uint = 0; i < _n; i++) {
				if (getChildAt(i).visible) {	//trace(getChildAt(i).name,i);
					if (nowStep != stepArray.length) {	//步驟數與陣列數量不相等,表示undo過
						goClear();
					}
					nowStep ++;
					getChildAt(i).visible = false;
					stepArray.push(null);		//刪除並沒有新增物件,所以放入null
					
					_a.push(getChildAt(i));
				}
			}
			return _a;
		}
		
		//劃出存檔的繪圖物件
		public function reDrawSave(soArray:Array):void {
			graphicsDataArray = soArray;
			var _i:uint = graphicsDataArray.length;	
			for (var i:uint = 0; i < _i; i++) { //陣列內容:[thickness(筆粗),color,alpha,commands(動作代號),data(動作路徑),x,y]
				var _s:Sprite = new Sprite();
				_s.x = graphicsDataArray[i][0];
				_s.y = graphicsDataArray[i][1];
				var _type:String = "";
				if (graphicsDataArray[i].length == 8) {	//形狀會多帶一筆填色
					var gf = graphicsDataArray[i].pop();
					//trace("還原填色");
					_s.graphics.beginFill(gf[0], gf[1]);
					_type = "c";	//標示為形狀
				}
				_s.graphics.lineStyle(graphicsDataArray[i][2], graphicsDataArray[i][3], graphicsDataArray[i][4]);
				//_s.graphics.drawPath(graphicsDataArray[i][2], graphicsDataArray[i][3]); 
				
				for (var j:int = 5; j < graphicsDataArray[i].length; j+=2) {	//虛線會有好幾個動作代號跟路徑,其他則只會有一組
					_s.graphics.drawPath(graphicsDataArray[i][j], graphicsDataArray[i][j+1]);
				}
				addChild(_s);
				canvasAdded(_type);
			}
		}
		
		//存檔
		public function goSave():Array 
		{
			graphicsDataArray = new Array();
			var _n:uint = this.numChildren; 
			for (var i:int = 0; i < _n; i++) {		//取得所有場景物件的IGraphicsData
				var _s:Sprite = this.getChildAt(i) as Sprite;
				if (_s.visible == true) {	//若visible == false表示繪圖物件被undo或被橡皮擦掉
					var v:Vector.<IGraphicsData> = _s.graphics.readGraphicsData();	
					var graphicsDataTemp:Array = new Array();	//一個陣列對應一個繪圖物件,[thickness(筆粗),color,alpha,commands(動作代號),data(動作路徑),x,y]
					graphicsDataTemp.push(_s.x, _s.y);	//取出x跟y
					var j:uint = v.length;
					if (j == 7) {	//表示是形狀物件,形狀物件前三個是填色資料,後四筆才是筆劃資料
						//取得填色資料
						var gf:GraphicsSolidFill = v[0] as GraphicsSolidFill;
						v = v.slice(3);
						j = 4;
					}
					for (var _j:int = 0; _j < j; _j++) {
						if (v[_j] as GraphicsPath) {	//判斷是否為GraphicsPath
							var p:GraphicsPath = v[_j] as GraphicsPath;	//取出commands(動作代號)跟data(動作路徑))
							graphicsDataTemp.push(p.commands,p.data);
							//trace("graphicsDataTemp1::::::",p.commands,p.data);
						}else if (v[_j] as GraphicsStroke && _j < 3) {  //只取一次,虛線會有很多筆一樣的
							var gs:GraphicsStroke = v[_j] as GraphicsStroke;
							if (gs.fill) {		//一組筆劃很奇怪的會帶兩個GraphicsStroke,其中一個才有正確的fill屬性,所以要判斷
								var gsf:GraphicsSolidFill = gs.fill as GraphicsSolidFill;	//取出thickness(筆粗),color,alpha)
								graphicsDataTemp.push(gs.thickness, gsf.color, gsf.alpha);
								//trace("graphicsDataTemp2::::::",gs.thickness, gsf.color, gsf.alpha);
							}
							//trace(":::",gs.caps,gs.fill,gs.joints,gs.miterLimit,gs.pixelHinting,gs.scaleMode,gs.thickness);
						}
					}
					if (gf) {	//如果有填色資料就加在最後一筆
						graphicsDataTemp.push([gf.color, gf.alpha]);
						gf = null;
					}
					
					graphicsDataArray.push(graphicsDataTemp);	
					//trace("graphicsDataTemp:",graphicsDataTemp.length, graphicsDataTemp);
				} 
			}
			//trace("graphicsDataArray:", graphicsDataArray.length, graphicsDataArray);
			return graphicsDataArray;
			//graphicsDataSharedObject.data.graphicsData = graphicsDataArray;
			//graphicsDataSharedObject.flush();	//存入SharedObject
		}
	}
}