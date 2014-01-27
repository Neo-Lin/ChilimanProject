package As 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * 筆畫的顏色,粗細,類型
	 * @author Neo
	 */
	public class MouseDrawPanel extends Sprite 
	{
		private var _colorNum:int = 1;
		private var _thicknessNum:int = 1;
		private var _typeNum:int = 1;
		private var pixel:BitmapData; 
		
		public function MouseDrawPanel() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			pixel = new BitmapData(this.width, this.height);
			pixel.draw(this);
			this.addEventListener(MouseEvent.CLICK, goChangeNum);
		}
		
		private function goChangeNum(e:MouseEvent):void 
		{
			var _s:String = e.target.name;
			if (_s.slice(0, _s.indexOf("_") - 1) == "thickness") {
				_thicknessNum = int(_s.substr(_s.indexOf("_") - 1, 1));
				this.dispatchEvent(new Event("Change_Thickness"));
			}else if (_s.slice(0, _s.indexOf("_") - 1) == "color") {
				//trace(pixel.getPixel(mouseX, mouseY).toString(16));
				//取得顏色
				_colorNum = pixel.getPixel(mouseX, mouseY);
				this.dispatchEvent(new Event("Change_Color"));
			}else if (_s.slice(0, _s.indexOf("_") - 1) == "type") {
				_typeNum = int(_s.substr(_s.indexOf("_") - 1, 1));
				this.dispatchEvent(new Event("Change_Type"));
			}else if (_s == "close_btn") {
				this.visible = false;
			}
			
		}
		
		public function get colorNum():int 
		{
			return _colorNum;
		}
		
		public function get thicknessNum():int 
		{
			return _thicknessNum;
		}
		
		public function get typeNum():int 
		{
			return _typeNum;
		}
	}

}