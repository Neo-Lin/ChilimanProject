package As 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsStroke;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class MorphTool extends Sprite 
	{
		private var _obj:Object;
		private var _typeNum:int;
		private var _w:int;
		private var _slant:Number;
		private var pixel:BitmapData; 
		private var _colorNum:int = 0;
		private var renderMatrix:Matrix = new Matrix();
		private var penOrPaint:String = "";
		
		public function MorphTool() 
		{
			freeTran.addEventListener(MouseEvent.MOUSE_MOVE, freeTranMM);
			mt_pen_mc.addEventListener(MouseEvent.CLICK, changePen);
			mt_paint_mc.addEventListener(MouseEvent.CLICK, changePaint);
			mt_colorPanel_mc.addEventListener(MouseEvent.CLICK, closeColorPanel);
		}
		
		private function closeColorPanel(e:MouseEvent):void 
		{
			if (e.target.name == "mt_colseColorPanel_btn") {
				mt_colorPanel_mc.visible = false;
			}else if (e.target.name == "mt_color_mc") {
				initPixel();
				mt_colorPanel_mc.visible = false;
				//重畫圖形,改線條顏色
				var v:Vector.<IGraphicsData> = _obj.graphics.readGraphicsData(false);
				var n:int = v.length;
				var _g:Shape = new Shape();
				for (var i:int = 3; i < n; i++) {
					if (v[i] as GraphicsPath) {
						var p:GraphicsPath = v[i] as GraphicsPath;
					}else if (v[i] as GraphicsStroke) {
						var gs:GraphicsStroke = v[i] as GraphicsStroke;
						if (gs.fill) {		//一組筆劃很奇怪的會帶兩個GraphicsStroke,其中一個才有正確的fill屬性,所以要判斷
							var gsf:GraphicsSolidFill = gs.fill as GraphicsSolidFill;	//取出thickness(筆粗),color,alpha)
							//trace("graphicsDataTemp2::::::",gs.thickness, gsf.color, gsf.alpha);
						}
					}
				}
				if (penOrPaint == "pen") {
					var gf:GraphicsSolidFill = v[0] as GraphicsSolidFill;
					_g.graphics.beginFill(gf.color,gf.alpha);
					_g.graphics.lineStyle(5, _colorNum);
				}else if (penOrPaint == "paint") {
					_g.graphics.beginFill(_colorNum, 1);
					_g.graphics.lineStyle(5, gsf.color);
				}
				_g.graphics.drawPath(p.commands, p.data);
				//複製新的圖形
				_obj.graphics.copyFrom(_g.graphics);
			}
		}
		
		//重製選色用點陣圖
		private function initPixel():void 
		{
			pixel = new BitmapData(this.width, this.height);
			renderMatrix.tx = -freeTran.x + freeTran.width / 2;
			renderMatrix.ty = -freeTran.y + freeTran.height / 2;
			pixel.draw(this, renderMatrix);
			_colorNum = pixel.getPixel(mouseX -freeTran.x + freeTran.width / 2, mouseY-freeTran.y + freeTran.height / 2);
			pixel.dispose();
			/*var bm:Bitmap = new Bitmap(pixel);
			addChild(bm);*/
		}
		
		private function freeTranMM(e:MouseEvent):void 
		{
			mt_pen_mc.x = freeTran.x - freeTran.width / 2 + 15;
			mt_pen_mc.y = freeTran.y - freeTran.height / 2 + 13;
			mt_paint_mc.x = mt_pen_mc.x + 30;
			mt_paint_mc.y = mt_pen_mc.y;
		}
		
		private function changePen(e:MouseEvent):void 
		{
			mt_colorPanel_mc.y = mt_pen_mc.y + mt_pen_mc.height;
			mt_colorPanel_mc.x = mt_pen_mc.x + mt_pen_mc.width;
			mt_colorPanel_mc.visible = true;
			penOrPaint = "pen";
		}
		
		private function changePaint(e:MouseEvent):void 
		{
			mt_colorPanel_mc.y = mt_paint_mc.y + mt_paint_mc.height;
			mt_colorPanel_mc.x = mt_paint_mc.x + mt_paint_mc.width;
			mt_colorPanel_mc.visible = true;
			penOrPaint = "paint";
		}
		
		public function cancel():void {
			freeTran.pic=null;
		}
		
		private function thisClick(e:MouseEvent):void 
		{
			trace("MorphTool:::",e.currentTarget, e.target.name, this.parent, e.target.name.indexOf("dot"));
			if (e.target.name != "body" && e.target.name.indexOf("dot") == -1 && e.target.name.indexOf("mt_") == -1) {
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, thisClick);
				cancel();
				parent.removeChild(this);
			}
		}
		
		private function inStage(e:MouseEvent):void 
		{	trace("add!!!");
			removeEventListener(MouseEvent.MOUSE_OVER, inStage);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, thisClick);
		}
		
		public function init(obj:DisplayObject) 
		{
			_obj = obj;
			freeTran.dragPic(obj);
			this.addEventListener(MouseEvent.MOUSE_OVER, inStage);
			
			/*this.graphics.clear();
			_typeNum = typeNum;
			this.x = _obj.x - _obj.width / 2;
			this.y = _obj.y - _obj.height / 2;
			_w = p1.width / 2;
			
			//Pen類別畫出來的多角形都會有偏移的問題,而且是隨著形狀大小而改變,
			//所以用形狀的大小計算出大概的偏移量
			var _s:Number = _obj.height / 100;
			if (typeNum == 5) {	//三角
				_slant = 18 * _s;
			}else if (typeNum == 8) {	//五角
				_slant = 4 * _s;
			}else if (typeNum == 9) {	//星型
				_slant = 7 * _s;
			}else {
				_slant = 0;
			}
			changePoint();*/
		}
		
		/*private function changePoint(e:Event = null):void {
			p1.x = - _w;
			p1.y = - _w - _slant;
			p2.x = _obj.width / 2 - _w;
			p2.y = - _w - _slant;
			p3.x = _obj.width - _w;
			p3.y = - _w - _slant;
			p4.x = - _w;
			p4.y = _obj.height / 2 - _w - _slant;
			p5.x = _obj.width - _w;
			p5.y = _obj.height / 2 - _w - _slant;
			p6.x = - _w;
			p6.y = _obj.height - _w - _slant;
			p7.x = _obj.width / 2 - _w;
			p7.y = _obj.height - _w - _slant;
			p8.x = _obj.width - _w;
			p8.y = _obj.height - _w - _slant;
			
			this.graphics.lineStyle(0, 0);
			this.graphics.moveTo(0, -_slant);
			this.graphics.lineTo(p3.x + _w, p3.y + _w);
			this.graphics.lineTo(p8.x + _w, p8.y + _w);
			this.graphics.lineTo(p6.x + _w, p6.y + _w);
			this.graphics.lineTo(0, -_slant);
		}*/
	}

}