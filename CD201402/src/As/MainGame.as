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
	import flash.media.Sound;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class MainGame extends GM
	{
		private var userSpeed:Number = 10;	//人物行走速度
		//private var userHp:uint = SingletonValue.getInstance().hp;	//人物HP
		private var userInvincible:Boolean = false;	//人物無敵狀態
		//上下左右開關
		private var upPressed:Boolean = false;
		private var downPressed:Boolean = false;
		private var leftPressed:Boolean = false;
		private var rightPressed:Boolean = false;
		private var directionTxt:String = "r";
		private var modeTxt:String = "";	//空:走路 a:攻擊 b:被照相 c:被攻擊
		
		//private var mapClipBmpData:BitmapData;	//已使用場景上的map_mc.mapClipBmpData取代
		private var userClipBmpData:BitmapData;
		private var cola_mc:MovieClip;
		private var attackZone:uint = 200;		//子彈攻擊距離
		private var bullet_mc:MovieClip;
		
		private var tempShelter:Array = new Array();
		private var tempTramp:MovieClip;
		private var trampSoundAmount:uint; //目前案件的街童語音數量
		private var trampSoundArray:Array; //街童語音當次需要播放的檔案跟影格
		private var trampSoundBoy:Array = [[[sound_g1_b1, 2], [sound_g1_b2, 3], [sound_g1_b3, 4]], 
										   [[sound_g2_b1, 8, sound_g2_c1, 9], [sound_g2_b2, 10, sound_g2_c2, 11], [sound_g2_b3, 12, sound_g2_c3, 13]],
										   [[sound_g3_b1, 20], [sound_g3_b2, 21], [sound_g3_b3, 22]],
										   [[sound_g4_b1, 25], [sound_g4_b2, 27]]];
										   
		private var trampSoundGirl:Array = [[[sound_g1_g1, 5], [sound_g1_g2, 6], [sound_g1_g3, 7]], 
											[[sound_g2_g1, 14, sound_g2_c4, 15], [sound_g2_g2, 16, sound_g2_c5, 17], [sound_g2_g3, 18, sound_g2_c6, 19]],
											[[sound_g3_g1, 23], [sound_g3_g2, 24]],
											[[sound_g4_g1, 26]]];
		
		private var sb1:Sound = new sound_bad1();
		private var sb2:Sound = new sound_bad2();
		//private var sc1:Sound = new sound_cola1();
		private var sc2:Sound = new sound_cola2();
		
		public function MainGame()
		{
		}
		
		//進入遊戲
		override public function EnterGame():void
		{
			//ChangeSide_btn.addEventListener(MouseEvent.CLICK, goChangeSide);
			//測試模式
			if (SingletonValue.getInstance().testMode) {
				//userInvincible = true;
			}
			
			HP_mc.gotoAndStop(SingletonValue.getInstance().hp);
			//人物走動用
			stage.stageFocusRect = false;
			stage.focus = stage;
			user_mc.addEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
			cola_mc = NPC_mc.cola_mc;
			cola_mc.a_mc.visible = false;
			
			//碰撞用
			userClipBmpData = new BitmapData(user_mc.width, user_mc.height, true, 0);
			userClipBmpData.draw(user_mc);
			/*mapClipBmpData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			mapClipBmpData.draw(map_mc);*/
			bullet_mc = NPC_mc.bullet_mc;
			
			//初始化壞人及記者
			badGuyInit();
			
			//bullet_mc.visible = false;	//子彈
			trampTxt_mc.visible = false;	//街童對話框
			trampTxt_mc.ok_btn.addEventListener(MouseEvent.CLICK, closeTrampTxt);
			cantPass_mc.visible = false;	//這裡還不能進入
			cantPass_mc.ok_btn.addEventListener(MouseEvent.CLICK, closeCantPass);
			enter_mc.visible = false;		//建築物入口偵測區
			map_mc.visible = false;		//碰撞偵測用紅地圖
			user_mc.visible = false;		//可樂球碰撞偵測用藍色小塊
			
			if (SingletonValue.getInstance().unitNum == 4 && SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) { //過關
				playSound("TSC", sound_go221);
			}
			//從建築物出來後設定在門口位置
			if (SingletonValue.getInstance().beforeSiteName == "G" || SingletonValue.getInstance().beforeSiteName == "Q") {
				if (SingletonValue.getInstance().caseNum == 0) { //博物館
					enter_mc.x = mpa_art_mc.x = map_mc.x = NPC_mc.x = -40;
					enter_mc.y = mpa_art_mc.y = map_mc.y = NPC_mc.y = -770;
					user_mc.x = 500;
					user_mc.y = 646;
					cola_mc.x = 540;
					cola_mc.y = 1416;
				} else if (SingletonValue.getInstance().caseNum == 1) { //銀行
					enter_mc.x = mpa_art_mc.x = map_mc.x = NPC_mc.x = -1020;
					enter_mc.y = mpa_art_mc.y = map_mc.y = NPC_mc.y = -770;
					user_mc.x = 590;
					user_mc.y = 686;
					cola_mc.x = 1610;
					cola_mc.y = 1456;
				} else if (SingletonValue.getInstance().caseNum == 2) { //暗巷
					enter_mc.x = mpa_art_mc.x = map_mc.x = NPC_mc.x = -1020;
					enter_mc.y = mpa_art_mc.y = map_mc.y = NPC_mc.y = 0;
					user_mc.x = 720;
					user_mc.y = 376;
					cola_mc.x = 1740;
					cola_mc.y = 376;
				} else if (SingletonValue.getInstance().caseNum == 3) { //鐘樓
					enter_mc.x = mpa_art_mc.x = map_mc.x = NPC_mc.x = -630;
					enter_mc.y = mpa_art_mc.y = map_mc.y = NPC_mc.y = -540;
					user_mc.x = 510;
					user_mc.y = 376;
					cola_mc.x = 1140;
					cola_mc.y = 916;
				}
			}
			//右上角提示狀態
			if (SingletonValue.getInstance().caseNum == 0) { //博物館
				side_mc.gotoAndStop(1);
			} else if (SingletonValue.getInstance().caseNum == 1) { //銀行
				side_mc.gotoAndStop(2);
			} else if (SingletonValue.getInstance().caseNum == 2) { //暗巷
				side_mc.gotoAndStop(3);
			} else if (SingletonValue.getInstance().caseNum == 3) { //鐘樓
				side_mc.gotoAndStop(4);
			}
			//若是破關狀態就顯示221B
			if (SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) { //221B
				side_mc.gotoAndStop(5);
			}
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
				}else if (getQualifiedClassName(_mc) == "tramp") { //街童
					_mc.startInit(map_mc.mapClipBmpData, userClipBmpData, user_mc, bullet_mc);
					_mc.addEventListener(BadguyEvent.TOUCH, information);
				}else if (getQualifiedClassName(_mc) == "tramp_boy") { //街童男
					_mc.startInit(map_mc.mapClipBmpData, userClipBmpData, user_mc, bullet_mc);
					_mc.addEventListener(BadguyEvent.TOUCH, information);
				}else if (_mc.name.substr(0, 7) == "shelter") { //遮蔽物
					_mc.startInit(user_mc);
					_mc.addEventListener(BadguyEvent.COVER, goCover);
					//_mc.addEventListener(BadguyEvent.UNCOVER, unCover);
				}
			}
		}
		
		//取消可樂球躲藏
		private function unCover():void 
		{	
			user_mc.alpha = 1;
			cola_mc.visible = true;
			user_mc.addEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, goUnCover);
		}
		
		//可樂球躲藏
		private function goCover(e:BadguyEvent):void 
		{	
			user_mc.alpha = 0;
			cola_mc.visible = false;
			user_mc.x = e.currentTarget.x + NPC_mc.x;
			user_mc.y = e.currentTarget.y + NPC_mc.y;
			cola_mc.x = e.currentTarget.x;
			cola_mc.y = e.currentTarget.y;
			//e.currentTarget.addEventListener(BadguyEvent.UNCOVER, unCover);
			tempShelter = [e.currentTarget.x, e.currentTarget.y, e.currentTarget.width, e.currentTarget.height];
			user_mc.removeEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, goUnCover);
		}
		
		//判斷跳出遮蔽物後可否通行,可以的話才跳出
		private function goUnCover(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.UP && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x, user_mc.y - user_mc.height), 255
				
				))
			{	
				user_mc.x -= user_mc.width / 2;
				user_mc.y = user_mc.y - user_mc.height - 23;
				cola_mc.x -= user_mc.width / 2;
				cola_mc.y = cola_mc.y - user_mc.height;
				unCover();
			}else if (e.keyCode == Keyboard.DOWN && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x, user_mc.y + tempShelter[3] / 2), 255
				
				))
			{
				user_mc.x -= user_mc.width / 2;
				user_mc.y = user_mc.y + tempShelter[3] / 2;
				cola_mc.x -= user_mc.width / 2;
				cola_mc.y = cola_mc.y + tempShelter[3] / 2;
				unCover();
			}else if (e.keyCode == Keyboard.LEFT && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x - tempShelter[2]/2 - user_mc.width, user_mc.y), 255
				
				))
			{	
				user_mc.x = user_mc.x - tempShelter[2] / 2 - user_mc.width;
				user_mc.y += user_mc.height;
				cola_mc.x = cola_mc.x - tempShelter[2] / 2 - user_mc.width;
				cola_mc.y += user_mc.height;
				unCover();
			}else if (e.keyCode == Keyboard.RIGHT && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x + tempShelter[2]/2, user_mc.y), 255
				
				))
			{	
				user_mc.x += tempShelter[2]/2;
				user_mc.y += user_mc.height;
				cola_mc.x += tempShelter[2]/2;
				cola_mc.y += user_mc.height;
				unCover();
			}
		}
		
		//子彈命中敵人
		private function hit(e:BadguyEvent):void 
		{
			bulletMove( -20, 1700);
		}
		
		//遇到街童
		private function information(e:BadguyEvent):void 
		{
			if (tempTramp && !tempTramp.hasEventListener(BadguyEvent.TOUCH) ||
			SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) {  
				//若上一個碰到的街童還沒恢復偵聽或目前關卡已破關就先跳過
				return;
			}
			this.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
			this.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_HIDE, true));
			tempTramp = e.currentTarget as MovieClip;
			tempTramp.removeEventListener(BadguyEvent.TOUCH, information);
			trampTxt_mc.Tramp_mc.visible = false;
			trampTxt_mc.cola_mc.visible = false;
			if (getQualifiedClassName(tempTramp) == "tramp") { //街童
				//亂數選取語音
				trampSoundAmount = Math.random() * trampSoundGirl[SingletonValue.getInstance().caseNum].length;
				//複製亂數選取的街童語音陣列,trampSoundPlay負責撥放
				//trampSoundArray = trampSoundGirl[SingletonValue.getInstance().caseNum][trampSoundAmount].concat();
				//依街童的名字固定播放語音
				if (uint(tempTramp.name.substr(1, 1)) > trampSoundGirl[SingletonValue.getInstance().caseNum].length - 1) {
					//若街童數量(3)比語音數量多就播第一個
					trampSoundArray = trampSoundGirl[SingletonValue.getInstance().caseNum][0].concat();
				}else {
					trampSoundArray = trampSoundGirl[SingletonValue.getInstance().caseNum][tempTramp.name.substr(1,1)].concat();
				}
				trampSoundPlay("g");
			}else if (getQualifiedClassName(tempTramp) == "tramp_boy") { //街童男
				trampSoundAmount = Math.random() * trampSoundBoy[SingletonValue.getInstance().caseNum].length;
				//trampSoundArray = trampSoundBoy[SingletonValue.getInstance().caseNum][trampSoundAmount].concat();
				if (uint(tempTramp.name.substr(1, 1)) > trampSoundBoy[SingletonValue.getInstance().caseNum].length - 1) {
					//若街童數量(3)比語音數量多就播第一個
					trampSoundArray = trampSoundBoy[SingletonValue.getInstance().caseNum][0].concat();
				}else {
					trampSoundArray = trampSoundBoy[SingletonValue.getInstance().caseNum][tempTramp.name.substr(1, 1)].concat();
				}
				trampSoundPlay("b");
			}
			trampTxt_mc.visible = true;
		}
		//播放語音,根據碰到的街童性別顯示相對應的動畫
		private function trampSoundPlay(_s:String = null):void {
			playSound("TSC", trampSoundArray.shift());
			trampTxt_mc.gotoAndStop(trampSoundArray.shift());
			if (_s == "b") { //男性街童
				trampTxt_mc.Tramp_mc.gotoAndStop("TrampBoy");
				MovieClip(trampTxt_mc.Tramp_mc.getChildAt(0)).play();
				trampTxt_mc.Tramp_mc.visible = true;
			}else if (_s == "g") { //女性街童
				trampTxt_mc.Tramp_mc.gotoAndStop("Tramp");
				MovieClip(trampTxt_mc.Tramp_mc.getChildAt(0)).play();
				trampTxt_mc.Tramp_mc.visible = true;
			}else {  //顯示可樂球
				trampTxt_mc.cola_mc.gotoAndStop(1);
				trampTxt_mc.cola_mc.visible = true;
			}
		}
		//街童語音播完後,判斷可樂球是否需要回答
		override public function scComplete(e:Event = null):void 
		{	
			if (trampTxt_mc.visible) {
				e.currentTarget.removeEventListener(Event.SOUND_COMPLETE, scComplete);
				MovieClip(trampTxt_mc.Tramp_mc.getChildAt(0)).gotoAndStop(1);
				trampTxt_mc.cola_mc.gotoAndStop(2);
				if (trampSoundArray.length > 0) { //表示可樂球有回答
					trampTxt_mc.Tramp_mc.visible = false;
					trampSoundPlay();
				}
			}
		}
		
		//關閉街童對話框,兩秒後恢復偵聽
		private function closeTrampTxt(e:MouseEvent):void 
		{
			stopSound("TSC");
			this.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			this.dispatchEvent(new MainEvent(MainEvent.TOOL_BAR_SHOW, true));
			trampTxt_mc.visible = false;
			trampTxt_mc.gotoAndStop(1);
			Tweener.addTween(this, { time:2, onComplete:function() {
				tempTramp.addEventListener(BadguyEvent.TOUCH, information);
			}} );
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
				sb2.play();
				cola_mc.lower5_mc.play(); //-5動畫
				//user_mc.alpha = 0.2;
				//第一次Tweener鎖住鍵盤3秒,第二次Tweener維持無敵2秒後復原
				Tweener.addTween(user_mc, { time:3, onComplete:function() {
					stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
					stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
					modeTxt = "";
					Tweener.addTween(user_mc, { /*alpha:1,*/ time:2, transition:"easeInBounce", onComplete:function() {
							userInvincible = false;
							}} );
					}} );
				changeHP( -5); 
				trace("被記者纏上了!!!", "HP:", SingletonValue.getInstance().hp);
			}
		}
		
		//血量變化
		private function changeHP(_hp:int):void 
		{
			if (SingletonValue.getInstance().hp + _hp <= 0) {
				SingletonValue.getInstance().hp = 0;
				this.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
				cantPass_mc.visible = true;
				cantPass_mc.gotoAndStop("nohp");
			}else {
				SingletonValue.getInstance().hp += _hp;
			}
			HP_mc.gotoAndStop(SingletonValue.getInstance().hp);
		}
		
		//遭受攻擊==扣血及暫時無敵
		private function injure(e:BadguyEvent):void 
		{
			if (!userInvincible) {
				modeTxt = "c";
				userInvincible = true;
				sb1.play(); //攻擊音效
				cola_mc.lower10_mc.play(); //-10動畫
				//user_mc.alpha = 0.2;
				Tweener.addTween(user_mc, { /*alpha:1,*/ time:2, transition:"easeInBounce", onComplete:function() {
					userInvincible = false;
					}} );
				changeHP( -10);
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
			if (modeTxt != "a" && upPressed && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x, user_mc.y - userSpeed), 255
				
				))
			{
				if (map_mc.y >= 0 || user_mc.y >= 370) { //判斷地圖移動或人物移動(map_mc已到底或user_mc未到中間)
					user_mc.y -= userSpeed;
				}else {
					enter_mc.y = mpa_art_mc.y = map_mc.y = NPC_mc.y += userSpeed;
				}
				cola_mc.y -= userSpeed;
				directionTxt = "u";
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				MovieClip(cola_mc.getChildAt(1)).play();
			}else if (modeTxt != "a" && downPressed && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x, user_mc.y + userSpeed), 255
				
				))
			{
				if (map_mc.y <= -768 || user_mc.y <= 370) {	//判斷地圖移動或人物移動(map_mc已到底或user_mc未到中間)
					user_mc.y += userSpeed;
				}else {
					enter_mc.y = mpa_art_mc.y = map_mc.y = NPC_mc.y -= userSpeed;
				}
				cola_mc.y += userSpeed;
				directionTxt = "d";
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				MovieClip(cola_mc.getChildAt(1)).play();
			}else if (modeTxt != "a" && leftPressed && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x - userSpeed, user_mc.y), 255
				
				))
			{
				if (map_mc.x >= 0 || user_mc.x >= 500) { //判斷地圖移動或人物移動(map_mc已到底或user_mc未到中間)
					user_mc.x -= userSpeed;
				}else {
					enter_mc.x = mpa_art_mc.x = map_mc.x = NPC_mc.x += userSpeed;
				}
				cola_mc.x -= userSpeed;
				directionTxt = "l";
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				MovieClip(cola_mc.getChildAt(1)).play();
			}else if (modeTxt != "a" && rightPressed && !map_mc.mapClipBmpData.hitTest(new Point(map_mc.x - 20, map_mc.y - 20), 255, userClipBmpData, new Point(user_mc.x + userSpeed, user_mc.y), 255
				
				))
			{
				if (map_mc.x <= -1014 || user_mc.x <= 500) { //判斷地圖移動或人物移動(map_mc已到底或user_mc未到中間)
					user_mc.x += userSpeed;
				}else {  
					enter_mc.x = mpa_art_mc.x = map_mc.x = NPC_mc.x -= userSpeed;
				}
				cola_mc.x += userSpeed;
				directionTxt = "r";
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				MovieClip(cola_mc.getChildAt(1)).play();
			}else {	//都不符合表示沒有在走路,停止走路動畫
				cola_mc.gotoAndStop(directionTxt + modeTxt);
				if (modeTxt == "") {	//如果是走路狀態才停止,攻擊等其他動畫就繼續
					MovieClip(cola_mc.getChildAt(1)).gotoAndStop(1);
				}
			}
			//判斷是否碰到可進入建築物的範圍(enter_mc)
			if (enter_mc.hitTestPoint(user_mc.x, user_mc.y, true)) {	
				//若目前案件已破關就不顯示進入箭頭
				if (enter_mc["enter_case" + SingletonValue.getInstance().caseNum + "_mc"].hitTestPoint(user_mc.x, user_mc.y, true) && 
				SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) return;
				cola_mc.a_mc.visible = true;
			}else {
				cola_mc.a_mc.visible = false;
			}
		}
		
		//攻擊!!!!!
		private function attack():void
		{
			//用子彈位置判斷是否在使用中
			if (bullet_mc.x == -20 && bullet_mc.y == 1700 && cola_mc.visible) {
				bulletMove(cola_mc.x + cola_mc.width / 4, cola_mc.y);
				sc2.play();
				if (directionTxt == "u") { 
					Tweener.addTween(bullet_mc, { y:bullet_mc.y - attackZone, time:.3, transition:"easeOutCirc", onComplete:function() {
						bulletMove( -20, 1700);
						if(modeTxt == "a") modeTxt = "";
						}});
				}else if (directionTxt == "d") {
					Tweener.addTween(bullet_mc, { y:bullet_mc.y + attackZone, time:.3, transition:"easeOutCirc", onComplete:function() {
						bulletMove( -20, 1700);
						if(modeTxt == "a") modeTxt = "";
						}}	);
				}else if (directionTxt == "l") {
					Tweener.addTween(bullet_mc, { x:bullet_mc.x - attackZone, time:.3, transition:"easeOutCirc", onComplete:function() {
						bulletMove( -20, 1700);
						if(modeTxt == "a") modeTxt = "";
						}}	);
				}else if (directionTxt == "r") {
					Tweener.addTween(bullet_mc, { x:bullet_mc.x + attackZone, time:.3, transition:"easeOutCirc", onComplete:function() {
						bulletMove( -20, 1700);
						if (modeTxt == "a") modeTxt = "";
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
					if (cola_mc.a_mc.visible) {
						checkPass();
						break;
					}
					upPressed = true;
					//紀錄可樂球方向
					modeTxt = "";
					break;
				}
				case Keyboard.DOWN: 
				{
					downPressed = true;
					modeTxt = "";
					break;
				}
				case Keyboard.LEFT: 
				{
					leftPressed = true;
					modeTxt = "";
					break;
				}
				case Keyboard.RIGHT: 
				{
					rightPressed = true;
					modeTxt = "";
					break;
				}
				case Keyboard.SPACE: 
				case 229:
				{	
					attack();
					modeTxt = "a";
					break;
				}
			}
		}
		
		//檢查要進入哪個場景及是否可以進入
		private function checkPass():void {
			
			if (enter_mc.enter_221b_mc.hitTestPoint(user_mc.x, user_mc.y, true)) {
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "221B.swf"));
			}else if (enter_mc["enter_case" + SingletonValue.getInstance().caseNum + "_mc"].hitTestPoint(user_mc.x, user_mc.y, true)) {
				//若碰到目前案件的進入點,就進入該案件
				//若是破關狀態就不能再進入
				if (SingletonValue.getInstance().caseArr[SingletonValue.getInstance().caseNum] == 3) return;
				//this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  SingletonValue.getInstance().allGameSwf[0][SingletonValue.getInstance().caseNum]));
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "INTO"));
			}else {
				this.dispatchEvent(new MainEvent(MainEvent.PAUSE, true));
				cantPass_mc.visible = true;
				cantPass_mc.gotoAndStop("cantpass");
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
		
		//關閉提示字卡
		private function closeCantPass(e:MouseEvent):void 
		{
			this.dispatchEvent(new MainEvent(MainEvent.UN_PAUSE, true));
			if (cantPass_mc.currentLabel == "nohp") { 
				this.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true, "221B.swf"));
			}
			cantPass_mc.visible = false;
			cantPass_mc.gotoAndStop(1);
		}
		
		//暫停
		override public function Pause(e:MainEvent):void {
			//trace("stage喊暫停!!");
			user_mc.removeEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
			upPressed = downPressed = rightPressed = leftPressed = false;
			cola_mc.gotoAndStop(directionTxt);
			MovieClip(cola_mc.getChildAt(1)).stop();
		}
		
		//結束暫停
		override public function UnPause(e:MainEvent):void {
			user_mc.addEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
		}
		
		//移除
		override public function kill(e:Event):void
		{ 
			super.kill(e);
			Tweener.pauseAllTweens();
			Tweener.removeAllTweens();  //trace("MainGame kill", Tweener.removeAllTweens(), Tweener.pauseAllTweens());
			//ChangeSide_btn.removeEventListener(MouseEvent.CLICK, goChangeSide);
			user_mc.removeEventListener(Event.ENTER_FRAME, fl_MoveInDirectionOfKey);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_SetKeyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_UP, fl_UnsetKeyPressed);
			userClipBmpData.dispose();
			map_mc.mapClipBmpData.dispose();
		}
	
	}

}