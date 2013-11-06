package As 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
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
		
		private var userSpeed:uint = 67;
		
		private var nowCh:String = "a";
		private var nowChNum:uint = 0;
		private var allGold:Array = new Array();
		
		public function G02() 
		{
			allGold = [
						[[368.4, 355.4], [368.85, 288.5], [434.95, 422.5], [502.05, 288.3]],
						[[], []],
						[[], [], []],
						[[], [], [], []],
						[[], [], [], [], [], []]
						]
		}
		
		//進入遊戲
		override public function EnterGame():void
		{
			this.stop();
			
			map_mc.visible = false;
			mapBD = new BitmapData(map_mc.width, map_mc.height, true, 0);
			mapBD.draw(map_mc);
			
			user_mc.visible = false;
			userBD = new BitmapData(user_mc.width, user_mc.height, true, 0);
			userBD.draw(user_mc);
			
			ex_mc.stop();
			ex_mc.visible = false;
			ex_mc.addEventListener("ex", finishEx);
			ch_mc.gotoAndStop(nowCh);
			count_mc.addEventListener("count", startGame);
			
			restart_btn.addEventListener(MouseEvent.CLICK, reStart);
			ex_btn.addEventListener(MouseEvent.CLICK, goEx);
		}
		
		private function reStart(e:MouseEvent):void 
		{
			
		}
		
		private function goEx(e:MouseEvent):void 
		{
			ex_mc.visible = true;
			ex_mc.gotoAndPlay(nowCh);
		}
		
		private function finishEx(e:Event):void 
		{
			ex_mc.gotoAndStop(1);
		}
		
		private function startGame(e:Event):void 
		{
			//user_mc.addEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
		}
		
		//
		private function fl_MoveInDirectionOfKey(event:Event)
		{ 
			
		}
		
		//控制人物走動===============================================================
		private function fl_SetKeyPressed(event:KeyboardEvent):void
		{
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
			if (gold1_mc.hitTestPoint(user_mc.x,user_mc.y,true)) { 
				pushGold("gold1_mc");
			}else if (gold2_mc.hitTestPoint(user_mc.x,user_mc.y,true)) {
				pushGold("gold2_mc");
			}else if (gold3_mc.hitTestPoint(user_mc.x,user_mc.y,true)) {
				pushGold("gold3_mc");
			}else if (gold4_mc.hitTestPoint(user_mc.x,user_mc.y,true)) {
				pushGold("gold4_mc");
			}
			
			//可樂球移動並撥放推動畫
			u_mc.x = user_mc.x;
			u_mc.y = user_mc.y;
			u_mc.gotoAndStop(2);
		}
		
		//移動黃金或是將可樂球回復原地
		private function pushGold(string:String):void 
		{	
			if (directionTxt == "u") {	//根據directionTxt的質來判斷黃金的移動方向
				//如果黃金將會超出可移動範圍,就將可樂球回復原位,並且return
				if (mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(this[string].x, this[string].y - userSpeed), 255)) {
					user_mc.y += userSpeed;
					return;
				}
				//移動黃金
				this[string].y -= userSpeed;
			}else if (directionTxt == "d") {
				if (mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(this[string].x, this[string].y + userSpeed), 255)) {
					user_mc.y -= userSpeed;
					return;
				}
				this[string].y += userSpeed;
			}else if (directionTxt == "l") {
				if (mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(this[string].x - userSpeed, this[string].y), 255)) {
					user_mc.x += userSpeed;
					return;
				}
				this[string].x -= userSpeed;
			}else if (directionTxt == "r") {
				if (mapBD.hitTest(new Point(map_mc.x, map_mc.y), 255, userBD, new Point(this[string].x + userSpeed, this[string].y), 255)) {
					user_mc.x -= userSpeed;
					return;
				}
				this[string].x += userSpeed;
			}
			checkGlod();
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
		
		private function checkGlod():void 
		{
			var _n:uint = allGold[nowChNum].length;
			for (var j:uint = 1; j <= _n; j++) {
				for (var i:uint = 1; i <= _n; i++) {
					trace(this["gold" + j + "_mc"].hitTestPoint(this["star" + i + "_mc"].x, this["star" + i + "_mc"].y, true));
				}
				trace("----------");
			}
			trace("==========");
		}
		
	}

}