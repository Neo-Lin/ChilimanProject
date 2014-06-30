package  
{
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
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
		//檢查連線,有連線的Tile會存入
		private var _tArrayAllW:Array = [];
		private var _tArrayAllH:Array = [];
		private var _tweenerCount:int;
		private var _helpTile:Tile;
		private var _score:int;
		private var _scoreDouble:int = 1;	//計算分數加乘用
		
		public function EliminateGame(objectsMC:MovieClip) 
		{
			_objectsMC = objectsMC;
			addChild(_objectsMC);
			
			for (var i:int = 0; i < _hTile; i++) {
				_allTileArray[i] = new Array();
				for (var j:int = 0; j < _wTile; j++) {
					var _t:Tile = new Tile();
					_allTileArray[i][j] = _t;
					//"同色消除技能"的Tile不用指定影格
					if (_t.skill != "randomTile") {
						//做出不會連線的初始組合
						do{
							_t.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
						}while (initChk(i, j)) 
					}
					
					_objectsMC.addChild(_t);
					_t.x = _t.width * j;
					_t.y = _t.height * i;
					_t.name = i + "_" + j;
					_t.addEventListener(MouseEvent.MOUSE_DOWN, tileMD);
					_t.addEventListener(MouseEvent.MOUSE_UP, tileMU);
				}
			}
			impasse();
			_objectsMC.help_btn.addEventListener(MouseEvent.CLICK, goHelp);
		}
		
		private function goHelp(e:MouseEvent):void 
		{
			trace("help!!");
			_helpTile.help_mc.play();
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
		
		//使用者對調Tile
		private function tileMD(e:MouseEvent):void 
		{	
			//相同圖案的Tile全部消除的特殊技能(同色消除技能)
			if (e.currentTarget.skill == "randomTile") {
				e.currentTarget.stop();
				_objectsMC.mouseChildren = false;
				for (var i:int = _allTileArray.length - 1; i >= 0; i--) {
					for (var j:int = _allTileArray[i].length - 1; j >= 0; j--) {
						if (_allTileArray[i][j].currentFrameLabel == e.currentTarget.currentFrameLabel
						&& _allTileArray[i][j].skill != "randomTile") {
							cleanLineTweener(_allTileArray[i][j]);
							addScore(20);
						}
					}
				}
				//清除被按到的特殊技能Tile
				cleanLineTweener(e.currentTarget as Tile);
				if (_touchTile.length > 0) { //是否已選取了第一個圖案
					var _m:MovieClip = _objectsMC.getChildByName(_touchTile[0] + "_" + _touchTile[1]) as MovieClip;
					_m.select_mc.visible = false;
				}
				_touchTile.length = 0;
				return;
			}else {
				var _tmpAR:Array = e.currentTarget.name.split("_");
			}
			if (_touchTile.length > 0) { //是否已選取了第一個圖案
				var _m:MovieClip = _objectsMC.getChildByName(_touchTile[0] + "_" + _touchTile[1]) as MovieClip;
				_m.select_mc.visible = false;
				//上下交換
				if ((_touchTile[0] == int(_tmpAR[0]) + 1 || _touchTile[0] == int(_tmpAR[0]) - 1) &&
				_touchTile[1] == _tmpAR[1]) {	
					//改變陣列中兩個圖案的位置
					_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, _m);
					_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, e.currentTarget);
					//改變畫面上兩個圖案的位置
					Tweener.addTween(e.currentTarget, { y:_m.y, time:.3 } );
					Tweener.addTween(_m, { y:e.currentTarget.y, time:.3, onComplete:function() {
						if (chkLine(2)) {
							//動畫結束後刪除連線的Tile
							cleanLine();
						}
						} } );
					//檢查是否達成連線
					if (chkLine(2)) {
						//修改交換的物件名稱,因為名稱要對應陣列位置,所以換位置就要換名字
						var _mName:String = _m.name;
						_m.name = e.currentTarget.name
						e.currentTarget.name = _mName;
						//刪除連線的Tile
						//cleanLine();
					}else { //沒有達成連線,恢復原狀
						_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, e.currentTarget);
						_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, _m);
						Tweener.addTween(e.currentTarget, { y:e.currentTarget.y, time:.3, delay:.3 } );
						Tweener.addTween(_m, { y:_m.y, time:.3, delay:.3 } );
					}
				//左右交換
				}else if ((_touchTile[1] == int(_tmpAR[1]) + 1 || _touchTile[1] == int(_tmpAR[1]) - 1) &&
				_touchTile[0] == _tmpAR[0]) {	
					//改變陣列中兩個圖案的位置
					_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, _m);
					_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, e.currentTarget);
					//改變畫面上兩個圖案的位置
					Tweener.addTween(e.currentTarget, { x:_m.x, time:.3 } );
					Tweener.addTween(_m, { x:e.currentTarget.x, time:.3, onComplete:function() {
						if (chkLine(2)) {
							//動畫結束後刪除連線的Tile
							cleanLine();
						}
						} } );
					//檢查是否達成連線
					if (chkLine(2)) {
						//修改交換的物件名稱,因為名稱要對應陣列位置,所以換位置就要換名字
						var _mName:String = _m.name;
						_m.name = e.currentTarget.name
						e.currentTarget.name = _mName;
						//刪除連線的Tile
						//cleanLine();
					}else { //沒有達成連線,恢復原狀
						_allTileArray[_tmpAR[0]].splice(_tmpAR[1], 1, e.currentTarget);
						_allTileArray[_touchTile[0]].splice(_touchTile[1], 1, _m);
						Tweener.addTween(e.currentTarget, { x:e.currentTarget.x, time:.3, delay:.3 } );
						Tweener.addTween(_m, { x:_m.x, time:.3, delay:.3 } );
					}
				}else {
					//trace("不在旁邊");
				}
				_touchTile.length = 0;
			}else {
				_touchTile = _tmpAR;
				e.currentTarget.select_mc.visible = true;
			}
		}
		
		//判斷要加多少分數
		private function countScore(cs:int):void {
			if (cs == 3) {	trace("分數計算:50 * " + _scoreDouble + " = " + 50 * _scoreDouble)
				addScore(50 * _scoreDouble);
			}else if (cs == 4) {	trace("分數計算:100 * " + _scoreDouble + " = " + 100 * _scoreDouble)
				addScore(100 * _scoreDouble);
			}else if (cs == 5) {	trace("分數計算:150 * " + _scoreDouble + " = " + 150 * _scoreDouble)
				addScore(150 * _scoreDouble);
			}
		}
		//加分並顯示
		private function addScore(s:int):void {	trace("分數加 "+s+" 分::::");
			_score += s;
			_objectsMC.score_txt.text = _score;
		}
		
		//刪除連線的Tile
		private function cleanLine():void {
			_objectsMC.mouseChildren = false;
			var bombSkillTile:Array = [];
			var lightningSkillTile:Array = [];
			//刪除橫向
			for (var wi:int = 0; wi < _tArrayAllW.length; wi++) {
				countScore(_tArrayAllW[wi].length);
				for each(var f:Tile in _tArrayAllW[wi]) {
					//怕跟直向有重複到所以多一道檢查,把直向陣列有重複的刪除
					/*for (var whi:int = 0; whi < _tArrayAllH.length; whi++) {
						if(_tArrayAllH[whi].indexOf(f)>-1){ trace("刪:", _tArrayAllH[whi].indexOf(f), f.name);
							_tArrayAllH[whi].splice(_tArrayAllH[whi].indexOf(f), 1);
						}
					}*/
					if (f.skill == "bomb") {
						bombSkillTile.push([f.name.charAt(0), f.name.charAt(2)]);
					}else if (f.skill == "lightning") {
						lightningSkillTile.push([f.name.charAt(0), f.name.charAt(2)]);
					}
					cleanLineTweener(f);
				}
			}
			//刪除直向
			for (var hi:int = 0; hi < _tArrayAllH.length; hi++) {
				countScore(_tArrayAllH[hi].length);
				for each(var f:Tile in _tArrayAllH[hi]) {
					//是否有爆炸技能
					if (f.skill == "bomb") {
						bombSkillTile.push([f.name.charAt(0), f.name.charAt(2)]);
					}else if (f.skill == "lightning") {
						lightningSkillTile.push([f.name.charAt(0), f.name.charAt(2)]);
					}
					cleanLineTweener(f);
				}
			}
			//刪除九宮格爆炸
			for (var i:int = 0; i < bombSkillTile.length; i++) {
				bomb(bombSkillTile[i][0], bombSkillTile[i][1]);
				addScore(300);
			}
			//刪除閃電
			for (var i:int = 0; i < lightningSkillTile.length; i++) {
				lightning(lightningSkillTile[i][0], lightningSkillTile[i][1]);
				addScore(500);
			}
		}
		
		//刪除閃電
		private function lightning(skillTile_h:int, skillTile_w:int):void 
		{
			for (var i:int = 0; i < _hTile; i++) {
				cleanLineTweener(_allTileArray[i][skillTile_w]);
			}
			for (var j:int = 0; j < _wTile; j++) {
				cleanLineTweener(_allTileArray[skillTile_h][j]);
			}
			//閃電效果
			var _b:LightningMv = new LightningMv();
			_b.x = _allTileArray[skillTile_h][skillTile_w].x;
			_b.y = _allTileArray[skillTile_h][skillTile_w].y;
			addChild(_b);
		}
		
		//九宮格爆炸
		private function bomb(skillTile_h:int, skillTile_w:int):void {
			var h1:int;
			var w1:int;
			var h2:int;
			var w2:int;
			//取得九宮格範圍
			if (skillTile_h > 0) {
				h1 = skillTile_h - 1;
			}else {
				h1 = skillTile_h;
			}
			if (skillTile_h < _hTile-1) {
				h2 = skillTile_h + 1;
			}else {
				h2 = skillTile_h;
			}
			if (skillTile_w > 0) {
				w1 = skillTile_w - 1;
			}else {
				w1 = skillTile_w;
			}
			if (skillTile_w < _wTile-1) {
				w2 = skillTile_w + 1;
			}else {
				w2 = skillTile_w;
			}
			//刪除範圍內的Tile
			for (h1; h1 <= h2; h1++) {
				for (var w:int = w1; w <= w2; w++) {	
					cleanLineTweener(_allTileArray[h1][w]);
				}
			}
			//爆破效果
			var _b:BombMv = new BombMv();
			_b.x = _allTileArray[skillTile_h][skillTile_w].x;
			_b.y = _allTileArray[skillTile_h][skillTile_w].y;
			addChild(_b);
		}
		
		private function cleanLineTweener(f:Tile):void {
			//略過達成連線而即將被刪除的Tile,因為tweener的關係刪除會延遲,因此多一個屬性判斷
			if (f.readyKill) {	//trace("略過", f.name);
				return;
			}
			_tweenerCount++;
			f.readyKill = true;
			Tweener.addTween(f, { alpha:0, time:.5, transition:"easeInBounce", onComplete:function() {
				_tweenerCount--;
				_objectsMC.removeChild(_allTileArray[this.name.charAt(0)][this.name.charAt(2)]);
				_allTileArray[this.name.charAt(0)][this.name.charAt(2)] = null;	
				rankTile();
				} } );
		}
		
		//排列Tile陣列
		private function rankTile():void {	
			var _n:int = 0;
			for (var i:int = _allTileArray.length-1; i >= 0; i--) {
				for (var j:int = _allTileArray[i].length - 1; j >= 0; j--) {
					if (_allTileArray[j][i] == null) {
						_n++;
					}else if (_n > 0 ) {
						_allTileArray[j + _n][i] = _allTileArray[j][i];
						_allTileArray[j][i] = null;
						Tweener.addTween(_allTileArray[j + _n][i], { y:_allTileArray[j + _n][i].height * (j + _n), time:.5 } );
					}
				}
				_n = 0;
			}
			addTile();
		}
		
		//補滿Tile--編輯所有Tile的名字,對應Tile在_allTileArray裡的位置--檢查是否死棋
		private function addTile():void 
		{		
			//showMeAllTileArray();
			//trace("=============================================");
			for (var i:int = _allTileArray.length - 1; i >= 0; i--) {
				for (var j:int = _allTileArray[i].length - 1; j >= 0; j--) {
					if (!_allTileArray[i][j]) { 
						var _t:Tile = new Tile();
						//"同色消除技能"的Tile不用指定影格
						if (_t.skill != "randomTile") {
							_t.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
						}
						_objectsMC.addChild(_t);
						_t.x = _t.width * int(j);
						//_t.x += 400; 
						_t.addEventListener(MouseEvent.MOUSE_DOWN, tileMD);
						_t.addEventListener(MouseEvent.MOUSE_UP, tileMU);
						_allTileArray[i][j] = _t;
					}
					_allTileArray[i][j].name = i + "_" + j;
				}
			}
			if (_tweenerCount == 0) {	trace("=====================檢查是否死棋");
				if (chkLine(2)) {
					_scoreDouble++;  //連鎖反應分數加乘
					cleanLine();
				}else {
					_scoreDouble = 1;  //分數加乘歸零
					//檢查是否死棋
					if (impasse() > 0) {
						_objectsMC.mouseChildren = true;
					}else {	//死棋,刷新所有Tile
						renewTile();
					}
				}
			}
			//showMeAllTileArray();
		}
		
		//亂數更新所有Tile的影格
		private function renewTile():void 
		{
			var _m:MovieClip;
			for (var i:int = 0; i < _hTile; i++) {
				for (var j:int = 0; j < _wTile; j++) {
					_m = _objectsMC.getChildByName(i + "_" + j) as MovieClip
					do{
						_m.gotoAndStop(_tileName[Math.floor(Math.random() * _tileName.length)]);
					}while (initChk(i, j)) 
				}
			}	
			
			//檢查是否死棋
			if (impasse() > 0) {
				_objectsMC.mouseChildren = true;
			}else {
				renewTile();
			}
		}
		
		//檢查是否死棋
		private function impasse():int {
			var _i:int = 0;	//橫向
			var _j:int = 0;	//直向
			var _k:int = 0;	//十字
			var _n:int = 0;
			var h:int;
			var w:int;
			if (chkLine(1)) {
				//檢查橫向
				for (var wi:int = 0; wi < _tArrayAllW.length; wi++) {
					for each(var f:Tile in _tArrayAllW[wi]) {
						h = int(f.name.charAt(0));
						w = int(f.name.charAt(2));
						if (_n == 0) { 
							_n++;
							if (w - 2 >= 0 && _allTileArray[h][w - 2].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h][w - 2];
							}
							if (w - 1 >= 0 && h - 1 >= 0 && _allTileArray[h - 1][w - 1].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h - 1][w - 1];
							}
							if (w - 1 >= 0 && h + 1 <= _hTile-1 && _allTileArray[h + 1][w - 1].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h + 1][w - 1];
							}
						}else { 
							_n = 0;
							if (w + 2 <= _wTile-1 && _allTileArray[h][w + 2].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h][w + 2];
							}
							if (w + 1 <= _wTile-1 && h - 1 >= 0 && _allTileArray[h - 1][w + 1].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h - 1][w + 1];
							}
							if (w + 1 <= _wTile-1 && h + 1 <= _hTile-1 && _allTileArray[h + 1][w + 1].currentFrameLabel == f.currentFrameLabel) {
								_i++;
								_helpTile = _allTileArray[h + 1][w + 1];
							}
						}
					}
				}
				//檢查直向
				for (var hi:int = 0; hi < _tArrayAllH.length; hi++) {
					for each(var f:Tile in _tArrayAllH[hi]) {
						h = int(f.name.charAt(0));
						w = int(f.name.charAt(2));
						if (_n == 0) { 
							_n++;
							if (h - 2 >= 0 && _allTileArray[h - 2][w].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h - 2][w];
							}
							if (h - 1 >= 0 && w - 1 >= 0 && _allTileArray[h - 1][w - 1].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h - 1][w - 1];
							}
							if (h - 1 >= 0 && w + 1 <= _wTile-1 && _allTileArray[h - 1][w + 1].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h - 1][w + 1];
							}
						}else { 
							_n = 0;
							if (h + 2 <= _hTile-1 && _allTileArray[h + 2][w].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h + 2][w];
							}
							if (h + 1 <= _hTile-1 && w - 1 >= 0 && _allTileArray[h + 1][w - 1].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h + 1][w - 1];
							}
							if (h + 1 <= _hTile-1 && w + 1 <= _wTile-1 && _allTileArray[h + 1][w + 1].currentFrameLabel == f.currentFrameLabel) {
								_j++;
								_helpTile = _allTileArray[h + 1][w + 1];
							}
						}
					}
				}
			}
			//檢查十字
			for (var wi:int = 0; wi < _allTileArray.length; wi++) {
				for each(var f:Tile in _allTileArray[wi]) {
					h = int(f.name.charAt(0));
					w = int(f.name.charAt(2));
					//十字無論如何都會檢查,所以只要有"同色消除技能"的Tile,就直接指定為"提示"功能要顯示的Tile
					if (_allTileArray[h][w].skill == "randomTile") {
						_helpTile = _allTileArray[h][w];
						return 1;
					}
					var _a:String = "";
					var _l:String; //用來判斷少一邊的十字(因為靠牆所以只有三個)
					//紀錄每個Tile上下左右的影格標籤
					if (h - 1 >= 0) {
						_a+=_allTileArray[h - 1][w].currentFrameLabel;
					}else {
						_l = "h1"; //沒有上方的Tile
					}
					if (h + 1 <= _hTile-1) {
						_a+=_allTileArray[h + 1][w].currentFrameLabel;
					}else {
						_l = "h2";
					}
					if (w - 1 >= 0) {
						_a+=_allTileArray[h][w - 1].currentFrameLabel;
					}else {
						_l = "w1"; //沒有左邊的Tile
					}
					if (w + 1 <= _wTile-1) {
						_a += _allTileArray[h][w + 1].currentFrameLabel;
					} else {
						_l = "w2";
					}
					//檢查有沒有兩個以上重複的影格標籤,有就成立
					for (var e:int = 0; e < _tileName.length; e++) {
						var pattern:RegExp = new RegExp(_tileName[e],"g"); 
						if (_a.match(pattern).length > 2) {
							_k++;	
							if (_a.charAt(0) != _tileName[e]) {
								_helpTile = _allTileArray[h + 1][w];
							}else if (_a.charAt(1) != _tileName[e]) {
								_helpTile = _allTileArray[h - 1][w];
							}else if (_a.charAt(2) != _tileName[e]) {
								_helpTile = _allTileArray[h][w + 1];
							}else if(_a.length == 3 && _l == "h1"){ //靠在上方所以沒有上面,所以一定是下面的Tile可以移動
								_helpTile = _allTileArray[h + 1][w];
							}else if(_a.length == 3 && _l == "h2"){
								_helpTile = _allTileArray[h - 1][w];
							}else if(_a.length == 3 && _l == "w1"){ //靠在左方所以沒有左邊,所以一定是右邊的Tile可以移動
								_helpTile = _allTileArray[h][w + 1];
							}else if(_a.length == 3 && _l == "w2"){
								_helpTile = _allTileArray[h][w - 1];
							}else {
								_helpTile = _allTileArray[h][w - 1];
							}
							break;
						}
					}
				}
			}
			trace("檢查死路-橫:", _i, "檢查死路-直:", _j, "檢查死路-十字:", _k);
			return _i + _j + _k;
		}
		
		//檢查是否有連線
		private function chkLine(tileNum:int):Boolean {
			var _t:MovieClip;
			var _tArray:Array = [];
			_tArrayAllW = [];
			_tArrayAllH = [];
			//檢查橫向
			for (var i:uint = 0; i < _allTileArray.length; i++) {
				for (var j:uint = 0; j < _allTileArray[i].length; j++) {
					//若Tile有"同色消除技能"就跳過
					if (_allTileArray[i][j].skill == "randomTile") {
						_t = null;
						if (_tArray.length > tileNum) {
							_tArrayAllW.push(_tArray);
						}
						continue;
					}
					if (_t) {
						//若跟上一個相同
						if (_t.currentFrameLabel == _allTileArray[i][j].currentFrameLabel) {
							_tArray.push(_allTileArray[i][j]);
						}else {
							if (_tArray.length > tileNum) {
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
				if (_tArray.length > tileNum) {
					_tArrayAllW.push(_tArray);
				}
			}
			trace("_tArrayAllW:",_tArrayAllW);
			//檢查直向
			_tArray = [];
			for (var k:uint = 0; k < _allTileArray.length; k++) {
				for (var m:uint = 0; m < _allTileArray[k].length; m++) {
					//若Tile有"同色消除技能"就跳過
					if(_allTileArray[m][k].skill == "randomTile") {
						_t = null;
						if (_tArray.length > tileNum) {
							_tArrayAllW.push(_tArray);
						}
						continue;
					}
					if (_t) {
						//若跟上一個相同
						if (_t.currentFrameLabel == _allTileArray[m][k].currentFrameLabel) {
							_tArray.push(_allTileArray[m][k]);
						}else {
							if (_tArray.length > tileNum) {
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
				if (_tArray.length > tileNum) {
					_tArrayAllH.push(_tArray);
				}
			}
			trace("_tArrayAllH:",_tArrayAllH);
			
			if (_tArrayAllW.length > 0 || _tArrayAllH.length > 0) {
				return true;
			}else {
				return false;
			}
		}
		
		//印出_allTileArray
		private function showMeAllTileArray():void {
			var _s:String = "";
			for each(var af:Array in _allTileArray) {
				for each(var f in af) {
					if (f) { 
						_s += f.name += "   ";
					}else {
						_s += f += "                ";
					}
				}
				trace(" ");
				trace(_s);
				_s = "";
			}
		}
		
		private function tileMU(e:MouseEvent):void 
		{
			
		}
		
	}

}