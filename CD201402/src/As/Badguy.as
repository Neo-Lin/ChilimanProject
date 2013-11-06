package As 
{
	import As.Events.BadguyEvent;
	import caurina.transitions.Tweener;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * ...壞人
	 * @author Neo
	 */
	public class Badguy extends MovieClip 
	{
		private var initXY:Point;	//記錄一開始的位置
		private var mapBD:BitmapData;
		private var userBD:BitmapData;
		private var userMc:MovieClip;
		public var bulletMc:MovieClip;
		private var thisBD:BitmapData;
		private var _time:uint;
		private var myTime:Timer = new Timer(_time, 1);
		private var birthTime:Timer = new Timer(5000, 1);	//重生速度
		private var _move:int;
		private var _speed:uint = 1;	//亂亂走速度
		private var setRL:Boolean;
		
		private var userMcX:Number;
		private var userMcY:Number;
		
		public function Badguy() 
		{ 
			/*mapBD = bd;
			thisBD = new BitmapData(this.width, this.height, true, 0);
			thisBD.draw(this);
			
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			reTime(null);*/
			//在影格上加程式碼
			this.addFrameScript(0, frame1, 9, frame10, 19, frame10);
			stage.addEventListener(MainEvent.PAUSE, Pause);
			stage.addEventListener(MainEvent.UN_PAUSE, UnPause);
		}
		
		//外部傳入BitmapData才開始//地圖BitmapData//攻擊對象BitmapData//攻擊對象MovieClip//子彈MovieCLip
		public function startInit(_map:BitmapData, _user:BitmapData, _mc:MovieClip, _bullet:MovieClip) {
			initXY = new Point(this.x, this.y);
			mapBD = _map;
			userBD = _user;
			userMc = _mc;
			bulletMc = _bullet;
			thisBD = new BitmapData(this.width, this.height, true, 0);
			thisBD.draw(this);
			this.addEventListener(Event.ENTER_FRAME, goMove);
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			reTime(null);
		}
		
		private function reTime(e:TimerEvent):void 
		{ 
			//設定下次移動時間
			_time = (Math.random() * 4 + 1) * 1000; //trace(_time);
			myTime.delay = _time;
			
			//設定移動x或移動y
			if (Math.random() * 2 - 1 > 0) {
				setRL = true;
			}else {
				setRL = false;
			}
			//設定移動距離
			_move = Math.random() * 60 - 30; //trace("_move=",_move);
			
			
		}
		
		//移動角色
		private function goMove(e:Event):void 
		{ 	
			//計算map_mc移動後user_mc.x,y的偏差值
			userMcX = userMc.x - parent.x;
			userMcY = userMc.y - parent.y;
			
			//偵測追逐區碰撞
			if (userBD.hitTest(new Point(userMcX, userMcY), 255, new Rectangle(this.x-50, this.y-50, 130, 130), new Point(this.x, this.y), 255)) {
				goChase();
			}
			
			//亂亂走
			if (_move > 0) { 
				if (setRL && !mapBD.hitTest(new Point(0, 0), 255, thisBD, new Point(this.x + _speed, this.y), 255)) {
					this.x += _speed;
				}else if(!setRL && !mapBD.hitTest(new Point(0, 0), 255, thisBD, new Point(this.x, this.y + _speed), 255)){
					this.y += _speed;
				}
				_move --;
			}else if (_move < 0) { 
				if (setRL && !mapBD.hitTest(new Point(0, 0), 255, thisBD, new Point(this.x - _speed, this.y), 255)) {
					this.x -= _speed;
				}else if(!setRL && !mapBD.hitTest(new Point(0, 0), 255, thisBD, new Point(this.x, this.y - _speed), 255)){
					this.y -= _speed;
				}
				_move ++;
			}else { //trace("XX");
				//this.removeEventListener(Event.ENTER_FRAME, goMove);
				myTime.start();
			}
			
			//偵測攻擊區碰撞
			if (userBD.hitTest(new Point(userMcX, userMcY), 255, new Rectangle(this.x-10, this.y-10, 50, 50), new Point(this.x, this.y), 255)) {
				goAttack();
			}
			
			//偵測被子彈攻擊
			if (this.hitTestObject(bulletMc)) {
				goInjure();
			}
			
			//偵測碰到其他角色
			if (this.hitTestObject(userMc)) {
				goTouch();
			}
		}
		
		//追逐
		public function goChase():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.CHASE, true));
			this.gotoAndPlay(21);
			_move = 0;
			if (userMcX > this.x+1 && !mapBD.hitTest(new Point(0, 0), 255, thisBD, new Point(this.x + _speed, this.y), 255)) {
				this.x ++;
			}else if (userMcX < this.x && !mapBD.hitTest(new Point(0, 0), 255, thisBD, new Point(this.x - _speed, this.y), 255)) {
				this.x --;
			}
			if (userMcY > this.y+1 && !mapBD.hitTest(new Point(0, 0), 255, thisBD, new Point(this.x, this.y + _speed), 255)) {
				this.y ++;
			}else if (userMcY < this.y && !mapBD.hitTest(new Point(0, 0), 255, thisBD, new Point(this.x, this.y - _speed), 255)) {
				this.y --;
			}
		}
		
		//碰到
		public function goTouch():void 
		{
			/*this.dispatchEvent(new BadguyEvent(BadguyEvent.TOUCH, true));
			trace("Badguy touch!!!");*/
		}
		
		//被攻擊
		public function goInjure():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.INJURE, true));
			this.gotoAndPlay(2);
			die();
		}
		
		//攻擊!!!
		public function goAttack():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.ATTACK, true));
			this.gotoAndPlay(11);
		}
		
		//死亡==取消所有偵聽==消失==重生Time開始==
		private function die():void {
			this.removeEventListener(Event.ENTER_FRAME, goMove);
			myTime.removeEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			Tweener.addTween(this, { alpha:0, time:2, onComplete:function() {
				this.x = initXY.x;
				this.y = initXY.y;
				this.visible = false; 
				} } );
			birthTime.addEventListener(TimerEvent.TIMER_COMPLETE, birth);
			birthTime.start();
		}
		
		//在影格上加程式碼=======================
		public function frame10():void 
		{
			gotoAndStop(1);
		}
		
		public function frame1():void 
		{
			stop();
		}
		//=======================在影格上加程式碼
		
		//重生==恢復偵聽==出現
		private function birth(e:TimerEvent):void {
			birthTime.removeEventListener(TimerEvent.TIMER_COMPLETE, birth);
			myTime.addEventListener(TimerEvent.TIMER_COMPLETE, reTime);
			this.visible = true;
			//出現兩秒後才開始動作
			Tweener.addTween(this, { alpha:1, time:2, onComplete:function() {
				this.addEventListener(Event.ENTER_FRAME, goMove);
				} } );
		}
		
		//暫停
		override public function Pause(e:MainEvent):void {
			trace("Badguy暫停!!");
			this.removeEventListener(Event.ENTER_FRAME, goMove);
		}
		
		//結束暫停
		override public function UnPause(e:MainEvent):void {
			trace("Badguy結束暫停!!");
			this.addEventListener(Event.ENTER_FRAME, goMove);
		}
		
	}

}