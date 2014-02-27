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
			for (var i:uint = 0; i < _i; i++) {
				if (_a[i].length == 4) { //陣列內容:[x, y, linkPanel_mc.title_txt.text, linkPanel_mc.link_txt.text];
					var _m:Link = new Link();
					_m.initForData(_a[i]);
					addChild(_m);
				}else if (_a[i].length == 5) {	//陣列內容:[x, y, textEditorPanel_mc.tfText.text, title_txt.text, "TextMemo"];
					var _t:TextMemo = new TextMemo();
					_t.initForData(_a[i]);
					addChild(_t);
				}
			}
		}
		
		//存檔
		public function goSave():Array 
		{
			var _a = [];
			var _n:uint = this.numChildren; 
			for (var i:int = 0; i < _n; i++) {		//取得所有場景物件
				if (this.getChildAt(i) is Link) {
					var _m:Link = this.getChildAt(i) as Link;
					//若visible == false表示物件被刪除
					if (_m.visible == true) {	
						_a.push(_m.getData());
					}
				}else if (this.getChildAt(i) is TextMemo) {
					var _t:TextMemo = this.getChildAt(i) as TextMemo;
					//若visible == false表示物件被刪除
					if (_t.visible == true) {	
						_a.push(_t.getData());
					}
				}
				
			}
			return _a;
		}
		
	}

}