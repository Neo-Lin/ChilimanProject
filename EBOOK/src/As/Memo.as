package As 
{
	import com.foxaweb.pageflip.PageFlip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Neo
	 */
	public class Memo extends Sprite
	{
		private var p0color:uint = 0x00ffcc33;
		private var p1color:uint = 0x00ffbb33;
		private var scaleWH:uint = 40;
		private var horizontal:Boolean = true;
		private var _render:Shape=new Shape();
		private var page0:BitmapData= new BitmapData(200, 40, false, p0color); 
		private var page1:BitmapData = new BitmapData(200, 40, false, p1color); 
		private var pixel:BitmapData; 
		private var _sp:Sprite = new Sprite();
		private var changeWH:Boolean = false;
		private var testBM:Bitmap;
		
		public function Memo() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			if (page0.width > page0.height) {
				pixel = new BitmapData(page0.width * 2, page0.width * 2)
			}else {
				pixel = new BitmapData(page0.height * 2, page0.height * 2)
			}
			testBM = new Bitmap(pixel);
			/*//撕除點在右上或右下角
			_render.x=100;
			_render.y=50;*/
			//撕除點在左上或左下角
			_render.x=0;
			_render.y=(pixel.height/2)/2;
			_sp.addChild(_render);
			addChild(_sp);
			addChild(testBM);
			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, bitmapPgD);
			stage.addEventListener(MouseEvent.MOUSE_UP, bitmapPgU);
			goFlip();
			
			pixel.draw(_sp);
		}
		
		private function bitmapPgU(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, bitmapPgM);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, goChangeWH);
			this.stopDrag();
			changeWH = false;
			if (_render.mouseX > page0.width * 1.8) {
				trace("jjjjjj");
			}
		}
		
		private function bitmapPgD(e:MouseEvent):void 
		{ 
			//pixel.draw(_sp);
			trace(page0.getPixel(mouseX,mouseY).toString(16),_render.mouseX,this.mouseX);
			if (pixel.getPixel(mouseX,mouseY).toString(16) == p1color.toString(16)) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, bitmapPgM);
				goFlip(_render.mouseX,_render.mouseY);
			}else if (_render.mouseX > page0.width - 10 && _render.mouseY > page0.height - 10) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, goChangeWH);
				//changeWH = true;
			}else {
				this.startDrag();
			}
			
		}
		
		private function goChangeWH(e:MouseEvent):void 
		{	//trace("goChangeWH");
			
			//縮小要有限度
			if (_render.mouseX < scaleWH && _render.mouseY < scaleWH) {
				page0 = new BitmapData(scaleWH, scaleWH, false, p0color);
				page1 = new BitmapData(scaleWH, scaleWH, false, p1color); 
			}else if (_render.mouseY < scaleWH) {
				page0 = new BitmapData(_render.mouseX, scaleWH, false, p0color);
				page1 = new BitmapData(_render.mouseX, scaleWH, false, p1color); 
			}else if (_render.mouseX < scaleWH) {
				page0 = new BitmapData(scaleWH, _render.mouseY, false, p0color);
				page1 = new BitmapData(scaleWH, _render.mouseY, false, p1color); 
			} else {
				page0 = new BitmapData(_render.mouseX, _render.mouseY, false, p0color);
				page1 = new BitmapData(_render.mouseX, _render.mouseY, false, p1color); 
			}
			
			if (page0.width > page0.height) {
				pixel = new BitmapData(page0.width * 2, page0.width * 2 + page0.height);
				horizontal = true;  //末端在右邊
				_render.x = 0;
				_render.y=pixel.height/2 - page0.height/2;
			}else {
				pixel = new BitmapData(page0.height * 2 + page0.width, page0.height * 2);
				horizontal = false;  //末端在下邊
				_render.x = pixel.width / 2 - page0.height / 2;
				_render.y = 0;
			}
			
			goFlip();
			pixel.draw(_sp);
			testBM.bitmapData = pixel;
			trace(page0.width, _render.width, _sp.width, pixel.width);
		}
		
		private function bitmapPgM(e:MouseEvent):void 
		{
			//trace(mouseX, _render.mouseX);
			//撕除點在右下角
			//if(_render.mouseX < _render.width - 10 || _render.mouseY < _render.height - 10) goFlip(_render.mouseX,_render.mouseY);
			if (changeWH) {
				//goChangeWH();
			}else if (mouseX > 10 || mouseY > _render.y + 10) { //撕除點在左上角
				goFlip(_render.mouseX,_render.mouseY);
			}
			
			pixel.draw(_sp);
		}
		
		private function goFlip(_x:Number = 20, _y:Number = 20):void {
			_render.graphics.clear(); 
			var o:Object=PageFlip.computeFlip(	new Point(_x, _y),	// flipped point
									new Point(0,0),		// of bottom-right corner
									page0.width,		// size of the sheet
									page1.height,
									horizontal,					// in horizontal mode
									1);					// sensibility to one 
           
			PageFlip.drawBitmapSheet(o,					// computeflip returned object
									_render,					// target
									page0,		// bitmap page 0
									page1);		// bitmap page 1
		}
		
	}

}