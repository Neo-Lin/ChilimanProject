package As 
{
	import As.Events.UndoManagerEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...放Memo的容器
	 * @author Neo
	 */
	public class FloatingMemo extends Sprite 
	{
		
		public function FloatingMemo() 
		{
			this.addEventListener(Event.ADDED, takeNewMemo);
		}
		
		private function takeNewMemo(e:Event):void 
		{
			/*trace("加入!!", e.currentTarget, e.target, this.numChildren, e.target is Memo);
			if (e.target is Memo) {
				var _a = e.target.getData();
				var operation:TransformOperation = new TransformOperation(e.target,_a[0],_a[1],_a[0],_a[1],false,true);
				stage.dispatchEvent(new UndoManagerEvent(UndoManagerEvent.PUSH_UNDO, false, operation));
			}*/
		}
		
		//劃出存檔的繪圖物件
		public function reDrawSave(soArray:Array):void {
			var _a = soArray;
			var _i:uint = _a.length;
			for (var i:uint = 0; i < _i; i++) { //陣列內容:[x,y,width,height,PrevX,PrevY]
				var _m:Memo = new Memo(this,_a[i]);
				addChild(_m);
			}
		}
		
		public function memosRemove():void {
			var _n:int = numChildren;
			for (var i:int = 0; i < _n; i++) {
				removeChildAt(0);
			}
		}
		
		//存檔
		public function goSave():Array 
		{
			var _a = [];
			var _n:uint = this.numChildren; 
			for (var i:int = 0; i < _n; i++) {		//取得所有場景物件
				var _m:Memo = this.getChildAt(i) as Memo;
				//若visible == false表示答案貼被撕除,alpha < 0表示答案貼撕除中
				if (_m.visible == true && _m.alpha == 1) {	
					_a.push(_m.getData());
				}
			}
			return _a;
		}
	}

}