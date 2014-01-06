package As.Events 
{
	import As.TransformOperation;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class UndoManagerEvent extends Event 
	{
		public static const CLEAR_REDO :String = "clearRedo";			//清除重做堆疊
		public static const PUSH_UNDO :String = "pushUndo";				//新增物件
		
		public var tfo:TransformOperation;
		
		public function UndoManagerEvent(type:String, bubbles:Boolean=false, _tfo:TransformOperation = null) 
		{ 
			super(type, bubbles);
			tfo = _tfo;
		} 
		
		public override function clone():Event 
		{ 
			return new UndoManagerEvent(type, bubbles);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("UndoManagerEvent", "type", "bubbles", "eventPhase"); 
		}
		
	}
	
}