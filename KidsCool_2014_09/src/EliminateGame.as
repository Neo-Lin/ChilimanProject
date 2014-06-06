package  
{
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class EliminateGame extends Sprite 
	{
		private var _objectsMC:MovieClip;
		private var _hTile:uint = 8;
		private var _wTile:uint = 8;
		private var _tileName:Array = ["a", "b", "c", "d", "e", "f", "g"];
		private var _allTileArray:Array = new Array();
		private var _touchTile:Array = [];
		private var _addLineNum:int = 0;
		
		public function EliminateGame(objectsMC:MovieClip) 
		{
			_objectsMC = objectsMC;
			addChild(_objectsMC);
			
			for (var i:int = 0; i < _hTile; i++) {
				_allTileArray[i] = new Array();
				for (var j:int = 0; j < _wTile; j++) {
					var _t:Tile = new Tile();
					_allTileArray[i][j] = _t;
					//做出不會連線的初始組合
					do{
						_t.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
					}while (initChk(i, j)) 
					
					_objectsMC.addChild(_t);
					_t.x = _t.width * j;
					_t.y = _t.height * i;
					_t.name = i + "_" + j;
					_t.addEventListener(MouseEvent.MOUSE_DOWN, tileMD);
					_t.addEventListener(MouseEvent.MOUSE_UP, tileMU);
				}
			}
		}
		
		private function initChk(i:int, j:int):Boolean 
		{
			if (i > 1) {
				if(_allTileArray[i][j].currentFrameLabel == _allTileArray[i - 1][j].currentFrameLabel) {
					if(_allTileArray[i][j].currentFrameLabel == _allTileArray[i - 2][j].currentFrameLabel) {
						return true;
					}
				}
			}
			if (j > 1) {
				if(_allTileArray[i][j].currentFrameLabel == _allTileArray[i][j - 1].currentFrameLabel) {
					if(_allTileArray[i][j].currentFrameLabel == _allTileArray[i][j - 2].currentFrameLabel) {
						return true;
					}
				}
			}
			return false;
		}
		
		private function tileMD(e:MouseEvent):void 
		{	//trace(e.currentTarget.name.split("_")[0]);
			var _tmpAR:Array = e.currentTarget.name.split("_");
			if (_touchTile.length > 0) { //是否已選取了第一個圖案
				var _m:MovieClip = _objectsMC.getChildByName(_touchTile[0] + "_" + _touchTile[1]) as MovieClip;
				if ((_touchTile[0] == int(_tmpAR[0]) + 1 || _touchTile[0] == int(_tmpAR[0]) - 1) &&
				_touchTile[1] == _tmpAR[1]) {	trace("在上下旁邊");
					//判斷交換後能不能達成連線
					if (chkLine()) {
						Tweener.addTween(e.currentTarget, { y:_m.y, time:.5 } );
						Tweener.addTween(_m, {y:e.currentTarget.y, time:.5 } );
					}
				}else if ((_touchTile[1] == int(_tmpAR[1]) + 1 || _touchTile[1] == int(_tmpAR[1]) - 1) &&
				_touchTile[0] == _tmpAR[0]) {	trace("在左右旁邊");
					if (chkLine()) {
						Tweener.addTween(e.currentTarget, { x:_m.x, time:.5 } );
						Tweener.addTween(_m, { x:e.currentTarget.x, time:.5 } );
					}
				}else {
					trace("不在旁邊");
				}
				_touchTile.length = 0;
			}else {
				_touchTile = _tmpAR;
			}
		}
		
		//檢查是否有連線
		private function chkLine():Boolean {
			var _t:MovieClip;
			var _tArray:Array = [];
			var _tArrayAllW:Array = [];
			var _tArrayAllH:Array = [];
			//檢查橫向
			for (var i:uint = 0; i < _allTileArray.length; i++) {
				for (var j:uint = 0; j < _allTileArray[i].length; j++) {
					if (_t) {
						//若跟上一個相同
						if (_t.currentFrameLabel == _allTileArray[i][j].currentFrameLabel) {
							_tArray.push(_allTileArray[i][j]);
						}else {
							if (_tArray.length > 1) {
								_tArray.push("++"+i);
								_tArrayAllW.push(_tArray);
							}
							_t = _allTileArray[i][j];
							_tArray = [_t];
						}
					}else {
						_t = _allTileArray[i][j];
						_tArray = [_t];
					}
				}
				_t = null;
				if (_tArray.length > 1) {
					_tArray.push("=="+i);
					_tArrayAllW.push(_tArray);
				}
			}
			trace(_tArrayAllW);
			//檢查直向
			_tArray = [];
			for (var k:uint = 0; k < _allTileArray.length; k++) {
				for (var m:uint = 0; m < _allTileArray[k].length; m++) {
					if (_t) {
						//若跟上一個相同
						if (_t.currentFrameLabel == _allTileArray[m][k].currentFrameLabel) {
							_tArray.push(_allTileArray[m][k]);
						}else {
							if (_tArray.length > 1) {
								_tArray.push("++"+k);
								_tArrayAllH.push(_tArray);
							}
							_t = _allTileArray[m][k];
							_tArray = [_t];
						}
					}else {
						_t = _allTileArray[m][k];
						_tArray = [_t];
					}
				}
				_t = null;
				if (_tArray.length > 1) {
					_tArray.push("=="+k);
					_tArrayAllH.push(_tArray);
				}
			}
			trace(_tArrayAllH);
			
			return true;
		}
		
		private function tileMU(e:MouseEvent):void 
		{
			/*var _tmpAR:Array = e.currentTarget.name.split("_");
			if (_touchTile.length > 0) { //是否已選取了第一個圖案
				var _m:MovieClip = _objectsMC.getChildByName(_touchTile[0] + "_" + _touchTile[1]) as MovieClip;
				if ((_touchTile[0] == int(_tmpAR[0]) + 1 || _touchTile[0] == int(_tmpAR[0]) - 1) &&
				_touchTile[1] == _tmpAR[1]) {	trace("在上下旁邊");
					Tweener.addTween(e.currentTarget, { y:_m.y, time:.5 } );
					Tweener.addTween(_m, {y:e.currentTarget.y, time:.5 } );
				}else if ((_touchTile[1] == int(_tmpAR[1]) + 1 || _touchTile[1] == int(_tmpAR[1]) - 1) &&
				_touchTile[0] == _tmpAR[0]) {	trace("在左右旁邊");
					Tweener.addTween(e.currentTarget, { x:_m.x, time:.5 } );
					Tweener.addTween(_m, {x:e.currentTarget.x, time:.5 } );
				}else {
					trace("不在旁邊");
				}
				_touchTile.length = 0;
			}*/
		}
		
	}

}