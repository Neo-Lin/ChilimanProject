package As 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...NPC_mc的人物深度判斷
	 * @author Neo
	 */
	public class MainGameNpc extends MovieClip 
	{
		private var _n:uint;
		
		public function MainGameNpc() 
		{
			_n = numChildren;
			this.addEventListener(Event.ENTER_FRAME, checkIndex);
		}
		
		private function checkIndex(e:Event):void 
		{
			for (var i:uint = 0; i < _n; i++) {
				var _mc:MovieClip = getChildAt(i) as MovieClip;
				for (var j:uint = 0; j < _n; j++) {
					var jmc:MovieClip = getChildAt(j) as MovieClip;
					if (_mc != jmc) {
						if (_mc.y > jmc.y && getChildIndex(_mc) < getChildIndex(jmc)) {
							this.swapChildren(_mc, jmc);
						}
					}
					
				}
			}
		}
		
	}

}