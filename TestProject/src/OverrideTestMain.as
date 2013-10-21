package  
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author test
	 */
	public class OverrideTestMain extends Sprite 
	{
		
		public function OverrideTestMain() 
		{
			ft1();
			trace("Main");
		}
		
		public function ft1():void {
			trace("Ft1");
		}
		
		public function ft2():void{};
	}

}