package As 
{
	import As.Events.MainEvent;
	import avmplus.getQualifiedClassName;
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Neo
	 */
	public class G01 extends GM 
	{
		//-----------------------------------------
		//cola_mc			可樂球
		//count_mc			倒數動畫
		//end_mc			終點動畫
		//danger_mc			警告
		//line_d_mc			橫的紅外線,只有這條不是程式產生的
		//life_mc			血條
		//life_1_mc			扣血圖示
		//die_mc            失敗視窗
		//bg_mc				背景
		//-----------------------------------------
		private var upPressed:Boolean = false;
		private var downPressed:Boolean = false;
		private var leftPressed:Boolean = false;
		private var rightPressed:Boolean = false;
		private var moveSpeed:uint = 10;				//可樂球移動速度
		private var lineTotalAmount:uint = 0;			//計算紅外線數量
		private var _time:uint;
		private var myTime:Timer = new Timer(_time, 1);
		private var userInvincible:Boolean = false;	//人物無敵狀態
		
		public function G01() 
		{
			
		}
		
		//進入遊戲
		override public function EnterGame():void
		{
			//測試模式
			if (SingletonValue.getInstance().testMode) {
				count_mc.gotoAndPlay(76);
				life_mc.gotoAndStop(5);
				lineTotalAmount = 17;
			}
			count_mc.addEventListener("count", startGame);	//倒數動畫結束後開始遊戲
			end_mc.gotoAndStop(1);
			end_mc.addEventListener("end", goWin);
			line_d_mc.gotoAndStop(1);
			danger_mc.visible = false;
			life_1_mc.visible = false;
			bg_mc.stop();
			die_mc.visible = false;
			die_mc.again_btn.addEventListener(MouseEvent.CLICK, again);
			die_mc.again_btn.addEventListener(MouseEvent.MOUSE_OVER, btnAgainOver);
			die_mc.again_btn.addEventListener(MouseEvent.MOUSE_OUT, btnOut);
			die_mc.exit_btn.addEventListener(MouseEvent.CLICK, exit);
			die_mc.exit_btn.addEventListener(MouseEvent.MOUSE_OVER, btnExitOver);
			die_mc.exit_btn.addEventListener(MouseEvent.MOUSE_OUT, btnOut);
			cola_mc.gotoAndStop(24);
			cola_mc.addEventListener("jfinish", jFinish);
			cola_mc.addEventListener("ggfinish", jFinish);
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			
		}
		
		private function goWin(e:Event):void 
		{
			end_mc.stop();
			bg_mc.stop();
			cancelAllEventListener();
			cola_mc.gotoAndStop("happy");
			
			Tweener.addTween(this, { time:3, onComplete:function() {
				this.gotoAndStop(2);
			} } );
		}
		
		private function reTime(e:TimerEvent):void 
		{ 
			//設定下次移動時間
			_time = (Math.random() * 3 + 1) * 1000; //trace(_time);
			myTime.delay = _time;
			
			//設定出現那一位置的紅外線
			var _n:Number = Math.random() * 3; 
			if (_n < 1) {
				addLineL();
			}else if(_n > 1 && _n < 2) {
				addLineC();
			}else if(_n > 2) {
				addLineR();
			}
			lineTotalAmount ++;
			if (lineTotalAmount > 20) {
				//過關
				bg_mc.addEventListener("start", endStart);
				line_d_mc.addEventListener("remove", lineDKill);
				return;
			}
			myTime.start();
		}
		
		private function endStart(e:Event):void 
		{
			bg_mc.removeEventListener("start", endStart);
			end_mc.play();
		}
		
		private function startGame(e:Event):void 
		{
			bg_mc.play();
			cola_mc.gotoAndStop(1);
			addAllEventListener();
			reTime(null);
			//場景上橫的紅外線偵聽
			line_d_mc.visible = true;
			line_d_mc.play();
			line_d_mc.addEventListener("touch", dTouch);
			line_d_mc.addEventListener("come", lineCome);
			line_d_mc.addEventListener("remove", lineDRemove);
		}
		
		private function addAllEventListener():void {
			cola_mc.addEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
		}
		
		private function cancelAllEventListener():void {
			upPressed = downPressed = leftPressed = rightPressed = false;
			cola_mc.removeEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
		}
		
		//產生紅外線
		private function addLineC():void {
			var _line:Line_c = new Line_c();
			_line.x = 512;
			_line.y = 384;
			_line.rotation = 90;
			_line.addEventListener("touch", cTouch);
			_line.addEventListener("come", lineCome);
			_line.addEventListener("remove", lineRemove);
			this.addChild(_line);
			this.setChildIndex(_line, getChildIndex(cola_mc)-1);
		}
		private function addLineR():void {
			var _line:Line_r = new Line_r();
			_line.x = 525;
			_line.y = 384;
			_line.rotation = -90;
			_line.addEventListener("touch", rTouch);
			_line.addEventListener("come", lineCome);
			_line.addEventListener("remove", lineRemove);
			this.addChild(_line);
			this.setChildIndex(_line, getChildIndex(cola_mc) - 1);
		}
		private function addLineL():void {
			var _line:Line_l = new Line_l();
			_line.x = 500;
			_line.y = 384;
			_line.rotation = 90;
			_line.addEventListener("touch", lTouch);
			_line.addEventListener("come", lineCome);
			_line.addEventListener("remove", lineRemove);
			this.addChild(_line);
			this.setChildIndex(_line, getChildIndex(cola_mc)-1);
		}
		/*private function addLineD():void {
			var _line:Line_d = new Line_d();
			_line.x = 512;
			_line.y = 383;
			_line.addEventListener("touch", dTouch);
			_line.addEventListener("come", lineCome);
			this.addChild(_line);
			this.swapChildren(_line, cola_mc);
		}*/
		//=====================================================產生紅外線
		
		//判斷可樂球有沒有被掃中
		private function cTouch(e:Event):void 
		{
			e.currentTarget.removeEventListener("touch", cTouch);
			e.currentTarget.removeEventListener("come", lineCome);
			//沒掃中就把紅外線移到可樂球上層
			this.setChildIndex(e.currentTarget as MovieClip, this.numChildren-1);
			danger_mc.visible = false;
			if (!userInvincible && cola_mc.x > 430 && cola_mc.x < 600) {
				playSound("TSC", sound_cola);
				colaGG(e);
			}
		}
		private function rTouch(e:Event):void 
		{
			e.currentTarget.addEventListener(Event.ENTER_FRAME, goCheckTouch);
			e.currentTarget.removeEventListener("touch", rTouch);
			e.currentTarget.removeEventListener("come", lineCome);
			this.setChildIndex(e.currentTarget as MovieClip, this.numChildren-1);
			danger_mc.visible = false;
			if (!userInvincible && cola_mc.x > 670) {
				playSound("TSC", sound_cola);
				colaGG(e);
			}
		}
		
		private function goCheckTouch(e:Event):void 
		{
			trace(cola_mc.hitTestObject(e.currentTarget as MovieClip));
		}
		private function lTouch(e:Event):void 
		{
			e.currentTarget.removeEventListener("touch", lTouch);
			e.currentTarget.removeEventListener("come", lineCome);
			this.setChildIndex(e.currentTarget as MovieClip, this.numChildren-1);
			danger_mc.visible = false;
			if (!userInvincible && cola_mc.x < 345) {
				playSound("TSC", sound_cola);
				colaGG(e);
			}
		}
		private function dTouch(e:Event):void 
		{
			//e.currentTarget.removeEventListener("touch", dTouch);
			danger_mc.visible = false;
			if (!userInvincible && cola_mc.currentLabel != "d" && cola_mc.currentLabel != "j") {
				playSound("TSC", sound_cola);
				colaGG(e);
			}else {
				//跳過就把紅外線移到可樂球上層
				this.setChildIndex(e.currentTarget as MovieClip, this.numChildren-1);
			}
		}
		private function colaGG(e:Event):void { 
			if (e.currentTarget.name != "line_d_mc") {
				this.removeChild(e.currentTarget as MovieClip);
				e.currentTarget.removeEventListener("remove", lineRemove);
			}
			life_1_mc.visible = true;
			cancelAllEventListener();
			life_mc.nextFrame();
			cola_mc.gotoAndStop("gg");
			cola_mc.alpha = .4;
			//失敗
			if (life_mc.currentFrame == 6) {	trace("失敗");
				myTime.stop();
				this.addChild(die_mc);
				die_mc.visible = true;
				playSound("TSC", sound_die);
				bg_mc.stop();
				line_d_mc.visible = false;
				line_d_mc.gotoAndStop(1);
				line_d_mc.removeEventListener("touch", dTouch);
				line_d_mc.removeEventListener("come", lineCome);
				cola_mc.removeEventListener("jfinish", jFinish);
				cola_mc.removeEventListener("ggfinish", jFinish);
				for (var i:uint = 0; i < this.numChildren; i++) { 
					var _mc:MovieClip = this.getChildAt(i) as MovieClip;
					if (getQualifiedClassName(_mc) == "Line_r" || getQualifiedClassName(_mc) == "Line_l" || getQualifiedClassName(_mc) == "Line_c" ) { 
						_mc.gotoAndStop(1);
						_mc.removeEventListener("touch", lTouch);
						_mc.removeEventListener("touch", cTouch);
						_mc.removeEventListener("touch", rTouch);
						_mc.removeEventListener("come", lineCome);
						_mc.removeEventListener("remove", lineRemove);
						this.removeChild(_mc);
						i--;
					}
				}
				danger_mc.visible = false;
				return;
			}
			userInvincible = true;
			//三秒後恢復正常
			Tweener.addTween(cola_mc, { alpha:1, time:3, transition:"easeInBounce", onComplete:function() {
				userInvincible = false;
				life_1_mc.visible = false;
			} } );
		}
		private function lineRemove(e:Event):void 
		{
			e.currentTarget.removeEventListener("touch", lTouch);
			e.currentTarget.removeEventListener("touch", cTouch);
			e.currentTarget.removeEventListener("touch", rTouch);
			e.currentTarget.removeEventListener("come", lineCome);
			e.currentTarget.removeEventListener("remove", lineRemove);
		}
		private function lineDRemove(e:Event):void 
		{
			this.setChildIndex(line_d_mc, getChildIndex(cola_mc)-1);
		}
		private function lineDKill(e:Event):void 
		{
			line_d_mc.removeEventListener("touch", dTouch);
			line_d_mc.removeEventListener("come", lineCome);
			line_d_mc.removeEventListener("remove", lineDRemove);
			line_d_mc.removeEventListener("remove", lineDKill);
			this.removeChild(line_d_mc);
		}
		//===================================================判斷可樂球有沒有被掃中
		
		//警告
		private function lineCome(e:Event):void 
		{ 
			this.addChild(danger_mc);
			danger_mc.visible = true;
		}
		
		//再來一次
		private function again(e:MouseEvent):void 
		{
			stopSound("TSC");
			die_mc.visible = false;
			life_mc.gotoAndStop(1);
			myTime.start();
			cola_mc.alpha = 1;
			count_mc.visible = true;
			count_mc.gotoAndPlay(1);
			EnterGame();
		}
		//離開
		private function exit(e:MouseEvent):void 
		{
			stopSound("TSC");
			this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "G00.swf"));
		}
		
		//按鈕音效
		private function btnOut(e:MouseEvent):void 
		{
			stopSound("BTNSC");
		}
		private function btnExitOver(e:MouseEvent):void 
		{
			stopSound("TSC");
			playSound("BTNSC", sound_exit);
		}
		private function btnAgainOver(e:MouseEvent):void 
		{
			stopSound("TSC");
			playSound("BTNSC", sound_again);
		}
		
		private function fl_MoveInDirectionOfKey(event:Event)
		{	//trace(this.numChildren);
			/*if (upPressed)
			{
				cola_mc.y -= moveSpeed;
			}*/
			if (downPressed)
			{
				//cola_mc.y += moveSpeed;
				cola_mc.gotoAndStop("d");
			}
			if (leftPressed)
			{
				if(cola_mc.x > 210) cola_mc.x -= moveSpeed;
				cola_mc.gotoAndStop("l");
			}
			if (rightPressed)
			{
				if(cola_mc.x < 820) cola_mc.x += moveSpeed;
				cola_mc.gotoAndStop("r");
			}
		}

		private function fl_SetKeyPressed(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP:
				{
					upPressed = true;
					cancelAllEventListener();
					cola_mc.gotoAndStop("j");
					break;
				}
				case Keyboard.DOWN:
				{
					downPressed = true;
					break;
				}
				case Keyboard.LEFT:
				{
					leftPressed = true;
					break;
				}
				case Keyboard.RIGHT:
				{
					rightPressed = true;
					break;
				}
			}
		}
		
		//可樂球結束跳躍&&可樂球結束驚嚇
		private function jFinish(e:Event):void 
		{
			addAllEventListener();
			cola_mc.gotoAndStop(1);
		}

		private function fl_UnsetKeyPressed(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP:
				{
					upPressed = false;
					break;
				}
				case Keyboard.DOWN:
				{
					downPressed = false;
					cola_mc.gotoAndStop(1);
					break;
				}
				case Keyboard.LEFT:
				{
					leftPressed = false;
					cola_mc.gotoAndStop(1);
					break;
				}
				case Keyboard.RIGHT:
				{
					rightPressed = false;
					cola_mc.gotoAndStop(1);
					break;
				}
			}
		}
	}

}