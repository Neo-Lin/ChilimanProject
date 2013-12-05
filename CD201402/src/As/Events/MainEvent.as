package As.Events 
{
	import As.SingletonValue;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class MainEvent extends Event 
	{
		public static const SAVE :String = "save";						//傳值
		public static const CHANGE_SITE:String = "change";				//換場景
		public static const PAUSE:String = "pause";						//暫停
		public static const UN_PAUSE:String = "unpause";				//取消暫停
		public static const GAME_FINISH:String = "gameFinish";			//win,使用者過關後會發出此事件,由Main接收
		public static const LOAD_EX:String = "loadEx";					//載入遊戲說明(主選單)
		public static const TOOL_BAR_HIDE:String = "toolBarHide";		//toolBar隱藏
		public static const TOOL_BAR_SHOW:String = "toolBarShow";		//toolBar顯示
		public static const EXIT:String = "exit";						//離開光碟
		
		public var ChangeSiteName:String; //要載入的swf名或類型
		public var HP:uint;
		
		public function MainEvent(type:String, bubbles:Boolean, _value = null) 
		{
			super(type, bubbles);
			
			if (type == "change") {
				ChangeSiteName = _value;
				SingletonValue.getInstance().beforeSiteName = SingletonValue.getInstance().nowSiteName;
				SingletonValue.getInstance().nowSiteName = _value;
			}else if (type == "loadEx") {
				ChangeSiteName = _value;
			}
		}
		
	}

}