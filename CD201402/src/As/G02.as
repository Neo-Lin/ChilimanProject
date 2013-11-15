package As 
{
	import As.Events.MainEvent;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Neo
	 */
	public class G02 extends GM 
	{
		//-----------------------------------------
		//ex_mc				示範動畫
		//count_mc			倒數動畫
		//ch_mc				關卡文字
		//user_mc			偵測碰撞用可樂球
		//u_mc				可樂球
		//map_mc			地圖可走範圍
		//gold*_mc			黃金
		//restart_btn		重新開始按鈕
		//ex_btn			提示按鈕
		//-----------------------------------------
		
		//上下左右開關
		private var upPressed:Boolean = false;
		private var downPressed:Boolean = false;
		private var leftPressed:Boolean = false;
		private var rightPressed:Boolean = false;
		private var directionTxt:String = "d";
		
		private var mapBD:BitmapData;
		private var userBD:BitmapData;
		
		private var userSpeed:int = 67;
		
		private var nowChNum:uint = 0;
		private var nowCh:String;					//nowCh = allCh[nowChNum];
		private var allStar:Array = new Array();	//所有關卡星星位置
		private var allGold:Array = new Array();	//所有關卡黃金位置
		private var allCh:Array = new Array();		//所有關卡影格名稱
		private var allUser:Array = new Array();	//所有關卡可樂球初始位置
		private var chk1:Sound = new sound_chk1();
		private var chk2:Sound = new sound_chk2();
		
		
		public function G02() 
		{	
		}
		
		private function initData():void {
			allStar = [
						[[368.4, 355.4], [368.85, 288.5], [434.95, 422.5], [502.05, 288.3]],
						[[470, 187.8], [604.3, 187.8]],
						[[402.1, 187.8], [469.25, 187.8], [536.4, 187.8]],
						[[267.15, 389.25], [334.3, 389.25], [267.15, 456.4], [334.3, 456.4]],
						[[268.65, 320.6], [334.3, 186.3], [401.45, 186.3], [604.3, 187.8], [536.55, 522.95], [603.7, 522.95]]
						]
						
			allGold = [
						[[402.4, 389.4], [402.85, 322.5], [468.95, 456.5], [536.05, 322.3]],
						[[536.35, 320.75], [469.2, 456.55]],
						[[469.2, 388.45], [334.5, 322.75], [266.85, 457.05]],
						[[604, 321.3], [536.35, 388.95], [402.05, 321.25], [266.85, 254.15]],
						[[402.05, 522.7], [335, 455.55], [402.05, 455.55], [469.2, 455.55], [469.7, 389.9], [401.55, 321.3]]
						]
						
			allCh = ["a", "b", "c", "d", "e"];
			
			allUser = [[468.4, 390.35],[201.4, 523.65],[333.1, 255.3],[265.05, 323.85],[404.1, 389.45]]
		}
		
		//進入遊戲
		override public function EnterGame():void
		{
			//測試模式
			if (SingletonValue.getInstance().testMode) {
				nowChNum = 4;
				count_mc.gotoAndPlay(76);
			}
			
			initData();
			nowCh = allCh[nowChNum];
			this.gotoAndStop(nowCh);
			
			//設定黃金跟可樂球初始位置
			initGoldAndUser();
			
			map_mc.visible = false;
			map_mc.gotoAndStop(nowCh);
			mapBD = new BitmapData(map_mc.width, map_mc.height, true, 0);
			mapBD.draw(map_mc);
			
			user_mc.visible = false;
			userBD = new BitmapData(user_mc.width, user_mc.height, true, 0);
			userBD.draw(user_mc);
			
			ex_mc.stop();
			ex_mc.visible = false;
			ex_mc.addEventListener("ex", finishEx);
			ch_mc.gotoAndStop(nowCh);
			count_mc.addEventListener("count", startGame);	//倒數動畫結束後開始遊戲
			
		}
		
		//設定黃金跟可樂球初始位置
		private function initGoldAndUser():void 
		{
			var _n:uint = numChildren;
			var _cn:uint = 0;
			for (var i:uint = 0; i < _n; i++) {	
				if (getChildAt(i).name.substr(0, 4) == "gold") {
					getChildAt(i).x = allGold[nowChNum][_cn][0];
					getChildAt(i).y = allGold[nowChNum][_cn][1];
					MovieClip(getChildAt(i))._mc.gotoAndStop(1);
					_cn++;
				}
			}
			
			u_mc.x = user_mc.x = allUser[nowChNum][0];
			u_mc.y = user_mc.y = allUser[nowChNum][1];
		}
		
		private function reStart(e:MouseEvent):void 
		{
			ex_mc.gotoAndStop(1);
			EnterGame();
			startGame(null);
		}
		
		private function goEx(e:MouseEvent):void 
		{
			Pause(null);
			ex_mc.gotoAndStop(1);
			ex_mc.visible = true;
			ex_mc.gotoAndPlay(nowCh);
		}
		
		private function finishEx(e:Event):void 
		{
			UnPause(null);
			ex_mc.gotoAndStop(1);
		}
		
		private function startGame(e:Event):void 
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
			restart_btn.addEventListener(MouseEvent.CLICK, reStart);
			ex_btn.addEventListener(MouseEvent.CLICK, goEx);
		}
		
		//控制人物走動===============================================================
		private function fl_SetKeyPressed(event:KeyboardEvent):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			switch (event.keyCode)
			{
				case Keyboard.UP: 
				{
					upPressed = true;
					u_mc.rotation = 180;
					//紀錄可樂球方向
					directionTxt = "u";
					if (!mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(user_mc.x, user_mc.y - userSpeed), 255)) {
						user_mc.y -= userSpeed;
					}
					break;
				}
				case Keyboard.DOWN: 
				{
					downPressed = true;
					u_mc.rotation = 0;
					//紀錄可樂球方向
					directionTxt = "d";
					if (!mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(user_mc.x, user_mc.y + userSpeed), 255)) {
						user_mc.y += userSpeed;
					}
					break;
				}
				case Keyboard.LEFT: 
				{
					leftPressed = true;
					u_mc.rotation = 90;
					//紀錄可樂球方向
					directionTxt = "l";
					if (!mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(user_mc.x - userSpeed, user_mc.y), 255)) {
						user_mc.x -= userSpeed;
					}
					break;
				}
				case Keyboard.RIGHT: 
				{
					rightPressed = true;
					u_mc.rotation = 270;
					//紀錄可樂球方向
					directionTxt = "r";
					if (!mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(user_mc.x + userSpeed, user_mc.y), 255)) {
						user_mc.x += userSpeed;
					}
					break;
				}
			}
			
			//判斷可樂球碰到哪個黃金
			var _n:uint = allStar[nowChNum].length;
			for (var j:uint = 1; j <= _n; j++) { //trace(j, "this[\"gold\" + j + \"_mc\"] : " + this["gold" + j + "_mc"] );
				if (this["gold" + j + "_mc"].hitTestPoint(user_mc.x, user_mc.y, true)) {
					pushGold("gold" + j + "_mc");
				}
			}
			
			//可樂球移動並撥放推動畫
			u_mc.x = user_mc.x;
			u_mc.y = user_mc.y;
			u_mc.gotoAndStop(3);
			chk1.play();	//移動音效
			
			//檢查是否過關
			checkGlod();
		}
		
		//移動黃金或是將可樂球回復原地
		private function pushGold(string:String):void 
		{	
			if (directionTxt == "u") {	//根據directionTxt的值來判斷黃金的移動方向
				//如果黃金將會超出可移動範圍 或 被其他黃金阻擋,就將可樂球回復原位,並且return
				//trace(this[string].hitTestObject(this[string]),gold3_mc == this[string]);
				if (mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(this[string].x, this[string].y - userSpeed), 255) || checkPushGold(this[string])) {
					user_mc.y += userSpeed;
					return;
				} 
				this[string].y -= userSpeed;
			}else if (directionTxt == "d") {
				if (mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(this[string].x, this[string].y + userSpeed), 255) || checkPushGold(this[string])) {
					user_mc.y -= userSpeed;
					return;
				}
				this[string].y += userSpeed;
			}else if (directionTxt == "l") {
				if (mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(this[string].x - userSpeed, this[string].y), 255) || checkPushGold(this[string])) {
					user_mc.x += userSpeed;
					return;
				}
				this[string].x -= userSpeed;
			}else if (directionTxt == "r") {
				if (mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(this[string].x + userSpeed, this[string].y), 255) || checkPushGold(this[string])) {
					user_mc.x -= userSpeed;
					return;
				}
				this[string].x += userSpeed;
			}
			chk2.play();	//移動金塊音效
		}
		
		//判斷黃金是否被黃金阻擋
		private function checkPushGold(mc:MovieClip):Boolean 
		{
			var _n:uint = allGold[nowChNum].length;
			var i:uint = 1;
			if (directionTxt == "u") {
				for ( ; i <= _n; i++) {	
					if (this["gold" + i + "_mc"] != mc) { 	
						if (this["gold" + i + "_mc"].hitTestPoint(mc.x, mc.y - userSpeed, true)) {
							return true;
						}
					}
				}
			}else if (directionTxt == "d") {
				for ( ; i <= _n; i++) {	
					if (this["gold" + i + "_mc"] != mc) { 	
						if (this["gold" + i + "_mc"].hitTestPoint(mc.x, mc.y + userSpeed, true)) {
							return true;
						}
					}
				}
			}else if (directionTxt == "l") {
				for ( ; i <= _n; i++) {		
					if (this["gold" + i + "_mc"] != mc) { 
						if (this["gold" + i + "_mc"].hitTestPoint(mc.x - userSpeed, mc.y, true)) {
							return true;
						}
					}
				}
			}else if (directionTxt == "r") {
				for ( ; i <= _n; i++) {	
					if (this["gold" + i + "_mc"] != mc) { 	
						if (this["gold" + i + "_mc"].hitTestPoint(mc.x + userSpeed, mc.y, true)) {
							return true;
						}
					}
				}
			}
			return false;
		}
		
		private function fl_UnsetKeyPressed(event:KeyboardEvent):void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
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
					break;
				}
				case Keyboard.LEFT: 
				{
					leftPressed = false;
					break;
				}
				case Keyboard.RIGHT: 
				{
					rightPressed = false;
					break;
				}
			}
			u_mc.gotoAndStop(1);
		}
		//===============================================================控制人物走動
		
		//檢查是否過關
		private function checkGlod():void 
		{
			var _n:uint = allStar[nowChNum].length;
			var _b:Boolean = true;
			var b:Boolean = true;
			for (var j:uint = 1; j <= _n; j++) {
				for (var i:uint = 1; i <= _n; i++) {
					if (this["gold" + j + "_mc"].hitTestPoint(this["star" + i + "_mc"].x, this["star" + i + "_mc"].y, false)) {
						//只要有true就跳出這個for
						this["gold" + j + "_mc"]._mc.gotoAndStop(2);  //黃金閃閃
						_b = true;
						break;
					}
					this["gold" + j + "_mc"]._mc.gotoAndStop(1);  //黃金不閃
					_b = false;
				}
				if (!_b) b = _b;
			}
			//如果有任一個黃金沒碰到星星,跳出這個function
			if (!b) {
				return;
			}
			//過關
			Pause(null);
			u_mc.gotoAndStop(2);
			var winTime:Timer = new Timer(1000, 3);		//倒數三秒後下一關
			winTime.addEventListener(TimerEvent.TIMER_COMPLETE, goNext);
			winTime.start();
		}
		
		private function goNext(e:TimerEvent):void 
		{
			u_mc.gotoAndStop(1);
			nextCh();
		}
		
		//下一關
		private function nextCh():void 
		{
			if (nowChNum < allCh.length-1) {
				nowChNum ++;
				EnterGame();
				startGame(null);
			}else {
				trace("破關!!");
				Pause(null);
				this.gotoAndPlay("f");
			}
		}
		
		//暫停
		override public function Pause(e:MainEvent):void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
		}
		
		//結束暫停
		override public function UnPause(e:MainEvent):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
		}		
	}
}