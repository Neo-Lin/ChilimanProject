package  
{
	import citrus.objects.CitrusSprite;
	import citrus.view.ICitrusArt;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class BackGround extends CitrusSprite 
	{
		
		public function BackGround(name:String, params:Object=null) 
		{
			super(name, params);
		}
		
		override public function handleArtChanged(oldArt:ICitrusArt):void 
		{
			super.handleArtChanged(oldArt);
			trace("handleArtChanged!!!!!!");
		}
	}

}