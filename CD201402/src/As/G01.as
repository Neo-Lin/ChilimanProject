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
		private var userInvincible:Boolean = false;		//人物無敵狀態
		private var lineArray:Array = [[Line_l, 500, 384, 90], [Line_l_0, 517, 384, 90], [Line_c, 512, 384, 90], [Line_r_0, 508, 384, -90], [Line_r, 525, 384, -90]];
		private var lineArrayNum:uint;
		
		public function G01() 
		{
			
		}
		
		//進入遊戲
		override public function EnterGame():void
		{
			//測試模式
			if (SingletonValue.getInstance().testMode) {
				count_mc.gotoAndPlay(76);
				life_mc.gotoAndStop(4);
				lineTotalAmount = 0;
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
			
			if (lineTotalAmount > 5) {
				_time = (Math.random() + 1) * 1000; //trace(_time);
			}else {
				_time = (Math.random() + 3) * 1000; //trace(_time);
			}
				
			myTime.delay = _time;
			
			//設定出現那一位置的紅外線
			var _n:Number = Math.random();  //trace(_n);
			if (_n < .2) {
				lineArrayNum = 0;
				if(lineTotalAmount > 20){
					addLine(lineArray[lineArrayNum][0]);
					if (_n < .1) {
						lineArrayNum = 2;
					}else {
						lineArrayNum = 1;
					}
				}
			}else if(_n > .2 && _n < .4) {
				lineArrayNum = 1;
				if(lineTotalAmount > 20){
					addLine(lineArray[lineArrayNum][0]);
					if (_n < .3) {
						lineArrayNum = 2;
					}else {
						lineArrayNum = 3;
					}
				}
			}else if(_n > .4 && _n < .6) {
				lineArrayNum = 2;
				if(lineTotalAmount > 20){
					addLine(lineArray[lineArrayNum][0]);
					lineArrayNum = 0;
					addLine(lineArray[lineArrayNum][0]);
					lineArrayNum = 4;
				}
			}else if(_n > .6 && _n < .8) {
				lineArrayNum = 3;
				if(lineTotalAmount > 20){
					addLine(lineArray[lineArrayNum][0]);
					if (_n < .7) {
						lineArrayNum = 2;
					}else {
						lineArrayNum = 1;
					}
				}
			}else if(_n > .8) {
				lineArrayNum = 4;
				if(lineTotalAmount > 20){
					addLine(lineArray[lineArrayNum][0]);
					if (_n < .9) {
						lineArrayNum = 3;
					}else {
						lineArrayNum = 2;
					}
				}
			}
			addLine(lineArray[lineArrayNum][0]);
			lineTotalAmount ++;
			if (lineTotalAmount > 40) {
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
			myTime.delay = 4000;
			myTime.start();
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
		private function addLine(line:Class):void {
			var _line = new line;
			_line.x = lineArray[lineArrayNum][1];
			_line.y = lineArray[lineArrayNum][2];
			_line.rotation = lineArray[lineArrayNum][3];
			_line.gotoAndPlay(1);
			_line.addEventListener("touch", Touch);
			_line.addEventListener("come", lineCome);
			_line.addEventListener("remove", lineRemove);
			this.addChild(_line);
			this.setChildIndex(_line, getChildIndex(cola_mc)-1);
		}
		//=====================================================產生紅外線
		
		//判斷可樂球有沒有被掃中
		private function Touch(e:Event):void 
		{
			e.currentTarget.removeEventListener("touch", Touch);
			e.currentTarget.removeEventListener("come", lineCome);
			//沒掃中就把紅外線移到可樂球上層
			this.setChildIndex(e.currentTarget as MovieClip, this.numChildren-1);
			danger_mc.visible = false;
			/*if (e.currentTarget.hitTestPoint(cola_mc.x, cola_mc.y)) {
				playSound("TSC", sound_cola);
				colaGG(e);
			}*/
			if (!userInvincible && cola_mc.colaTouch_mc.hitTestObject(e.currentTarget as MovieClip)) {
				playSound("TSC", sound_cola);
				colaGG(e);
			}
			/*if (!userInvincible && cola_mc.x > 430 && cola_mc.x < 600) {
				
			}*/
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
					if (getQualifiedClassName(_mc) == "Line_r" || 
						getQualifiedClassName(_mc) == "Line_r_0" || 
						getQualifiedClassName(_mc) == "Line_l" || 
						getQualifiedClassName(_mc) == "Line_l_0" || 
						getQualifiedClassName(_mc) == "Line_c" ) { 
						_mc.gotoAndStop(1);
						_mc.removeEventListener("touch", Touch);
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
			e.currentTarget.removeEventListener("touch", Touch);
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
			line_d_mc.gotoAndStop(1);
			line_d_mc.visible = false;
			//this.removeChild(line_d_mc);
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
			bg_mc.removeEventListener("start", endStart);
			stopSound("TSC");
			die_mc.visible = false;
			life_mc.gotoAndStop(1);
			lineTotalAmount = 0;
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
				if(cola_mc.x > 250) cola_mc.x -= moveSpeed;
				cola_mc.gotoAndStop("l");
			}
			if (rightPressed)
			{
				if(cola_mc.x < 790) cola_mc.x += moveSpeed;
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
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
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
					stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
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