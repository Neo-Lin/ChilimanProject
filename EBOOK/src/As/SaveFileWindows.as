package As 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class SaveFileWindows extends Sprite 
	{
		private var listAmount:int = 3;
		private var tempFileLine:MovieClip;
		
		public function SaveFileWindows() 
		{
			delete_btn.visible = save_btn.visible = false;
			
			fileLine1_mc.fileName_txt.text = "001";
			
			initLine();
			changeLine();
			/*fileLine_mc.fileName_txt.doubleClickEnabled = true;
			fileLine_mc.fileName_txt.addEventListener(MouseEvent.DOUBLE_CLICK, changeFileName);*/
		}
		
		private function initLine():void {
			for (var i:int = 1; i <= listAmount; i++) {
				var _mc:MovieClip = this["fileLine" + i + "_mc"];
				_mc.addEventListener(MouseEvent.MOUSE_OVER, lineMouseOver);
				_mc.addEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
				_mc.addEventListener(MouseEvent.CLICK, lineClick);
				_mc.fileNameInput_txt.addEventListener(MouseEvent.CLICK, inputFileName);
			}
		}
		
		private function inputFileName(e:MouseEvent):void 
		{
			e.currentTarget.text = "";
		}
		
		private function changeLine():void {
			for (var i:int = 1; i <= listAmount; i++) {
				var _mc:MovieClip = this["fileLine" + i + "_mc"];
				_mc.frame_mc.gotoAndStop(1);
				_mc.addEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
				if (_mc.fileName_txt.length > 0) {
					_mc.fileNameInput_txt.visible = false;
				}else if (tempFileLine != _mc) {
					_mc.fileNameInput_txt.text = "請輸入檔名";
				}
			}
		}
		
		private function lineClick(e:MouseEvent):void 
		{
			tempFileLine = e.currentTarget as MovieClip;
			changeLine();
			tempFileLine.frame_mc.gotoAndStop(2);
			tempFileLine.removeEventListener(MouseEvent.MOUSE_OUT, lineMouseOut);
			
			tempFileLine.fileName_txt.focusRect = true;
			
			if (tempFileLine.fileName_txt.length > 0) {
				delete_btn.visible = save_btn.visible = true;
			}else {
				delete_btn.visible = false;
				save_btn.visible = true;
			}
		}
		
		private function lineMouseOut(e:MouseEvent):void 
		{
			e.currentTarget.frame_mc.gotoAndStop(1);
		}
		
		private function lineMouseOver(e:MouseEvent):void 
		{
			e.currentTarget.frame_mc.gotoAndStop(2);
		}
		
	}

}