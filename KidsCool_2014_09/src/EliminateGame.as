package  
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class EliminateGame extends Sprite 
	{
		private var _objectsMC:MovieClip;
		
		public function EliminateGame(objectsMC:MovieClip) 
		{
			_objectsMC = objectsMC;
			addChild(_objectsMC);
			
			var _t:Tile = new Tile();
			_objectsMC.addChild(_t);
		}
		
	}

}