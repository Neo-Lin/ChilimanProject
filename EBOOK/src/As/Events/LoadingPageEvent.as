package As.Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class LoadingPageEvent extends Event 
	{
		public static const LOAD_OPEN :String = "loadOpen";				//開始載入頁面
		public static const LOAD_COMPLETE :String = "loadComplete";		//載入頁面完成
		
		public function LoadingPageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new LoadingPageEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LoadingPageEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}