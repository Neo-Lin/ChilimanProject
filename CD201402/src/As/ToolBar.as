package As 
{
	import As.Events.MainEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class ToolBar extends GM
	{
		private var arrowY:Number;
		private var st:SoundTransform = new SoundTransform(.5);
		private var saveDataSharedObject:SharedObject = SharedObject.getLocal("saveData", "/");
		
		public function ToolBar() 
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			stage.addEventListener(MainEvent.TOOL_BAR_HIDE, Hide);
			stage.addEventListener(MainEvent.TOOL_BAR_SHOW, Show);
			zone_mc.mouseEnabled = false;
			main_btn.addEventListener(MouseEvent.CLICK, openToolBar);
			index_btn.addEventListener(MouseEvent.CLICK, goIndex);
			index_btn.addEventListener(MouseEvent.MOUSE_OVER, btnPlaySound);
			ex_btn.addEventListener(MouseEvent.CLICK, goEx);
			ex_btn.addEventListener(MouseEvent.MOUSE_OVER, btnPlaySound);
			sound_mc.sound_btn.addEventListener(MouseEvent.CLICK, goSound);
			//sound_mc.addEventListener(MouseEvent.MOUSE_OVER, btnPlaySound);
			sound_mc.sound_btn.addEventListener(MouseEvent.MOUSE_OVER, soundOV);
			sound_mc.addEventListener(MouseEvent.ROLL_OUT, soundOU);
			exit_btn.addEventListener(MouseEvent.CLICK, goExit);
			exit_btn.addEventListener(MouseEvent.MOUSE_OVER, btnPlaySound);
			
			sound_mc.soundBar_mc.visible = false;
			sound_mc.soundBar_mc.arrow_mc.addEventListener(MouseEvent.MOUSE_DOWN, dragArrow);
			sound_mc.soundBar_mc.arrow_mc.addEventListener(MouseEvent.MOUSE_UP, stopArrow);
			
			//調整控制bar的位置
			if (saveDataSharedObject.data.volume) {
				st.volume = saveDataSharedObject.data.volume;
				sound_mc.soundBar_mc.bar_mc.gotoAndStop(uint(st.volume * 10 + 1));
				if (st.volume > .5) {
					sound_mc.soundBar_mc.arrow_mc.y -= 17 * (st.volume * 10 - 5);
				}else if (st.volume < .5) {
					sound_mc.soundBar_mc.arrow_mc.y = 17 * (5 - st.volume * 10);
				}
			}
			SoundMixer.soundTransform = st;
		}
		
		//音量控制================================================
		private function dragArrow(e:MouseEvent):void 
		{
			sound_mc.soundBar_mc.arrow_mc.addEventListener(Event.ENTER_FRAME, moveArrow);
			arrowY = mouseY;
		}
		private function moveArrow(e:Event):void 
		{
			if (mouseY - arrowY >= 17 && e.currentTarget.y < 85) {
				arrowY += 17;
				e.currentTarget.y += 17;
				sound_mc.soundBar_mc.bar_mc.prevFrame();
				st.volume -= .1;
				SoundMixer.soundTransform = st;
			}else if (mouseY - arrowY <= -17 && e.currentTarget.y > -85) {
				arrowY -= 17;
				e.currentTarget.y -= 17;
				sound_mc.soundBar_mc.bar_mc.nextFrame();
				st.volume += .1;
				SoundMixer.soundTransform = st;
			}
			
			saveDataSharedObject.data.volume = st.volume;
			saveDataSharedObject.flush();	//存入SharedObject
		}
		private function stopArrow(e:MouseEvent):void 
		{
			sound_mc.soundBar_mc.arrow_mc.removeEventListener(Event.ENTER_FRAME, moveArrow);
		}
		private function soundOU(e:MouseEvent):void 
		{
			sound_mc.soundBar_mc.visible = false;
			sound_mc.soundBar_mc.arrow_mc.removeEventListener(Event.ENTER_FRAME, moveArrow);
		}
		private function soundOV(e:MouseEvent):void 
		{
			stopSound("BTNSC");
			playSound("BTNSC", sound_sound);
			sound_mc.soundBar_mc.visible = true;
		}
		//================================================音量控制
		
		//滑鼠離開選單列自動縮回
		private function goClose(e:MouseEvent = null):void 
		{	
			stopSound("BTNSC");
			stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			zone_mc.removeEventListener(MouseEvent.MOUSE_MOVE, goClose);
			zone_mc.mouseEnabled = false;
			if (this.currentFrame != 1) {
				this.gotoAndPlay(this.totalFrames - this.currentFrame);
			}
		}
		
		//回主遊戲
		private function goIndex(e:MouseEvent):void 
		{	trace("index:",e.currentTarget.currentFrame);
			if (index_btn.currentFrame == 1) {
				this.gotoAndStop(1);
				this.visible = false;
				stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
				stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "G00.swf"));
			}
		}
		
		//遊戲說明
		private function goEx(e:MouseEvent):void 
		{	trace("ex:",e.currentTarget.currentFrame, SingletonValue.getInstance().nowSiteName);
			if (ex_btn.currentFrame == 1) {
				if(SingletonValue.getInstance().nowSiteName == "G00.swf") {	//如果在主場景就載入主場景的說明動畫
					stage.dispatchEvent(new MainEvent(MainEvent.LOAD_EX, true,  "G00_G_EX.swf"));
				} else if(SingletonValue.getInstance().nowSiteName == "221B.swf") {	//如果在221B就載入221B的說明動畫
					stage.dispatchEvent(new MainEvent(MainEvent.LOAD_EX, true,  "221B_EX.swf"));
				} else if (SingletonValue.getInstance().unitNum == 2) {	//其他就依照unitNum來載入相對應的說明動畫
					stage.dispatchEvent(new MainEvent(MainEvent.LOAD_EX, true,  "QEX"));
				} else if(SingletonValue.getInstance().unitNum == 4) {
					stage.dispatchEvent(new MainEvent(MainEvent.LOAD_EX, true,  "GEX"));
				}
				this.gotoAndPlay("close");
				//stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			}
		}
		
		private function goSound(e:MouseEvent):void 
		{	
			//sound_mc.soundBar_mc.visible = true;
		}
		
		private function goExit(e:MouseEvent):void 
		{	trace("Exit:",e.currentTarget.currentFrame);
			if (exit_btn.currentFrame == 1) {
				stopSound("BTNSC");
				stage.dispatchEvent(new MainEvent(MainEvent.EXIT, true));
				this.gotoAndPlay("close");
				//stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			}
		}
		
		private function openToolBar(e:MouseEvent):void 
		{	trace("open");
			playSound("BTNSC", sound_btnClick);
			zone_mc.addEventListener(MouseEvent.MOUSE_MOVE, goClose);
			zone_mc.mouseEnabled = true;
			//先將所有按鈕都恢復成可點選狀態
			index_btn.gotoAndStop(1);
			ex_btn.gotoAndStop(1);
			trace("ex_btn.currentFrame:", ex_btn.currentFrame);
			//若沒有接受任何案件,就不能按前往主遊戲的按鈕
			if (SingletonValue.getInstance().caseNum == 4 || SingletonValue.getInstance().nowSiteName == "G00.swf") {
				index_btn.gotoAndStop(2);
			}
			if (SingletonValue.getInstance().caseNum == 2 && SingletonValue.getInstance().nowSiteName == "Q") {
				ex_btn.gotoAndStop(2);
				trace("ex_btn.currentFrame:", ex_btn.currentFrame);
			}
			stage.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
			this.gotoAndPlay("open");
		}
		
		private function btnPlaySound(e:MouseEvent):void 
		{	
			stopSound("BTNSC");
			if (e.currentTarget.name == "index_btn") {
				playSound("BTNSC", sound_index);
			}else if (e.currentTarget.name == "ex_btn") {
				playSound("BTNSC", sound_ex);
			}else if (e.currentTarget.name == "exit_btn") {
				playSound("BTNSC", sound_exit);
			}
		}
		
		//隱藏
		public function Hide(e:MainEvent):void { 
			this.visible = false;
		}
		
		//顯示
		public function Show(e:MainEvent):void {
			this.visible = true;
		}
	}

}