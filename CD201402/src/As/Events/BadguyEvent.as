package As.Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class BadguyEvent extends Event 
	{
		public static const CHASE:String = "chase";		//進入追擊範圍
		public static const ATTACK:String = "attack";	//進入攻擊範圍
		public static const INJURE:String = "injure";	//遭受攻擊
		public static const TOUCH:String = "touch";		//碰到其他角色
		public static const CATCH:String = "catch";		//抓住
		
		public function BadguyEvent(type:String, bubbles:Boolean) 
		{
			super(type, bubbles);
		}
		
	}

}