package  
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.objects.platformer.box2d.Crate;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class CoinCrate extends Crate 
	{
		private var _sp:Sprite = new Sprite();
		
		public function CoinCrate(name:String, params:Object=null) 
		{
			super(name, params);
			beginContactCallEnabled = true;
		}
		
		override public function handleBeginContact(contact:b2Contact):void {
			var bodyB:b2Body = contact.GetFixtureB().GetBody();
			
			if (bodyB.GetUserData().name != "floor") {	//有接到
				//trace("得到禮物!!!");
				_sp.dispatchEvent(new Event("getGift"));
				_ce.sound.playSound("Beep");
			}else {
				_ce.sound.playSound("Miss");
			}
			_sp.dispatchEvent(new Event("touch"));
			kill = true;
		}
		
		public function get sp():Sprite 
		{
			return _sp;
		}
	}

}