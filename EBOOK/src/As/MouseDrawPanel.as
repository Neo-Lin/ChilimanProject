package As 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.ui.Mouse;
	
	/**
	 * ...
	 * 筆畫的顏色,粗細,類型
	 * @author Neo
	 */
	public class MouseDrawPanel extends MovieClip 
	{
		private var _colorNum:int = 0;
		private var _thicknessNum:int = 1;
		private var _typeNum:int = 1;
		private var pixel:BitmapData; 
		private var renderMatrix:Matrix = new Matrix();
		private var bm:Bitmap;
		
		public function MouseDrawPanel() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			colorPanel_mc.visible = false;
			initPixel();
			this.addEventListener(MouseEvent.CLICK, goChangeNum);
			this.addEventListener(MouseEvent.MOUSE_OUT, hideMouse);
			this.addEventListener(MouseEvent.MOUSE_OVER, showMouse);
		}
		
		private function showMouse(e:MouseEvent):void 
		{
			Mouse.show();
		}
		private function hideMouse(e:MouseEvent):void 
		{
			Mouse.hide();
		}
		
		//重製選色用點陣圖
		private function initPixel():void 
		{
			if(pixel) pixel.dispose();
			pixel = new BitmapData(this.width, this.height);
			if (colorPanel_mc.visible) {
				renderMatrix.ty = -colorPanel_mc.y;
			}else {
				renderMatrix.ty = 0;
			}
			pixel.draw(this, renderMatrix);
			/*bm = new Bitmap(pixel);
			addChild(bm);
			bm.x = -100;*/
		}
		
		private function goChangeNum(e:MouseEvent):void 
		{
			var _s:String = e.target.name;	
			if (_s.slice(0, _s.indexOf("_") - 1) == "thickness") {		//線段粗細
				_thicknessNum = int(_s.substr(_s.indexOf("_") - 1, 1));
				this.dispatchEvent(new Event("Change_Thickness"));
			}else if (_s.slice(0, _s.indexOf("_") - 1) == "color" || _s == "color_mc") {		//選顏色
				//trace(pixel.getPixel(mouseX, mouseY).toString(16));
				if (colorPanel_mc.visible) {
					//取得顏色
					_colorNum = pixel.getPixel(mouseX, mouseY - colorPanel_mc.y);
					colorPanel_mc.visible = false;
					initPixel();
				}else {
					//取得顏色
					_colorNum = pixel.getPixel(mouseX, mouseY);
				}	//trace(_colorNum);
				this.dispatchEvent(new Event("Change_Color"));
			}else if (_s.slice(0, _s.indexOf("_") - 1) == "type") {		//線段類型
				_typeNum = int(_s.substr(_s.indexOf("_") - 1, 1));
				this.dispatchEvent(new Event("Change_Type"));
			}else if (_s == "close_btn") {		//關閉
				colorPanel_mc.visible = false;
				this.visible = false;
			}else if (_s == "colseColorPanel_btn") {	//關閉顏色面板
				colorPanel_mc.visible = false;
				initPixel();
			}else if (_s == "colorPanel_btn") {		//開啟顏色面板
				colorPanel_mc.visible = true;
				initPixel();
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