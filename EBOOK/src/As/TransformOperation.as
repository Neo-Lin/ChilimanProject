package As
{
	import flashx.undo.IOperation;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class TransformOperation implements IOperation
	{
		
		private var _previousX:Number = 0;
		private var _previousY:Number = 0;
		private var _previousVisible:Boolean = true;
		
		private var _currentX:Number = 0;
		private var _currentY:Number = 0;
		private var _currentVisible:Boolean = true;
		
		private var _affectObj:Object = new Object();
		
		public function TransformOperation(affectObj:Object, previousX:Number, previousY:Number, currentX:Number, currentY:Number, previousVisible:Boolean, currentVisible:Boolean)
		{	
			_previousX = previousX;
			_previousY = previousY;
			_previousVisible = previousVisible;
			
			_currentX = currentX;
			_currentY = currentY;
			_currentVisible = currentVisible;
			_affectObj = affectObj;
			
			//trace('Transform _previousX:  ' + _previousX + ' _previousY:  ' + _previousY + ' _affectObj ' + _affectObj );
			//trace('trans _currentX    ' + _currentX + '  ' + '_currentY     ' + _currentY);
		}
		
		public function performUndo():void
		{
			if (affectObj is Array) {	//一次多個物件
				var n:int = _affectObj.length;
				for (var i:int = 0; i < n; i++) {
					_affectObj[i].visible = _previousVisible;
				}
			}else {	//單個物件
				_affectObj.x = _previousX;
				_affectObj.y = _previousY;
				_affectObj.visible = _previousVisible;
			}
		}
		
		public function performRedo():void
		{
			if (affectObj is Array) {	//一次多個物件
				var n:int = _affectObj.length;
				for (var i:int = 0; i < n; i++) {
					_affectObj[i].visible = _currentVisible;
				}
			}else {	//單個物件
				_affectObj.x = _currentX;
				_affectObj.y = _currentY;
				_affectObj.visible = _currentVisible;
			}
			//trace(_currentX + '  ' + _currentY);
		}
		
		public function get affectObj():Object 
		{
			return _affectObj;
		}
	}

}