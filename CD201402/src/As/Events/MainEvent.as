package As.Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class MainEvent extends Event 
	{
		public static const SAVE :String = "save";//傳值
		public static const CHANGE_SITE:String = "change";//換場景
		public static const UPDATE_HP:String = "hp";//血量更新
		
		public var ChangeSiteName:String;
		public var HP:uint;
		
		public function MainEvent(type:String, bubbles:Boolean, _value = null) 
		{
			super(type, bubbles);
			
			if (type == "change") {
				ChangeSiteName = _value;
			}else if (type == "hp") {
				HP = _value;
			}
			
		}
		
	}

}