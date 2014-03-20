package  
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2WeldJoint;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import caurina.transitions.Tweener;
	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.objects.platformer.box2d.Crate;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class HeroCrate extends Loader 
	{
		/*[Embed(source = "/../embed/_aBoy.png")]
		private var _loadScreenClass:Class;*/
		
		private var _ce:CitrusEngine;
		private var _sp:Sprite = new Sprite();
		private var _tempView:String;
		public var _params:Object;
		private var _floor:DisplayObject;
		private var _box:DisplayObject;
		private var _n:Number = 1;
		private var loadScreen:Bitmap;
		private var _content:MovieClip;
		private var _aHeight:int = 100;
		private var _dHeight:int = 75;
		private var _allow:int = 25;	//越小越難
		
		public function HeroCrate(ce:CitrusEngine, _name:String, floor:DisplayObject, box:DisplayObject, params:Object=null) 
		{
			/*super(name, params);
			beginContactCallEnabled = true;
			updateCallEnabled = true;*/
			super();
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			load(new URLRequest("levels/SoundPatchDemo/role.swf"));
			
			_ce = ce;
			name = _name;
			_params = params;
			if (floor) _floor = floor;
			if (box) _box = box;
			x = params.x;
			y = params.y;
			/*loadScreen = new _loadScreenClass();
			loadScreen.x = -loadScreen.width / 2;
			addChild(loadScreen);*/
		}
		
		/*private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.ENTER_FRAME, onEF);
		}*/
		
		private function onComplete(e:Event):void 
		{
			_content = MovieClip(content);
			_content.gotoAndStop(_params.view);
			_content.x = -_content.width / 2;
			addEventListener(Event.ENTER_FRAME, onEF);
		}
		
		private function onEF(e:Event):void 
		{
			_n += 1;
			y += _n;
			if (hitTestObject(_floor)) {	//碰到地板
				removeEventListener(Event.ENTER_FRAME, onEF);
				if (name == "muffin1") {
					_sp.dispatchEvent(new Event("static"));
					return; //若是第一個就可以碰到地板不會刪除
				}else if (name.indexOf("gift") > -1) {
					_sp.dispatchEvent(new Event("touch"));
					_ce.sound.playSound("Miss");
				}
				kill();
			}else if (_box && hitTestObject(_box)) {	//碰到其他堆疊
				if (_params.view.indexOf("_d") > -1) {
					y = _box.y - _dHeight;
				}else {
					y = _box.y - _aHeight;
				}
				//狗的偏差值
				if (HeroCrate(_box)._params.view.indexOf("_d") > -1) y += 20;
				removeEventListener(Event.ENTER_FRAME, onEF);
				_sp.dispatchEvent(new Event("touch"));
				if (name.indexOf("gift") > -1) {
					_sp.dispatchEvent(new Event("getGift"));
					_ce.sound.playSound("Beep");
					kill();
					return;
				}
				//判斷有沒有放歪
				if (x > _box.x + _allow) {
					playFallSound();
					rotation = 30;
					x += 50;
				}else if (x < _box.x - _allow) {
					playFallSound();
					rotation = -30;
					x -= 50;
				}else {	 
					_sp.dispatchEvent(new Event("static"));
				}
			}
		}
		
		private function playFallSound():void {
			if (_params.view.indexOf("_aB") > -1) { //分辨是誰掉下來
				if (!_ce.sound.soundIsPlaying("Ya")) _ce.sound.playSound("Ya");
			}else if (_params.view.indexOf("_aG") > -1) { //分辨是誰掉下來
				if (!_ce.sound.soundIsPlaying("Ya1")) _ce.sound.playSound("Ya1");
			}else if (_params.view.indexOf("_b") > -1) { //分辨是誰掉下來
				if (!_ce.sound.soundIsPlaying("Yb")) _ce.sound.playSound("Yb");
			}else if (_params.view.indexOf("_c") > -1) { //分辨是誰掉下來
				if (!_ce.sound.soundIsPlaying("Yc")) _ce.sound.playSound("Yc");
			}else {
				if (!_ce.sound.soundIsPlaying("Wuan")) _ce.sound.playSound("Wuan");
			}
			//換成一臉驚恐的圖
			_content.gotoAndStop(_params.view.substr(0,_params.view.lastIndexOf(".")) + "_fall.png");
			Tweener.addTween(this, { y: y+400, time:1, onComplete:kill, transition:"easeInCubic" } );
		}
		
		private function kill():void 
		{
			parent.removeChild(this);
			_sp.dispatchEvent(new Event("kill"));
			//removeChild(loadScreen);
			}
		
		/*override public function handleBeginContact(contact:b2Contact):void {
			var bodyB:b2Body = contact.GetFixtureB().GetBody();
			//var bodyA:b2Body = contact.GetFixtureA().GetBody();
			//速度減少,減少難度
			body.SetLinearVelocity(new b2Vec2(0, 1));
			//trace("\\", view);
			_tempView = _sp.name = view;
			//_sp.name = bodyB.GetUserData().name;
			
			if (name == "muffin1") { //若是第一個就可以碰到地板不會刪除
				beginContactCallEnabled = false;
				touchable = false;
				postContactCallEnabled = false;
			}else if (bodyB.GetUserData() == this) {
				return;
			}else if (bodyB.GetUserData().name == "floor") {	//沒接好掉到地板,刪除
				kill = true;
				_sp.dispatchEvent(new Event("kill"));
				return;
			}
			_sp.y = y;
			_sp.dispatchEvent(new Event("touch"));
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(0);
			//物體接近靜止,不會再改變位置(掉到地上)
			//trace("static:::::", velocity);
			if (velocity[1] < 0.00025 && velocity[1] > -0.00025) {
				//trace("static:::::", velocity);
				view = _tempView;
				_ce.sound.stopSound("Ya");
				_ce.sound.stopSound("Ya1");
				_ce.sound.stopSound("Yb");
				_ce.sound.stopSound("Yc");
				_ce.sound.stopSound("Wuan");
				updateCallEnabled = false;
				_sp.dispatchEvent(new Event("static"));
			}else {
				//if(_tempView) trace("D:::::",_tempView,_tempView.lastIndexOf("fall"));
				if (_tempView && _tempView.lastIndexOf("fall") < 0) {
					if (_tempView.indexOf("_aB") > -1) { //分辨是誰掉下來
						if (!_ce.sound.soundIsPlaying("Ya")) _ce.sound.playSound("Ya");
					}else if (_tempView.indexOf("_aG") > -1) { //分辨是誰掉下來
						if (!_ce.sound.soundIsPlaying("Ya1")) _ce.sound.playSound("Ya1");
					}else if (_tempView.indexOf("_b") > -1) { //分辨是誰掉下來
						if (!_ce.sound.soundIsPlaying("Yb")) _ce.sound.playSound("Yb");
					}else if (_tempView.indexOf("_c") > -1) { //分辨是誰掉下來
						if (!_ce.sound.soundIsPlaying("Yc")) _ce.sound.playSound("Yc");
					}else {
						if (!_ce.sound.soundIsPlaying("Wuan")) _ce.sound.playSound("Wuan");
					}
					//換成一臉驚恐的圖
					view = _tempView.substr(0,_tempView.lastIndexOf(".")) + "_fall.png";
				}
			}
		}*/
		
		public function get sp():Sprite 
		{
			return _sp;
		}
	}

}