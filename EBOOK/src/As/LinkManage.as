package As 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class LinkManage extends Sprite 
	{
		
		public function LinkManage() 
		{
			
		}
		
		public function memosRemove():void {
			var _n:int = numChildren;
			for (var i:int = 0; i < _n; i++) {
				removeChildAt(0);
			}
		}
		
		//劃出存檔的繪圖物件
		public function reDrawSave(soArray:Array):void {
			var _a = soArray;
			var _i:uint = _a.length;
			for (var i:uint = 0; i < _i; i++) { //陣列內容:[x,y,width,height,PrevX,PrevY]
				var _m:Link = new Link();
				_m.initForData(_a[i]);
				addChild(_m);
			}
		}
		
		//存檔
		public function goSave():Array 
		{
			var _a = [];
			var _n:uint = this.numChildren; 
			for (var i:int = 0; i < _n; i++) {		//取得所有場景物件
				var _m:Link = this.getChildAt(i) as Link;
				//若visible == false表示答案貼被刪除
				if (_m.visible == true) {	
					_a.push(_m.getData());
				}
			}
			return _a;
		}
		
	}

}