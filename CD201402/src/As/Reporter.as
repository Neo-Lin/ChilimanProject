package As 
{
	import As.Events.BadguyEvent;
	/**
	 * ...記者
	 * @author Neo
	 */
	public class Reporter extends Badguy 
	{
		
		public function Reporter() 
		{
			
		}
		
		//攻擊-纏住!!!
		override public function goAttack():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.CATCH, true));
			this.gotoAndPlay(11);
		}
		
		//被攻擊
		override public function goInjure():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.CATCH, true));
			this.gotoAndPlay(11);
		}
	}

}