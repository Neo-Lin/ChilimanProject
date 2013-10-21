package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author test
	 */
	public class MenuEvent extends Event 
	{
		public static const Mouse_Click :String = "MouseClick";
		public var Target_Name :String = "null";
		
		public function MenuEvent(type:String, TargetName:String) 
		{ 
			super(type);
			
			Target_Name = TargetName;
		} 
		
		
		
	}
	
}