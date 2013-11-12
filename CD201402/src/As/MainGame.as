package As
{
	import As.Events.BadguyEvent;
	import As.Events.MainEvent;
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class MainGame extends GM
	{
		private var userSpeed:Number = 5;	//人物行走速度
		//private var userHp:uint = SingletonValue.getInstance().hp;	//人物HP
		private var userInvincible:Boolean = false;	//人物無敵狀態
		//上下左右開關
		private var upPressed:Boolean = false;
		private var downPressed:Boolean = false;
		private var leftPressed:Boolean = false;
		private var rightPressed:Boolean = false;
		private var tempPressed:Boolean;
		private var directionTxt:String = "r";
		private var modeTxt:String = "";	//空:走路 a:攻擊 b:被照相 c:被攻擊
		
		//private var mapClipBmpData:BitmapData;	//已使用場景上的map_mc.mapClipBmpData取代
		private var userClipBmpData:BitmapData;
		
		public function MainGame()
		{
		}
		
		//進入遊戲
		override public function EnterGame():void
		{
			//bullet_mc.visible = map_mc.visible = false;
			//ChangeSide_btn.addEventListener(MouseEvent.CLICK, goChangeSide);
			
			//人物走動用
			stage.stageFocusRect = false;
			stage.focus = stage;
			user_mc.addEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
			
			//碰撞用
			userClipBmpData = new BitmapData(user_mc.width, user_mc.height, true, 0);
			userClipBmpData.draw(user_mc);
			/*mapClipBmpData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			mapClipBmpData.draw(map_mc);*/
			
			//初始化壞人及記者
			badGuyInit();
			
			trampTxt_mc.visible = false;	//街童對話框
			cantPass_mc.visible = false;	//這裡還不能進入
			map_mc.visible = false;			//碰撞偵測用紅地圖
		}
		
		//初始化壞人,記者,街童(已擺放在場景上)
		private function badGuyInit():void 
		{ 
			var _i:uint = NPC_mc.numChildren;
			for (var i:uint ; i < _i; i++) { //trace(getQualifiedClassName(this.getChildAt(i)),getQualifiedClassName(this.getChildAt(i)) == "As::Badguy",getQualifiedClassName(this.getChildAt(i)) == "As::Reporter",getQualifiedClassName(this.getChildAt(i)) == "As::Tramp");
				var _mc:MovieClip = NPC_mc.getChildAt(i) as MovieClip;
				//壞人
				if (getQualifiedClassName(_mc) == "As::Badguy") {
					_mc.startInit(map_mc.mapClipBmpData, userClipBmpData, user_mc, bullet_mc);
					_mc.addEventListener(BadguyEvent.ATTACK, injure);
					_mc.addEventListener(BadguyEvent.INJURE, hit);
				}else if (getQualifiedClassName(_mc) == "As::Reporter") { //記者
					_mc.startInit(map_mc.mapClipBmpData, userClipBmpData, user_mc, bullet_mc);
					_mc.addEventListener(BadguyEvent.CATCH, catching);
				}else if (getQualifiedClassName(_mc) == "As::Tramp") { //街童
					_mc.startInit(map_mc.mapClipBmpData, userClipBmpData, user_mc, bullet_mc);
					_mc.addEventListener(BadguyEvent.TOUCH, information);
				}
			}
		}
		
		//子彈命中敵人
		private function hit(e:BadguyEvent):void 
		{
			bulletMove( -20, -20);
		}
		
		//遇到街童
		private function information(e:BadguyEvent):void 
		{
			trace("顯示街童對話");
		}
		
		//被纏上==鎖住鍵盤無法移動==扣血及暫時無敵
		private function catching(e:BadguyEvent):void 
		{
			if (!userInvincible) {
				modeTxt = "b";
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
				stage.removeEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
				upPressed = downPressed = rightPressed = leftPressed = false;
				userInvincible = true;
				user_mc.alpha = 0.2;
				//第一次Tweener鎖住鍵盤3秒,第二次Tweener維持無敵2秒後復原
				Tweener.addTween(user_mc, { time:3, onComplete:function() {
					stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
					stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
					modeTxt = "";
					Tweener.addTween(user_mc, { alpha:1, time:2, transition:"easeInBounce", onComplete:function() {
							userInvincible = false;
							}} );
					}} );
				changeHP( -10); 
				trace("被記者纏上了!!!", "HP:", SingletonValue.getInstance().hp);
			}
		}
		
		//血量變化
		private function changeHP(_hp:int):void 
		{
			if (SingletonValue.getInstance().hp + _hp <= 0) {
				SingletonValue.getInstance().hp = 0;
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "221B.swf"));
			}else {
				SingletonValue.getInstance().hp += _hp;
			}
		}
		
		//遭受攻擊==扣血及暫時無敵
		private function injure(e:BadguyEvent):void 
		{
			if (!userInvincible) {
				modeTxt = "c";
				userInvincible = true;
				user_mc.alpha = 0.2;
				Tweener.addTween(user_mc, { alpha:1, time:2, transition:"easeInBounce", onComplete:function() {
					userInvincible = false;
					}} );
				changeHP( -5);
				trace("HP:",SingletonValue.getInstance().hp);
			}	
		}
		
		//換場景
		private function goChangeSide(e:MouseEvent):void
		{
			this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "alley.swf"));
		}
		
		//用碰撞判斷可走區域===子彈位置
		private function fl_MoveInDirectionOfKey(event:Event)
		{ 
			if (upPressed && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x, user_mc.y - userSpeed), 255
				
				))
			{
				if (map_mc.y >= 0 || user_mc.y >= 370) { //判斷地圖移動或人物移動(map_mc已到底或user_mc未到中間)
					cola_mc.y = user_mc.y -= userSpeed;
				}else {
					mpa_art_mc.y = map_mc.y = NPC_mc.y += userSpeed;
				}
				directionTxt = "u";
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				MovieClip(cola_mc.getChildAt(1)).play();
			}else if (downPressed && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x, user_mc.y + userSpeed), 255
				
				))
			{
				if (map_mc.y <= -768 || user_mc.y <= 370) {	//判斷地圖移動或人物移動(map_mc已到底或user_mc未到中間)
					cola_mc.y = user_mc.y += userSpeed;
				}else {
					mpa_art_mc.y = map_mc.y = NPC_mc.y -= userSpeed;
				}
				directionTxt = "d";
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				MovieClip(cola_mc.getChildAt(1)).play();
			}else if (leftPressed && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x - userSpeed, user_mc.y), 255
				
				))
			{
				if (map_mc.x >= 0 || user_mc.x >= 500) { //判斷地圖移動或人物移動(map_mc已到底或user_mc未到中間)
					cola_mc.x = user_mc.x -= userSpeed;
				}else {
					mpa_art_mc.x = map_mc.x = NPC_mc.x += userSpeed;
				}
				directionTxt = "l";
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				MovieClip(cola_mc.getChildAt(1)).play();
			}else if (rightPressed && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x + userSpeed, user_mc.y), 255
				
				))
			{
				if (map_mc.x <= -1024 || user_mc.x <= 500) { //判斷地圖移動或人物移動(map_mc已到底或user_mc未到中間)
					cola_mc.x = user_mc.x += userSpeed;
				}else {
					mpa_art_mc.x = map_mc.x = NPC_mc.x -= userSpeed;
				}
				directionTxt = "r";
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				MovieClip(cola_mc.getChildAt(1)).play();
			}else {	//都不符合表示沒有在走路,停止走路動畫
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				if (modeTxt == "") {	//如果是走路狀態才停止,攻擊等其他動畫就繼續
					MovieClip(cola_mc.getChildAt(1)).gotoAndStop(1);
				}
			}
		}
		
		//攻擊!!!!!
		private function attack():void
		{
			//用子彈位置判斷是否在使用中
			if (bullet_mc.x == -20 && bullet_mc.y == -20) {
				bulletMove(user_mc.x + user_mc.width / 2, user_mc.y + user_mc.height / 2);
				if (directionTxt == "u") { 
					Tweener.addTween(bullet_mc, { y:bullet_mc.y - 90, time:.3, transition:"easeOutCirc", onComplete:function() {
						bulletMove( -20, -20);
						if(modeTxt == "a") modeTxt = "";
						tempPressed = true;
						}});
				}else if (directionTxt == "d") {
					Tweener.addTween(bullet_mc, { y:bullet_mc.y + 90, time:.3, transition:"easeOutCirc", onComplete:function() {
						bulletMove( -20, -20);
						if(modeTxt == "a") modeTxt = "";
						tempPressed = true;
						}}	);
				}else if (directionTxt == "l") {
					Tweener.addTween(bullet_mc, { x:bullet_mc.x - 90, time:.3, transition:"easeOutCirc", onComplete:function() {
						bulletMove( -20, -20);
						if(modeTxt == "a") modeTxt = "";
						tempPressed = true; trace(tempPressed,leftPressed,rightPressed,upPressed,downPressed);
						}}	);
				}else if (directionTxt == "r") {
					Tweener.addTween(bullet_mc, { x:bullet_mc.x + 90, time:.3, transition:"easeOutCirc", onComplete:function() {
						bulletMove( -20, -20);
						if (modeTxt == "a") modeTxt = "";
						tempPressed = true;
						}}	);
				}
			}
		}
		
		//移動子彈位置
		public function bulletMove(_x:Number, _y:Number):void { 
			bullet_mc.x = _x;
			bullet_mc.y = _y;	
		}
		
		//控制人物走動===============================================================
		private function fl_SetKeyPressed(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP: 
				{
					upPressed = true;
					tempPressed = upPressed;
					//紀錄可樂球方向
					modeTxt = "";
					break;
				}
				case Keyboard.DOWN: 
				{
					downPressed = true;
					tempPressed = downPressed;
					modeTxt = "";
					break;
				}
				case Keyboard.LEFT: 
				{
					leftPressed = true;
					tempPressed = leftPressed;
					modeTxt = "";
					break;
				}
				case Keyboard.RIGHT: 
				{
					rightPressed = true;
					tempPressed = rightPressed;
					modeTxt = "";
					break;
				}
				case Keyboard.SPACE: 
				{
					upPressed = downPressed = rightPressed = leftPressed = false;
					attack();
					modeTxt = "a";
					break;
				}
			}
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
		}
		//===============================================================控制人物走動
		
		//暫停
		override public function Pause(e:MainEvent):void {
			trace("stage喊暫停!!");
			user_mc.removeEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			this.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			this.removeEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
		}
		
		//結束暫停
		override public function UnPause(e:MainEvent):void {
			user_mc.addEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			this.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			this.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
		}
		
		//移除
		override public function kill(e:Event):void
		{ 
			super.kill(e);
			Tweener.pauseAllTweens();
			Tweener.removeAllTweens();  //trace("MainGame kill", Tweener.removeAllTweens(), Tweener.pauseAllTweens());
			//ChangeSide_btn.removeEventListener(MouseEvent.CLICK, goChangeSide);
			user_mc.removeEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			this.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			this.removeEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
			userClipBmpData.dispose();
			map_mc.mapClipBmpData.dispose();
		}
	
	}

}