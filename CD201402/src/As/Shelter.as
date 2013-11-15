package As 
{
	import As.Events.BadguyEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Shelter extends MovieClip 
	{
		private var cola_mc:MovieClip;
		
		public function Shelter() 
		{
			
		}
		
		public function startInit(_cola:MovieClip) {
			cola_mc = _cola;
			this.addEventListener(Event.ENTER_FRAME, goCheck);
		}
		
		private function goCheck(e:Event):void 
		{	
			if (shelterZone_mc.hitTestObject(cola_mc)) {
				//偵測碰撞
				this.gotoAndStop(2);
				this.dispatchEvent(new BadguyEvent(BadguyEvent.COVER, true));
			}else {
				this.gotoAndStop(1);
				this.dispatchEvent(new BadguyEvent(BadguyEvent.UNCOVER, true));
			}
		}
		
	}

}