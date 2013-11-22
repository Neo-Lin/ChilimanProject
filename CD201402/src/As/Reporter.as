package As 
{
	import As.Events.BadguyEvent;
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	/**
	 * ...記者
	 * @author Neo
	 */
	public class Reporter extends Badguy 
	{
		
		public function Reporter() 
		{
			chaseZoneX = 600;
			chaseZoneY = 300;
			chaseZoneW = chaseZoneX * 2 + 60;
			chaseZoneH = chaseZoneY * 2 + 30;
			//trace(chaseZoneW, chaseZoneH);
		}
		
		override public function inits():void {
			people = reporter_mc;
			people.stop();
		}
		
		override public function goChase():void 
		{
			super.goChase();
			see_mc.play();
		}
		
		//攻擊-纏住!!!
		override public function goAttack():void 
		{
			see_mc.play();
			this.dispatchEvent(new BadguyEvent(BadguyEvent.CATCH, true));
			people.gotoAndStop(directionTxt + "a");
			MovieClip(people.getChildAt(1)).play();
			Tweener.addTween(this, { time:1, onComplete:function() {
				die();
			} } );
		}
		
		//被攻擊
		override public function goInjure():void 
		{
			this.dispatchEvent(new BadguyEvent(BadguyEvent.CATCH, true));
			people.gotoAndStop(directionTxt + "a");
			MovieClip(people.getChildAt(1)).play();
			Tweener.addTween(this, { time:1, onComplete:function() {
				die();
			} } );
		}
	}

}