package As 
{
	import As.Events.MainEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	/**
	 * ...
	 * @author Neo
	 */
	public class G02_Q extends GM 
	{
		//==============================
		//pass_mc				過關字卡
		//	pass_btn				確定紐
		//Abox1_mc - Abox23_mc  答題框
		//	correct_mc				標點符號,影格標籤對應: a=， b=。 c=「 d=」 e=: f=! g=?
		//Abtna_btn - Abtng_btn	答題紐
		//sign_mc				答題紐外觀的標點符號
		//enter_btn				確定作答紐
		//==============================
		var signTag:String;
		var answer:Array = ["e", "e", "e", "a", "c", "d", "a", "b", "e", "c", "a", "f", "d", "a", "b", "a", "g", "a", "a", "c", "d", "a", "g"];
		var passNum:uint = 0;	//答對的題數
		var mySound:Sound;
		var chk1:Sound = new sound_chk1();
		var chk2:Sound = new sound_chk2();
		private var SC:SoundChannel;
		
		public function G02_Q() 
		{
			
		}
		
		override public function EnterGame():void {
			pass_mc.visible = false;
			pass_mc.pass_btn.addEventListener(MouseEvent.CLICK, goPass);
			//只需顯示不須任何滑鼠事件
			sign_mc.mouseEnabled = false;
			sign_mc.mouseChildren = false;
			
			var _n:uint = this.numChildren;
			for (var i:uint = 0; i < _n; i++) {
				if (this.getChildAt(i).name.substr(0, 4) == "Abtn") {	//按到標點符號,讓符號跟著滑鼠跑
					this.getChildAt(i).addEventListener(MouseEvent.CLICK, takeSign);
				}else if (this.getChildAt(i).name.substr(0, 4) == "Abox") {
					this.getChildAt(i).addEventListener(MouseEvent.CLICK, changeBox);
					this.getChildAt(i).addEventListener(MouseEvent.MOUSE_OVER, BoxIn);
					this.getChildAt(i).addEventListener(MouseEvent.MOUSE_OUT, BoxOut);
				}
			}
			
			enter_btn.addEventListener(MouseEvent.CLICK, goCheck);
			enter_btn.addEventListener(MouseEvent.MOUSE_OVER, goIn);
			enter_btn.addEventListener(MouseEvent.MOUSE_OUT, goOut);
		}
		
		private function BoxIn(e:MouseEvent):void 
		{
			if (sign_mc.x == mouseX && sign_mc.y == mouseY) {
				e.currentTarget.brim_mc.visible = true;
			}
		}
		
		private function BoxOut(e:MouseEvent):void 
		{
			e.currentTarget.brim_mc.visible = false;
		}
		
		private function goOut(e:MouseEvent):void 
		{
			stopSound("BTNSC");
		}
		
		private function goIn(e:MouseEvent):void 
		{
			playSound("BTNSC", sound_enter);
		}
		
		//檢查是否答對
		private function goCheck(e:MouseEvent):void 
		{
			//測試模式
			if (SingletonValue.getInstance().testMode) {
				pass_mc.visible = true;
				mySound = new sound_pass();
				mySound.play();
				stage.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
				return;
			}
			//SoundMixer.stopAll();
			stopSound("BTNSC");
			passNum = 0;
			initSign();
			var _n:uint = answer.length;
			for (var i:uint = 1; i <= _n; i++) {
				var _mc:MovieClip = this["Abox" + i + "_mc"];
				if (_mc.correct_mc.currentLabel == answer[i - 1]) {
					passNum++;
					_mc.removeEventListener(MouseEvent.CLICK, changeBox);
					_mc.removeEventListener(MouseEvent.MOUSE_OVER, BoxIn);
					_mc.removeEventListener(MouseEvent.MOUSE_OUT, BoxOut);
				}else {
					if (_mc.correct_mc.currentLabel) {
						_mc.correct_mc.gotoAndStop(_mc.correct_mc.currentLabel.substr(0,1) + "e");
					}
					_mc.gotoAndPlay(2);
				}
			}
			enter_btn.removeEventListener(MouseEvent.CLICK, goCheck);
			//全對顯示過關字卡
			if (passNum == answer.length) {
				pass_mc.visible = true;
				mySound = new sound_pass();
				SC = mySound.play();
				stage.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
			}else {
				mySound = new sound_again();
				SC = mySound.play();
			}
			SC.addEventListener(Event.SOUND_COMPLETE, completeSound);
		}
		
		private function completeSound(e:Event):void 
		{
			SC.removeEventListener(Event.SOUND_COMPLETE, completeSound);
			enter_btn.addEventListener(MouseEvent.CLICK, goCheck);
		}
		
		//答題框貼上使用者選擇的符號
		private function changeBox(e:MouseEvent):void 
		{
			if (sign_mc.x == mouseX && sign_mc.y == mouseY) {
				chk2.play();
				e.currentTarget.correct_mc.gotoAndStop(signTag);
				initSign();
			}
		}
		
		//讓使用者選擇的符號跟隨滑鼠
		private function takeSign(e:MouseEvent):void 
		{
			chk1.play();
			signTag = e.currentTarget.name.substr(4, 1);	
			sign_mc.gotoAndStop(signTag);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, goMouse);
		}
		
		private function goMouse(e:MouseEvent):void 
		{	
			sign_mc.x = mouseX;
			sign_mc.y = mouseY;
		}
		
		//取消跟隨滑鼠的符號
		private function initSign():void 
		{
			sign_mc.x = sign_mc.y = 0;
			sign_mc.gotoAndStop(0);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, goMouse);
		}
		
		//暫停
		override public function Pause(e:MainEvent):void { 
			
		}
		
		//結束暫停
		override public function UnPause(e:MainEvent):void { 
			
		}
		
		//過關
		private function goPass(e:MouseEvent):void 
		{
			trace("過關!!");
			stage.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "GEX"));
		}
	}

}