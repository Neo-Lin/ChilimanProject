package As 
{
	import caurina.transitions.Tweener;
	import com.foxaweb.pageflip.PageFlip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
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
		private var scaleShape:Sprite=new Sprite();
		private var horizontal:Boolean = true;
		private var _render:Shape = new Shape();
		private var initRenderW:Number = 200;
		private var initRenderH:Number = 40;
		private var renderMatrix:Matrix = new Matrix();
		private var page0:BitmapData= new BitmapData(initRenderW, initRenderH, false, p0color); 
		private var page1:BitmapData = new BitmapData(initRenderW, initRenderH, false, p1color); 
		private var pixel:BitmapData; 
		private var pixelBM:Bitmap;
		private var pixelS:Sprite = new Sprite();
		private var renderArray:Array = new Array();
		private var _drawArea:DisplayObjectContainer;
		
		public function Memo(drawArea:DisplayObjectContainer) 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			_drawArea = drawArea;	//可繪圖區域
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//用來偵測滑鼠點擊位置像素值的對照點陣圖
			pixel = new BitmapData(initRenderW, initRenderH)
			/*pixelBM = new Bitmap(pixel);
			pixelS.addChild(pixelBM);*/
			addChild(pixelS);
			
			//右下角放大圖標
			scaleShape.graphics.beginFill(0xff8800, 1);
            scaleShape.graphics .moveTo(15,0);
            scaleShape.graphics .lineTo(0,15);
            scaleShape.graphics .lineTo(15,15);
            scaleShape.graphics .lineTo(15,0);
            scaleShape.graphics.endFill();
			scaleShape.x = page0.width;
			scaleShape.y = page0.height;
			addChild(scaleShape);
			
			addChild(_render);	//顯示便利貼
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, bitmapPgD);
			stage.addEventListener(MouseEvent.MOUSE_UP, bitmapPgU);
			goFlip();	//繪製便利貼翻頁效果
			
			pixel.draw(_render);
		}
		
		private function bitmapPgU(e:MouseEvent):void 
		{	
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, bitmapPgM);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, goChangeWH);
			this.stopDrag();
			scaleShape.visible = true;
			if (this.alpha < 1) {  //便利貼撕除
				Tweener.addTween(this, { y:this.y + 20, alpha:0, time:1, onComplete:kill } );
			}
		}
		
		private function bitmapPgD(e:MouseEvent):void 
		{ 
			//trace(pixel.getPixel(pixelS.mouseX,pixelS.mouseY).toString(16),_render.mouseX,this.mouseX);
			
			if (pixel.getPixel(pixelS.mouseX,pixelS.mouseY).toString(16) == p1color.toString(16)) { //顏色符合撕除角
				scaleShape.visible = false;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, bitmapPgM);
				goFlip(_render.mouseX,_render.mouseY);
			}else if (_render.mouseX > page0.width && _render.mouseY > page0.height) { //放大縮小角
				stage.addEventListener(MouseEvent.MOUSE_MOVE, goChangeWH);
			}else { //移動便利貼
				this.startDrag();
				scaleShape.visible = false;
			}
			
		}
		
		private function goChangeWH(e:MouseEvent):void 
		{	
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
				horizontal = true;  //末端在右邊
			}else {
				horizontal = false;  //末端在下邊
			}
			scaleShape.x = renderArray[0].x;
			scaleShape.y = renderArray[0].y;
			
			goFlip();
			updatePixel();
		}
		
		private function bitmapPgM(e:MouseEvent):void 
		{
			if (mouseX > 10 || mouseY > _render.y + 10) { 
				goFlip(_render.mouseX,_render.mouseY);
			}
			updatePixel();
			
			if (page0.width > page0.height) {  //寬型便利貼撕除偵測
				if (renderArray[1].x > page0.width * .9 || renderArray[2].x > page0.width * .9) {  //撕除預告
					this.alpha = .5;
				}else {
					this.alpha = 1;
				}
			}else {  //長型便利貼撕除偵測
				if (renderArray[1].y > page0.height * .9 || renderArray[2].y > page0.height * .9) {  //撕除預告
					this.alpha = .5;
				}else {
					this.alpha = 1;
				}
			}
		}
		
		//更新對照點陣圖
		private function updatePixel():void {
			pixel.dispose();
			renderMatrix.tx = this.x - (_render.transform.pixelBounds.x - _drawArea.transform.pixelBounds.x);
			renderMatrix.ty = this.y - (_render.transform.pixelBounds.y - _drawArea.transform.pixelBounds.y);
			pixel = new BitmapData(_render.transform.pixelBounds.width, _render.transform.pixelBounds.height);
			pixel.draw(_render,renderMatrix);
			//pixelBM.bitmapData = pixel;
			//trace(_render.transform.pixelBounds.x , this.x, _drawArea.transform.pixelBounds.x);
			pixelS.x = _render.transform.pixelBounds.x - this.x - _drawArea.transform.pixelBounds.x;
			pixelS.y = _render.transform.pixelBounds.y - this.y - _drawArea.transform.pixelBounds.y;
		}
		
		//移除便利貼
		private function kill():void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, bitmapPgD);
			stage.removeEventListener(MouseEvent.MOUSE_UP, bitmapPgU);
			page0.dispose();
			page1.dispose();
			pixel.dispose();
			Tweener.removeAllTweens();
			parent.removeChild(this);
		}
		
		private function goFlip(_x:Number = 20, _y:Number = 20):void {
			_render.graphics.clear(); 
			var o:Object=PageFlip.computeFlip(	new Point(_x, _y),	// flipped point
									new Point(0,0),		// of bottom-right corner
									page0.width,		// size of the sheet
									page1.height,
									horizontal,					// in horizontal mode
									1);					// sensibility to one 
           //trace(o.pPoints);
			PageFlip.drawBitmapSheet(o,					// computeflip returned object
									_render,					// target
									page0,		// bitmap page 0
									page1);		// bitmap page 1
			
			renderArray = o.pPoints;
		}
		
	}

}