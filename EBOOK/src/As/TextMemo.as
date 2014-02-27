package As 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class TextMemo extends Sprite 
	{
		private var tempX:Number;
		private var tempY:Number;
		private var isInitForData:Boolean = false;
		private var myDate:Date = new Date();
		
		public function TextMemo() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{	
			//initForData就跳出
			if (isInitForData) return;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, followMouse);
		}
		
		private function followMouse(e:MouseEvent):void 
		{	
			stage.addEventListener(MouseEvent.CLICK, startLink);
			this.x = stage.mouseX;
			this.y = stage.mouseY;
		}
		
		private function startLink(e:MouseEvent = null):void 
		{
			if (stage) {
				stage.removeEventListener(MouseEvent.CLICK, startLink);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, followMouse);
			}
			textEditorMc_mc.addEventListener(MouseEvent.MOUSE_DOWN, goDrag);
			textEditorMc_mc.addEventListener(MouseEvent.MOUSE_UP, goText);
			
			//沒有帶事件(initForData)就不用
			if (e) {
				textEditorPanel_mc.visible = true;
				title_txt.text = textEditorPanel_mc.title_txt.text = (myDate.month + 1) + "/" + myDate.date + " " + myDate.hours + ":" + myDate.minutes;
			}
			
			textEditorPanel_mc.addEventListener(MouseEvent.CLICK, settingText);
		}
		
		//建立存檔的連結,提供給LinkManage使用,Array內容看getData
		public function initForData(_a:Array):void {
			isInitForData = true;
			this.x = _a[0];
			this.y = _a[1];
			textEditorPanel_mc.tfText.text = _a[2];
			title_txt.text = textEditorPanel_mc.title_txt.text = _a[3];
			startLink();
		}
		
		private function settingText(e:MouseEvent):void 
		{	trace(e.target.name);
			if (e.target.name == "close_btn") {
				textEditorPanel_mc.visible = false;
			}else if (e.target.name == "delete_btn") {
				kill();
			}
		}
		
		//提供外部取得資料
		public function getData():Array {
			return [this.x,this.y,textEditorPanel_mc.tfText.text,title_txt.text,"TextMemo"];
		}
		
		//移動圖示
		private function goDrag(e:MouseEvent):void 
		{
			tempX = this.x;
			tempY = this.y;
			this.startDrag();
		}
		private function goText(e:MouseEvent):void 
		{
			this.stopDrag();
			//如果有移動就跳出
			if (tempX != this.x && tempY != this.y) return;
			textEditorPanel_mc.visible = true;
		}
		
		private function kill():void 
		{
			textEditorMc_mc.removeEventListener(MouseEvent.MOUSE_DOWN, goDrag);
			textEditorMc_mc.removeEventListener(MouseEvent.MOUSE_UP, goText);
			textEditorPanel_mc.removeEventListener(MouseEvent.CLICK, settingText);
			parent.removeChild(this);
		}
	}

}