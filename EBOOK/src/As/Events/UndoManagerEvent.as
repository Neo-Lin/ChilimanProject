package As.Events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class UndoManagerEvent extends Event 
	{
		public static const CLEAR_REDO :String = "clearRedo";			//清除重做堆疊
		public static const PUSH_UNDO :String = "pushUndo";				//新增物件
		
		public function UndoManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new UndoManagerEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("UndoManagerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}