package  
{
	import caurina.transitions.Tweener;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Neo
	 */
	public class Bird extends Loader 
	{
		private var _y:Number;
		private var _ice:Boolean;	//第四關要拿冰淇淋
		
		public function Bird(ice:Boolean = false) 
		{
			super();
			_ice = ice;
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			load(new URLRequest("levels/SoundPatchDemo/BIRD.swf"));
		}
		
		private function onComplete(e:Event):void 
		{
			MovieClip(content).y = -200;
		}
		
		public function get getX():Number
		{
			if (content)
				return MovieClip(content)._bird.x;
			else return 0;
		}
		
		public function get getY():Number
		{
			if (content)
				return MovieClip(content)._bird.y;
			else return 0;
		}
		
		public function setRole(role:String):void {
			//第四關老鷹抓的人物要拿冰淇淋,role==1表示老鷹沒抓任何人物
			if (_ice && role != "1" && role != "_gift") {	
				MovieClip(content)._bird._role.gotoAndStop(role + "_Ice");
			}else {
				MovieClip(content)._bird._role.gotoAndStop(role);
			}
		}
		
		public function hideBird():void {
			Tweener.addTween(MovieClip(content), {y:-200, time:1 } );
		}
		
		public function showBird():void {
			Tweener.addTween(MovieClip(content), {y:0, time:1 } );
		}
	}

}