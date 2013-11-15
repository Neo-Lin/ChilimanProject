package As 
{
	import As.Events.BadguyEvent;
	import flash.display.MovieClip;
	/**
	 * ...記者
	 * @author Neo
	 */
	public class Reporter extends Badguy 
	{
		
		public function Reporter() 
		{
			
		}
		
		override public function inits():void {
			people = reporter_mc;
			people.stop();
		}
		
		//攻擊-纏住!!!
		override public function goAttack():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.CATCH, true));
			people.gotoAndStop(directionTxt + "a");
			MovieClip(people.getChildAt(1)).play();
		}
		
		//被攻擊
		override public function goInjure():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.CATCH, true));
			people.gotoAndStop(directionTxt + "a");
			MovieClip(people.getChildAt(1)).play();
		}
	}

}