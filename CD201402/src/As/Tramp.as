package As 
{
	import As.Events.BadguyEvent;
	/**
	 * ...街童
	 * @author Neo
	 */
	public class Tramp extends Badguy 
	{
		
		public function Tramp() 
		{
			
		}
		
		override public function inits():void {
			people = tramp_mc;
			people.stop();
		}
		
		//追逐
		override public function goChase():void {
			
		}
		
		//攻擊!!!
		override public function goAttack():void 
		{
			
		}
		
		//被攻擊
		override public function goInjure():void 
		{
			
		}
		
		//碰到
		override public function goTouch():void {
			this.dispatchEvent(new BadguyEvent(BadguyEvent.TOUCH, true));
			//trace("Badguy touch!!!");
		}
	}

}