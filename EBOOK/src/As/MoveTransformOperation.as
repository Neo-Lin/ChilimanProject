package As
{
	import flashx.undo.IOperation;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class MoveTransformOperation implements IOperation
	{
		
		private var _previousX:Number = 0;
		private var _previousY:Number = 0;
		private var _previousObj:Object = new Object();
		private var _currentX:Number = 0;
		private var _currentY:Number = 0;
		private var _currentObj:Object = new Object();
		private var _shape:Object = new Object();
		
		public function MoveTransformOperation(currentObj:Object, previousObj:Object, previousX:Number, previousY:Number, currentX:Number, currentY:Number)
		{
			_previousX = previousX;
			_previousY = previousY;
			_previousObj = previousObj;
			
			_currentX = currentX;
			_currentY = currentY;
			_currentObj = currentObj;
			_shape = _currentObj;
			
			trace('Transform _previousX:  ' + _previousX + ' _previousY:  ' + _previousY + ' _currentObj ' + _currentObj + ' _shape ' + _shape);
			trace('trans _currentX    ' + _currentX + '  ' + '_currentY     ' + _currentY);
		
		}
		
		public function performUndo():void
		{
			_shape = _currentObj;
			//trace('_shape.x '+_shape.x+" _shape.y "+_shape.y);
			_shape.x = _previousX;
			_shape.y = _previousY;
			//trace(_previousX +'  '+ _previousY +'  '+ _previousWidth +'  '+ _previousHeight +'  '+  _previousScaleX +'  '+  _previousScaleY +'  '+ _previousRotation);
			//trace('_shape.x '+_shape.x+" _shape.y "+_shape.y);
			//trace('_currentX    '+ _currentX +'  '+'_currentY     '+ _currentY);
		}
		
		public function performRedo():void
		{
			_shape.x = _currentX;
			_shape.y = _currentY;
			trace(_currentX + '  ' + _currentY);
		}
	}

}