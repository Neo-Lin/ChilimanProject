package As.Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class LoadingPageEvent extends Event 
	{
		public static const START_TURN_PAGE :String = "startTurnPage";	//開始翻動頁面
		public static const STOP_TURN_PAGE :String = "stopTurnPage";	//停止翻動頁面(維持原頁)
		public static const STOP_TURN_PAGE_AND_CHANGE :String = "stopTurnPageAndChange";	//停止翻動頁面(有翻頁)
		public static const LOAD_OPEN :String = "loadOpen";				//開始載入頁面
		public static const LOAD_COMPLETE :String = "loadComplete";		//載入頁面完成
		public var msg:String;
		
		public function LoadingPageEvent(type:String, bubbles:Boolean=false, pMsg:String = "") 
		{ 
			super(type, bubbles, false);
			msg = pMsg;
		} 
		
		public override function clone():Event 
		{ 
			return new LoadingPageEvent(type, bubbles, msg);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LoadingPageEvent", "type", "bubbles", "msg", "eventPhase"); 
		}
		
	}
	
}