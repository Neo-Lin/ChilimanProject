package As 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Canvas extends MovieClip 
	{
		private var nowStep:uint = 0;
		private var stepArray:Array = new Array();
		
		public function Canvas() 
		{
			//addEventListener(Event.ADDED, canvasAdded);
		}
		
		public function canvasAdded(changeFrom:Sprite = null):void 
		{	
			if (numChildren > 0) {
				nowStep ++;
				if (nowStep == numChildren) {
					stepArray.push([getChildAt(numChildren - 1), changeFrom]);	//將繪圖物件放進array
				}else {	//上一步ctrlZ之後又加入新繪圖
					for (; numChildren > nowStep; ) {		//把之前的繪圖都刪除(顯示物件列表跟array)
						removeChild(stepArray[nowStep-1][0]);
						stepArray.splice(nowStep-1, 1);
					} 
					stepArray.push([getChildAt(numChildren - 1), changeFrom]);	//將新繪圖物件放進array
				}	
				getChildAt(numChildren - 1).addEventListener(MouseEvent.MOUSE_DOWN, goDrag);
				getChildAt(numChildren - 1).addEventListener(MouseEvent.MOUSE_UP, finishDrag);
			}
		}
		
		private function goDrag(e:MouseEvent):void 
		{	
			var _s:Sprite = new Sprite;
			_s.graphics.copyFrom(e.currentTarget.graphics);
			_s.x = e.currentTarget.x;
			_s.y = e.currentTarget.y;
			addChild(_s);
			canvasAdded(e.currentTarget as Sprite);		//更新stepArray,並告知移動前的物件
			e.currentTarget.visible = false;
			_s.startDrag();
		}
		
		private function finishDrag(e:MouseEvent):void 
		{	
			e.currentTarget.stopDrag();
		}
		
		public function ctrlZ():void {
			if (nowStep > 0) {	
				changeVisible(stepArray[nowStep - 1][0]);
				if (stepArray[nowStep - 1][1]) {
					changeVisible(stepArray[nowStep - 1][1]);
				}
				nowStep--;
			}
		}
		
		public function ctrlY():void {
			if (nowStep < numChildren) {
				changeVisible(stepArray[nowStep][0]);
				if (stepArray[nowStep][1]) {		//若是移動就會有移動前的物件,也一併改變顯示狀態
					changeVisible(stepArray[nowStep][1]);
				}
				nowStep++;
			}
		}
		
		private function changeVisible(_s:Sprite):void {
			if (_s.visible == true) {
				_s.visible = false;
			}else {
				_s.visible = true;
			}
		}
		
	}

}