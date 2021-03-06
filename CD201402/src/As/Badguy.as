package As 
{
	import As.Events.BadguyEvent;
	import As.Events.MainEvent;
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.Video;
	import flash.utils.Timer;
	
	/**
	 * ...壞人
	 * @author Neo
	 */
	public class Badguy extends MovieClip 
	{
		private var initXY:Point;	//記錄一開始的位置
		private var mapBD:BitmapData;
		private var mapBDPoint:Point = new Point(-20, -20);
		private var userBD:BitmapData;
		private var userMc:MovieClip;
		public var bulletMc:MovieClip;
		private var thisBD:BitmapData;
		private var _time:uint;
		private var myTime:Timer = new Timer(_time, 1);
		private var birthTime:Timer = new Timer(5000, 1);	//重生速度
		private var _move:int;
		private var _speed:uint = 7;		//亂亂走速度
		private var chaseSpeed:uint = 5;	//追逐速度
		private var setRL:Boolean;
		public var people:MovieClip;
		public var chaseZoneX:uint = 200;
		public var chaseZoneY:uint = 200;
		public var chaseZoneW:uint = chaseZoneX * 2 + 60;
		public var chaseZoneH:uint = chaseZoneY * 2 + 30;
		
		private var userMcX:Number;
		private var userMcY:Number;
		
		private var zone_mc:Zone = new Zone();
		public var directionTxt:String = "r";
		private var tempDirection1:String;
		private var tempDirection2:String;
		private var tempDirectionTime:uint;
		private var tempDirection:Number;
		
		private var tempBadguyX:Number;		//判斷是否卡住用
		private var tempBadguyY:Number;
		private var stopXY:uint;
		private var tempStopXY:uint;
		
		public var onChase:Boolean = false;  //是否在追擊狀態
		
		private var modeTxt:String = "";	//空:走路 a:攻擊 b:被攻擊
		private var sb3:Sound = new sound_bad3();
		
		private var isPause:Boolean = false;
		
		public function Badguy() 
		{ 
			/*mapBD = bd;
			thisBD = new BitmapData(this.width, this.height, true, 0);
			thisBD.draw(this);
			
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			reTime(null);*/
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.addEventListener(Event.REMOVED_FROM_STAGE, kill);
			//在影格上加程式碼
			//this.addFrameScript(0, frame1, 9, frame10, 19, frame10);
			stage.addEventListener(MainEvent.PAUSE, Pause);
			stage.addEventListener(MainEvent.UN_PAUSE, UnPause);
			//addChild(zone_mc);
			inits();
		}
		
		public function inits():void {
			people = badguy_mc;
			people.stop();
			MovieClip(people.getChildAt(1)).gotoAndStop(1);
			//trace(people.getChildAt(1));
			//MovieClip(people.getChildAt(1)).stop();
		}
		
		//外部傳入BitmapData才開始//地圖BitmapData//攻擊對象BitmapData//攻擊對象MovieClip//子彈MovieCLip
		public function startInit(_map:BitmapData, _user:BitmapData, _mc:MovieClip, _bullet:MovieClip) {
			initXY = new Point(this.x, this.y);
			mapBD = _map;
			userBD = _user;
			userMc = _mc;
			bulletMc = _bullet;
			thisBD = new BitmapData(zone_mc.width, zone_mc.height, true, 0);
			thisBD.draw(zone_mc);
			
			//進入主遊戲後三秒才開始動作
			this.alpha = 0;
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			Tweener.addTween(this, { alpha:1, time:2, transition:"easeInExpo", onComplete:function() {
				if (!isPause) {
					this.addEventListener(Event.ENTER_FRAME, goMove);
					reTime(null);
				}
				} } );
		}
		
		private function reTime(e:TimerEvent):void 
		{ 
			//設定下次移動時間
			_time = (Math.random() * 2) * 1000; //trace(_time);
			myTime.delay = _time;
			
			//設定移動x或移動y
			if (Math.random() * 2 - 1 > 0) {
				setRL = true;
			}else {
				setRL = false;
			}
			//設定移動距離
			_move = Math.random() * 80 - 40; //trace("_move=",_move);
		}
		
		//移動角色
		private function goMove(e:Event):void 
		{ 	
			//計算map_mc移動後user_mc.x,y的偏差值
			userMcX = userMc.x - parent.x;
			userMcY = userMc.y - parent.y;
			
			//偵測被子彈攻擊
			if (this.hitTestObject(bulletMc)) {
				goInjure();
				return;
			}
			
			//偵測碰到其他角色
			if (userMc.alpha == 1 && userBD.hitTest(new Point(userMcX, userMcY), 255, new Rectangle(this.x, this.y, 60, 30))) {
				goTouch();
				return;
			}
			
			//偵測追逐區碰撞
			if (userMc.alpha == 1 && userBD.hitTest(new Point(userMcX, userMcY), 255, new Rectangle(this.x - chaseZoneX, this.y - chaseZoneY, chaseZoneW, chaseZoneH))) {
				//偵測攻擊區碰撞
				if (userBD.hitTest(new Point(userMcX, userMcY), 255, new Rectangle(this.x - 30, this.y - 30, 120, 90))) {
					goAttack();
					return;
				}
				goChase();
				onChase = true;
				return;
			}else {
				onChase = false;
			}
			
			//亂亂走
			if (_move > 0) { 
				if (setRL && !mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x + _speed, this.y), 255)) {
					this.x += _speed;
					directionTxt = "r";
					people.gotoAndStop(directionTxt);
					MovieClip(people.getChildAt(1)).play();
				}else if(!setRL && !mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x, this.y + _speed), 255)){
					this.y += _speed;
					directionTxt = "d";
					people.gotoAndStop(directionTxt);
					MovieClip(people.getChildAt(1)).play();
				}
				_move --;
			}else if (_move < 0) { 
				if (setRL && !mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x - _speed, this.y), 255)) {
					this.x -= _speed;
					directionTxt = "l";
					people.gotoAndStop(directionTxt);
					MovieClip(people.getChildAt(1)).play();
				}else if(!setRL && !mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x, this.y - _speed), 255)){
					this.y -= _speed;
					directionTxt = "u";
					people.gotoAndStop(directionTxt);
					MovieClip(people.getChildAt(1)).play();
				}
				_move ++;
			}else { //trace("XX");
				//this.removeEventListener(Event.ENTER_FRAME, goMove);
				myTime.start();
				people.gotoAndStop(directionTxt);
				MovieClip(people.getChildAt(1)).gotoAndStop(1);
			}
		}
		
		//追逐
		public function goChase():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.CHASE, true));
			//this.gotoAndPlay(21);
			_move = 0;
			changeDirection();
			autoChangeDirection();
			if (directionTxt == "r" && !mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x + _speed, this.y), 255)) {
				this.x += chaseSpeed;
			}else if (directionTxt == "l" && !mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x - _speed, this.y), 255)) {
				this.x -= chaseSpeed;
			}else if (directionTxt == "d" && !mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x, this.y + _speed), 255)) {
				this.y += chaseSpeed;
			}else if (directionTxt == "u" && !mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x, this.y - _speed), 255)) {
				this.y -= chaseSpeed;
			}
			people.gotoAndStop(directionTxt);
			MovieClip(people.getChildAt(1)).play();
		}
		
		//左右或上下座標超過一定限度才紀錄方向,
		public function changeDirection():void {
			if (userMcY > this.y+5) {
				tempDirection1 = "d";
			}else if (userMcY < this.y-5) {
				tempDirection1 = "u";
			}else {
				tempDirection1 = "";
			}
			if (userMcX > this.x+5) {
				tempDirection2 = "r";
			}else if (userMcX < this.x-5) {
				tempDirection2 = "l";
			}else {
				tempDirection2 = "";
			}
			if (tempDirection1 == "" && tempDirection2 == "") {
				tempDirection1 = tempDirection2 = directionTxt;
			}else if (tempDirection1 == "") {
				directionTxt = tempDirection1 = tempDirection2;
			}else if (tempDirection2 == "") {
				directionTxt = tempDirection2 = tempDirection1;
			}
		}
		
		//自動改變行走方向(躲避障礙物,追蹤更精準)
		private function autoChangeDirection():void {	
			tempDirectionTime++;
			if (tempDirectionTime == 5) {
				tempDirectionTime = 0;
				tempDirection = Math.random() * 2;	
			}
			if (tempDirection > 1) {
				directionTxt = tempDirection1;
			}else {
				directionTxt = tempDirection2;
			}
			
			//判斷是否卡住
			if (tempStopXY == 0) {
				if (tempBadguyX == this.x && tempBadguyY == this.y) {
					stopXY ++;
				}else {
					tempBadguyX = this.x;
					tempBadguyY = this.y;
					stopXY = 0;
				}
				if (stopXY > 30) {
					tempStopXY = stopXY;
					duck();
				}
			}else {
				duck();
			}
		}
		
		//躲避左下,左上,右下,右上障礙
		private function duck():void {
			if (tempDirection1 == "u" && tempDirection2 == "l") {
				directionTxt = "r";
			}else if (tempDirection1 == "d" && tempDirection2 == "l") {
				directionTxt = "r";
			}else if (tempDirection1 == "d" && tempDirection2 == "r") {
				directionTxt = "l";
			}else if (tempDirection1 == "u" && tempDirection2 == "r") {
				directionTxt = "d";
			}else if(tempDirection1 == "d" || tempDirection1 == "u"){
				if (!mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x + _speed, this.y), 255)) {
					directionTxt = "r";
				}else {
					directionTxt = "l";
				}
			}else if(tempDirection2 == "r" || tempDirection2 == "l"){
				if (!mapBD.hitTest(mapBDPoint, 255, thisBD, new Point(this.x, this.y + _speed), 255)) {
					directionTxt = "d";
				}else {
					directionTxt = "u";
				}
			}
			tempStopXY --;
		}
		
		
		//碰到
		public function goTouch():void 
		{
			/*this.dispatchEvent(new BadguyEvent(BadguyEvent.TOUCH, true));
			trace("Badguy touch!!!");*/
			goAttack();
		}
		
		//被攻擊
		public function goInjure():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.INJURE, true));
			//this.gotoAndPlay(2);
			people.gotoAndStop(directionTxt + "b");
			MovieClip(people.getChildAt(1)).play();
			sb3.play();
			die();
		}
		
		//攻擊!!!
		public function goAttack():void 
		{
			changeDirection();
			//this.gotoAndPlay(11);
			people.gotoAndStop(directionTxt + "a");	
			MovieClip(people.getChildAt(1)).play();
			this.dispatchEvent(new BadguyEvent(BadguyEvent.ATTACK, true));
		}
		
		//死亡==取消所有偵聽==消失==重生Time開始==
		public function die():void {
			this.removeEventListener(Event.ENTER_FRAME, goMove);
			myTime.removeEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			Tweener.addTween(this, { alpha:0, time:2, onComplete:function() {
				this.x = initXY.x;
				this.y = initXY.y;
				this.visible = false; 
				people.gotoAndStop(directionTxt);
				MovieClip(people.getChildAt(1)).gotoAndStop(1);
				} } );
			birthTime.addEventListener(TimerEvent.TIMER_COMPLETE, birth);
			birthTime.start();
		}
		
		//重生==恢復偵聽==出現
		private function birth(e:TimerEvent):void {
			birthTime.removeEventListener(TimerEvent.TIMER_COMPLETE, birth);
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			this.visible = true;
			//出現兩秒後才開始動作
			Tweener.addTween(this, { alpha:1, time:2, onComplete:function() {
				if(!isPause) this.addEventListener(Event.ENTER_FRAME, goMove);
				} } );
		}
		
		//暫停
		public function Pause(e:MainEvent):void {
			//trace("Badguy暫停!!");
			isPause = true;
			this.removeEventListener(Event.ENTER_FRAME, goMove);
			myTime.reset();
			birthTime.reset();
			//Tweener.pauseAllTweens();
			people.gotoAndStop(directionTxt);
			MovieClip(people.getChildAt(1)).gotoAndStop(1);
		}
		
		//結束暫停
		public function UnPause(e:MainEvent):void {
			//trace("Badguy結束暫停!!");
			//Tweener.resumeAllTweens();
			isPause = false;
			myTime.start();
			
			//死亡後會自動重生,若這時暫停就會自動恢復ENTER_FRAME的偵聽而出問題,因此做個是否在重生中的判斷
			if (birthTime.hasEventListener(TimerEvent.TIMER_COMPLETE)) {  //重生中遇到暫停
				birthTime.start();
			} else {
				this.addEventListener(Event.ENTER_FRAME, goMove);
			}
		}
		
		public function kill(e:Event = null):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, kill);
			stage.removeEventListener(MainEvent.PAUSE, Pause);
			stage.removeEventListener(MainEvent.UN_PAUSE, UnPause);
			this.removeEventListener(Event.ENTER_FRAME, goMove);
			myTime.removeEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			birthTime.removeEventListener(TimerEvent.TIMER_COMPLETE, birth);
			myTime.reset();
			birthTime.reset();
			Tweener.pauseAllTweens();
			Tweener.resumeAllTweens();
		}
		
		
		
		//在影格上加程式碼=======================
		/*public function frame10():void 
		{
			gotoAndStop(1);
		}
		
		public function frame1():void 
		{
			stop();
		}*/
		//=======================在影格上加程式碼
		
	}

}