package  {

	import Box2D.Dynamics.Contacts.b2Contact;
	import caurina.transitions.Tweener;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.Timer;

	import citrus.core.CitrusObject;
	import citrus.core.State;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Coin;
	import citrus.objects.platformer.box2d.Crate;
	import citrus.objects.platformer.box2d.Enemy;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2D;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.utils.objectmakers.ObjectMaker2D;
	import citrus.utils.AGameData;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class DemoState extends State {
		private const DataName:String = "Act201404.asp";
		private var Uldr:URLLoader;
		private var Ureq:URLRequest;
		private var Udata:URLVariables;
		private var tmpStr:String;
		private var tmpXML:XML;
		
		private var _jewelMeter:JewelMeter;
		private var _bird:Bird;
		private var _tool:Tool;
		private var _objectsMC:MovieClip;
		//private var _loadScreen:LoadScreen;
		private var _clickScreen:ClickScreen;
		private var _signMessage:SignMessage;
		private var _hero:Hero;
		private var _sign:Sensor;
		private var _jewels:Vector.<CitrusObject>;
		private var _timer:Timer;
		private var _amount:int = 0; //疊起來的總數
		private var _dog:int = 0;	//疊起來的狗數量
		private var _s:Sprite = new Sprite();
		private var _heroCrate:Vector.<CitrusObject>;
		private var _tempRoleName:String;	//使用者選取人物時會記錄(changeRole)
		private var _gameNumber:int;	//遊戲關卡
		private var _opening:OpLoader;
		private var _tempBox:HeroCrate;
		private var _heroCrateContent:Sprite = new Sprite();

		public function DemoState(objectsMC:MovieClip) {
			super();
			_objectsMC = objectsMC;
			
			var objects:Array = [Platform, Hero, CitrusSprite, Sensor, Coin, Enemy, WindmillArms, Crate];
		}

		override public function initialize():void {
			super.initialize();
			
			//取得外部資料
			loadData();
			
			//載入畫面
			/*_loadScreen = new LoadScreen();
			addChild(_loadScreen);
			//載入完成移除載入畫面
			view.loadManager.onLoadComplete.addOnce(handleLoadComplete);*/

			var box2D:Box2D = new Box2D("box2D");
			//box2D.visible = true;
			box2D.gravity.y = 3;
			add(box2D);
			
			//首頁遊戲說明
			_opening = new OpLoader("levels/SoundPatchDemo/index_help.swf");
			addChild(_opening);
			_opening.addEventListener("goNext", goIndex);
			_opening.addEventListener("finishMovie", goIndex);

			ObjectMaker2D.FromMovieClip(_objectsMC);
			
			//對位用高度標示,隨堆疊高度升高或降低,讓camera對位用
			_sign = getObjectByName("signSensor") as Sensor;
			view.camera.setUp(_sign, new Rectangle(0, -600, 800, 1200), null, new Point(.25, .05));
			
			//測試掉落的箱子
			/*_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, _onTick);
			_timer.start();*/
		}
		
		//首頁選單
		private function goIndex(e:Event):void 
		{
			_opening.removeEventListener("goNext", goIndex);
			_opening.removeEventListener("finishMovie", goIndex);
			if (e) {
				Loader(e.currentTarget).unloadAndStop(true);
				e.currentTarget.removeEventListener("goBack", goIndex);
			}
			_opening = new OpLoader("levels/SoundPatchDemo/index.swf");
			_opening.contentLoaderInfo.addEventListener(Event.COMPLETE, indexComplete);
			addChild(_opening);
			_opening.addEventListener("CLOSE_WINDOW", closeWindow);
			_opening.addEventListener("startGoGame", startGoGame);
			_opening.addEventListener("goStore", goStore);
		}
		
		//儲藏室
		private function goStore(e:Event):void 
		{
			_opening.removeEventListener("CLOSE_WINDOW", closeWindow);
			_opening.removeEventListener("startGoGame", startGoGame);
			e.currentTarget.removeEventListener("goStore", goStore);
			Loader(e.currentTarget).unloadAndStop(true);
			_ce.sound.stopSound("Game1");
			var store:Store = new Store(_ce.gameData);
			addChild(store);
			store.addEventListener("goBack", storeGoIndex);	//回主選單
			store.addEventListener("changeGameData", storeChangeGameData);	//儲藏箱更新禮物資訊
		}
		
		private function storeChangeGameData(e:Event):void 
		{	
			/*sendAsp("Level1=" + e.currentTarget.gameData.level1 + 
					"&Level2=" + e.currentTarget.gameData.level2 + 
					"&Level3=" + e.currentTarget.gameData.level3 + 
					"&Level4=" + e.currentTarget.gameData.level4 + 
					"&send_gift=" + e.currentTarget.gameData.send_gift
					);*/
			if (e.currentTarget.gameData.mode == 2) {
				sendAsp("L=" + e.currentTarget.gameData.L + 
						"&S=" + e.currentTarget.gameData["level" + e.currentTarget.gameData.L]
						, e.currentTarget.gameData.mode);
			}else if (e.currentTarget.gameData.mode == 3) {
				sendAsp("F=" + e.currentTarget.gameData.send_gift
						, e.currentTarget.gameData.mode);
			}
			//trace("storeChangeGameData:",e.currentTarget.gameData.L);
		}
		
		private function storeGoIndex(e:Event):void 
		{
			e.currentTarget.removeEventListener("goBack", storeGoIndex);
			Loader(e.currentTarget).unloadAndStop(true);
			goIndex(null);
		}
		
		//檢查遊戲是否可開啟
		private function indexComplete(e:Event):void 
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, indexComplete);
			if (_ce.gameData.today > 20140407) {
				MovieClip(_opening.content).game2_mc.gotoAndStop(2);
				if (_ce.gameData.today > 20140414) {
					MovieClip(_opening.content).game3_mc.gotoAndStop(2);
					if (_ce.gameData.today > 20140421) {
						MovieClip(_opening.content).game4_mc.gotoAndStop(2);
					}
				}
			}
		}
		
		//取得關卡數字,載入開場動畫
		private function startGoGame(e:Event):void 
		{
			_gameNumber = e.currentTarget.gameNumber;
			_opening.removeEventListener("CLOSE_WINDOW", closeWindow);
			_opening.removeEventListener("startGoGame", startGoGame);
			_opening.removeEventListener("goStore", goStore);
			Loader(e.currentTarget).unloadAndStop(true);
			goGame();
		}
		
		//開場動畫
		private function goGame():void 
		{
			//Loader(e.currentTarget).unloadAndStop(true);
			_opening = new OpLoader("levels/SoundPatchDemo/game" + _gameNumber + "_op_" + _ce.gameData.sex + ".swf");
			addChild(_opening);
			_opening.addEventListener("goNext", goHelp);
			_opening.addEventListener("finishMovie", goHelp);
		}
		
		//遊戲說明
		private function goHelp(e:Event):void 
		{
			_opening.removeEventListener("goNext", goHelp);
			_opening.removeEventListener("finishMovie", goHelp);
			Loader(e.currentTarget).unloadAndStop(true);
			_opening = new OpLoader("levels/SoundPatchDemo/game_help.swf");
			addChild(_opening);
			_opening.addEventListener("goNext", startGame);
			_opening.addEventListener("finishMovie", startGame);
		}
		
		private function startGame(e:Event):void 
		{
			_opening.removeEventListener("goNext", startGame);
			_opening.removeEventListener("finishMovie", startGame);
			Loader(e.currentTarget).unloadAndStop(true);
			//開始遊戲
			addChild(_heroCrateContent);
			//恢復初始值,"再玩一次"用=================
			_amount = 0;
			_dog = 0;
			checkHeight();
			_ce.sound.stopSound("Fail");
			//=======================恢復初始值,"再玩一次"用
			//_ce.sound.playSound("Game" + _gameNumber);
			_ce.sound.playSound("Game1");
			//上方飛行的小鳥
			_bird = new Bird(_gameNumber == 4);
			addChild(_bird);
			//人物選擇,禮物,高度表
			_tool = new Tool(_ce.gameData.sex);
			_tool.addEventListener("changeRole", changeRole);
			_tool.addEventListener("goBack", goBackIndex);
			addChild(_tool);
			
			//依據不同遊戲載入佈景
			var _mb:CitrusSprite = getObjectByName("_mb") as CitrusSprite;
			_mb.view = "levels/SoundPatchDemo/game" + _gameNumber + "_mb.swf";
		}
		
		private function goBackIndex(e:Event):void 
		{
			_ce.sound.stopSound("Game1");
			finishGame();
			goIndex(null);
		}
		
		private function changeRole(e:Event):void 
		{
			_tool.showLight(false);
			_tempRoleName = _tool.roleName;
			_bird.setRole(_tool.roleName);
			_bird.showBird();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_KeyboardDownHandler);
		}
		
		private function fl_KeyboardDownHandler(event:KeyboardEvent):void
		{
			//trace("已按下按鍵碼: " + event.keyCode);
			if (event.keyCode == 32 && _tool.roleName) {
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_KeyboardDownHandler);
				_ce.sound.playSound("Skid");
				if (_tool.roleName == "_gift") {
					var gift:HeroCrate = new HeroCrate(_ce, "gift"+_amount, _objectsMC.floor_mc, _tempBox, {view:_tool.roleName+".png", registration:"center", width:83, height:45, x:_bird.getX, y:_bird.getY - view.camera.camPos.y});
					gift.sp.addEventListener("touch", getEventStatic);
					gift.sp.addEventListener("getGift", getGift);
					_heroCrateContent.addChild(gift);
					_bird.setRole("1");
				}else{
					_bird.setRole("1");
					_amount ++;
					//trace(view.camera.center.y,view.camera.camPos.y,view.camera.ghostTarget.y);
					var muffin:HeroCrate;
					//若是第四關,圖片名稱加_Ice,有拿冰淇淋的人物圖案
					var path:String = "";
					if (_gameNumber == 4) path = "_Ice";
					if (_tool.roleName != "_d") {
						muffin = new HeroCrate(_ce, "muffin"+_amount, _objectsMC.floor_mc, _tempBox, {view:_tool.roleName+path+".png", registration:"center", width:120, height:90, x:_bird.getX, y:_bird.getY - view.camera.camPos.y});
					}else {
						_dog ++;
						muffin = new HeroCrate(_ce, "muffin"+_amount, _objectsMC.floor_mc, _tempBox, {view:_tool.roleName+path+".png", registration:"center", width:120, height:45, x:_bird.getX, y:_bird.getY - view.camera.camPos.y});
					}
					_tempBox = muffin;
					muffin.sp.addEventListener("kill", getEvent);
					muffin.sp.addEventListener("touch", getEventTouch);
					muffin.sp.addEventListener("static", getEventStatic);
					_heroCrateContent.addChild(muffin);
				}
			}
		}
		
		private function checkWin():void {	trace("_tool._altitude.currentFrame:",_tool.getHight(),_tool.life);
			if (_tool.getHight() >= 100) {
				//過關
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_KeyboardDownHandler);
				_ce.sound.playSound("Win");
				finishGame();
				//紀錄關卡狀態=0沒過 1過關 2已兌換
				if(_ce.gameData["level" + _gameNumber] != 2) _ce.gameData["level" + _gameNumber] = 1;
				//過關動畫
				var _win:OpLoader = new OpLoader("levels/SoundPatchDemo/game" + _gameNumber + "_pass.swf");
				_win.contentLoaderInfo.addEventListener(Event.COMPLETE, setGiftNumber);
				_win.addEventListener("goStore", goStore);
				addChild(_win);
			}else if (_tool.life == 0) {
				//失敗
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, fl_KeyboardDownHandler);
				_ce.sound.playSound("Fail");
				finishGame();
				//停止關卡音樂
				//_ce.sound.stopSound("Game" + _gameNumber);
				_ce.sound.stopSound("Game1");
				//失敗動畫
				var _fail:OpLoader = new OpLoader("levels/SoundPatchDemo/game" + _gameNumber + "_fail.swf");
				_fail.contentLoaderInfo.addEventListener(Event.COMPLETE, setGiftNumber);
				addChild(_fail);
				_fail.addEventListener("goAgain", startGame); //再玩一次
				_fail.addEventListener("goBack", goIndex);	//回主選單
			}
		}
		
		private function finishGame():void {
			//_bird.unloadAndStop(true);
			//_tool.unloadAndStop(true);
			removeChild(_bird);
			removeChild(_tool);
			//刪除所有堆疊
			/*trace("刪除所有堆疊");
			_heroCrate = getObjectsByType(HeroCrate);
			for each (var heroCrate:HeroCrate in _heroCrate) {
				heroCrate.sp.removeEventListener("kill", getEvent);
				heroCrate.sp.removeEventListener("touch", getEventTouch);
				heroCrate.sp.removeEventListener("static", getEventStatic);
				removeChild(heroCrate);
			}*/
			_tempBox = null;
			var i:int = _heroCrateContent.numChildren;
			for (var s:int = 0; s < i; s++) {
				var _mc = _heroCrateContent.getChildAt(s);
				if (_mc is HeroCrate) {	//trace("刪除堆疊", _mc, s);
					i--;
					s--;
					_mc.sp.removeEventListener("kill", getEvent);
					_mc.sp.removeEventListener("touch", getEventTouch);
					_mc.sp.removeEventListener("static", getEventStatic);
					_heroCrateContent.removeChild(_mc);
				}
			}
		}
		
		//設定字卡的禮物盒數量
		private function setGiftNumber(e:Event):void 
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, setGiftNumber);
			var card_mc:MovieClip = e.currentTarget.content.getChildByName("card_mc") as MovieClip;
			var p_mc:MovieClip = e.currentTarget.content.getChildByName("p_mc") as MovieClip;
			//紀錄關卡中得到的禮物數量
			//_ce.gameData.gift = _tool.giftNum;	
			sendAsp("L=" + _gameNumber + 
					"&S=" + _ce.gameData["level" + _gameNumber] +
					"&G=" + _tool.giftNum
					, 2);
			if (_tool.giftNum > 9) {
				card_mc._a.gotoAndStop("_f"+String(_tool.giftNum).charAt(1));
				card_mc._b.gotoAndStop("_f"+String(_tool.giftNum).charAt(0));
			}else {
				card_mc._a.gotoAndStop("_f"+_tool.giftNum);
				card_mc._b.gotoAndStop(1);
			}
			//判斷男女,男1女2
			if (_ce.gameData.sex == "boy") {
				p_mc.gotoAndStop(1);
			}else {
				p_mc.gotoAndStop(2);
			}
		}
		
		private function getGift(e:Event):void 
		{	//trace("給我禮物");
			_tool.getGift();
		}
		
		private function getEventTouch(e:Event):void 
		{
			_ce.sound.playSound("Jump");
		}
		
		private function getEventStatic(e:Event):void 
		{	//trace("Touch:::::",e.currentTarget.name, e.target.name);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, fl_KeyboardDownHandler);
			checkHeight();
			checkWin();
			//亂數產生禮物
			if (Math.random() < .2 ) {	
				//設定鳥抓取禮物
				_tool.roleName = "_gift";
				_bird.setRole(_tool.roleName);
			}else {
				//將禮物喚回人物
				_tool.roleName = _tempRoleName;
				_bird.setRole(_tool.roleName);
			}
		}
		
		//沒接好掉到地上了
		private function getEvent(e:Event):void 
		{
			if(!_ce.sound.soundIsPlaying("Miss")) _ce.sound.playSound("Miss");
			_amount --;
			_tempBox = _heroCrateContent.getChildByName("muffin" + _amount) as HeroCrate;
			if (e.currentTarget.name == "_d.png") _dog --;
			_tool.roleKill();
			_tool.roleName = null;
			_tool.showLight(true);
			_bird.hideBird();
			checkHeight();
			checkWin();
		}

		private function checkHeight():void {
			//依據疊的數量來計算高度,以便讓camera可以對位(狗的高度不同所以要另外算)
			_sign.setParams(_sign, { y: 600 - 110 * (_amount - _dog) - (55 * _dog) } ); 
			if (_tool) _tool.goHight((_amount - _dog) * 10 + _dog * 5);
			//trace("checkHeight::::::",_amount, _dog, _sign.y, view.camera.camPos.y);
		}
		
		override public function update(timeDelta:Number):void {
			super.update(timeDelta);
			_heroCrateContent.y = view.camera.camPos.y;
			_objectsMC.floor_mc.y = 600 + view.camera.camPos.y;
			/*if (_heroCrateContent.rotation > 1) {
				_heroCrateContent.rotation = - (_amount + _dog) / 2;
				trace(_heroCrateContent.rotation);
			}else if (_heroCrateContent.rotation < 1) {
				_heroCrateContent.rotation = (_amount + _dog) / 2;
			}*/
		}

		//關閉視窗
		private function closeWindow(e:Event):void {
			navigateToURL(new URLRequest("javascript:window.opener=self; window.close();"), "_self");
		}
		
		//=================================asp=======================================
		//取得data
		private function loadData():void {
			Uldr = new URLLoader();
			Ureq = new URLRequest(DataName);
			Udata = new URLVariables();
			tmpStr = "mode=1";
			Udata.decode(tmpStr);
			Ureq.data = Udata;
			//trace("playerType:", Capabilities.playerType);
			if (Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone") {
				Uldr.load(new URLRequest('Act201404.xml'));
			} else {
				Uldr.load(Ureq);
			}
			Uldr.addEventListener(Event.COMPLETE, DataLoaded);
		}
		//Data載入完成
		private function DataLoaded(e:Event):void {
			e.currentTarget.removeEventListener(Event.COMPLETE, DataLoaded);
			//=============取得資料==============;
			tmpXML = new XML(e.currentTarget.data);
			//trace(tmpXML);
			_ce.gameData = new AGameData();
			_ce.gameData.today = tmpXML["Today"];
			if (tmpXML["Sex"] == 1) {
				_ce.gameData.sex = "boy";
			}else {
				_ce.gameData.sex = "girl";
			}
			_ce.gameData.gift = tmpXML["Gift"];
			_ce.gameData.level1 = tmpXML["Level1"];
			_ce.gameData.level2 = tmpXML["Level2"];
			_ce.gameData.level3 = tmpXML["Level3"];
			_ce.gameData.level4 = tmpXML["Level4"];
		}
		//傳值
		private function sendAsp(v:String,m:int):void {
			Uldr = new URLLoader();
			Ureq = new URLRequest(DataName);
			Udata = new URLVariables();
			/*var _v:String = "Gift=" + _ce.gameData.gift +
							"&Level1=" + _ce.gameData.level1 + 
							"&Level2=" + _ce.gameData.level2 + 
							"&Level3=" + _ce.gameData.level3 + 
							"&Level4=" + _ce.gameData.level4;
			if (e) {
				_v + "&send_gift=" + _ce.gameData.level4;
			}*/
			tmpStr = "mode=" + m + "&" + v;
			Udata.decode(tmpStr);
			Ureq.data = Udata;
			//trace("playerType:", Capabilities.playerType);
			if (Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone") {
				Uldr.load(new URLRequest('Act201404.xml'));
			} else {
				Uldr.load(Ureq);
			}
			loadData();
			//Uldr.addEventListener(Event.COMPLETE, DataLoaded);
		}
		/*private function _onTick(tEvt:TimerEvent):void {
			_amount ++;
			var muffin:HeroCrate = new HeroCrate("muffin"+_amount, {view:"all0001.png", registration:"center", width:83, height:90, x:_bird.getX, y:_bird.getY});
			muffin.sp.addEventListener("kill", getEvent);
			muffin.sp.addEventListener("test", getEventTest);
			add(muffin);
		}
		
		private function handleLoadComplete():void {
			removeChild(_loadScreen);
		}*/
		
	}
}