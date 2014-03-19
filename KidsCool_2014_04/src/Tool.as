package  
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Tool extends Loader 
	{
		private var _role:MovieClip;
		private var _gift:MovieClip;
		private var _giftNum:int;
		private var _altitude:MovieClip;
		private var _roleName:String;
		private var _roleSex:String;
		private var back_btn:SimpleButton;
		private var _life:int = 4;
		
		public function Tool(_sex:String) 
		{
			super();
			_roleSex = _sex;
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, getAllTool);
			load(new URLRequest("levels/SoundPatchDemo/TOOL.swf"));
		}
		
		private function getAllTool(e:Event):void 
		{
			_role = MovieClip(content)._role;
			_role.gotoAndStop(_roleSex);
			_gift = MovieClip(content)._gift;
			_altitude = MovieClip(content)._altitude;
			back_btn = MovieClip(content).back_btn;
			
			if (_roleSex == "boy") {
				_role._aBoy.addEventListener(MouseEvent.CLICK, roleClick);
			}else {
				_role._aGirl.addEventListener(MouseEvent.CLICK, roleClick);
			}
			_role._b.addEventListener(MouseEvent.CLICK, roleClick);
			_role._c.addEventListener(MouseEvent.CLICK, roleClick);
			_role._d.addEventListener(MouseEvent.CLICK, roleClick);
			
			back_btn.addEventListener(MouseEvent.CLICK, back);
		}
		
		private function back(e:MouseEvent):void 
		{
			dispatchEvent(new Event("goBack"));
		}
		
		public function getGift():void {
			_giftNum++;
			//trace(_giftNum);
			if (_giftNum > 9) {
				_gift._a.gotoAndStop("_f"+String(_giftNum).charAt(1));
				_gift._b.gotoAndStop("_f"+String(_giftNum).charAt(0));
			}else {
				_gift._a.gotoAndStop("_f"+_giftNum);
				_gift._b.gotoAndStop(1);
			}
		}
		
		//高度計
		public function goHight(_n:int):void {
			if (_altitude) {
				_altitude.gotoAndStop(_n);
			}
		}
		//取得高度
		public function getHight():int {
			if (_altitude) {
				return _altitude.currentFrame;
			}
			return 0;
		}
		
		//切換腳色
		private function roleClick(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop(2);
			_roleName = e.currentTarget.name;
			dispatchEvent(new Event("changeRole"));
		}
		//掉到地上的人物就無法使用
		public function roleKill():void {
			if (_roleName && _roleName != "_gift") {
				_life--;
				_role[_roleName].gotoAndStop(3);
				_role[_roleName].removeEventListener(MouseEvent.CLICK, roleClick);
			}
		}
		//紅框
		public function showLight(_b:Boolean):void {
			_role._light.visible = _b;
		}
		//取得人物名稱
		public function get roleName():String 
		{
			return _roleName;
		}
		public function set roleName(value:String):void 
		{
			_roleName = value;
		}
		//取得生命值
		public function get life():int 
		{
			return _life;
		}
		
		public function get giftNum():int 
		{
			return _giftNum;
		}
	}

}