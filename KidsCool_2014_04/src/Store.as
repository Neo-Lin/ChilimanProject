package  
{
	import citrus.core.CitrusEngine;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Store extends Loader 
	{
		private static var _giftNumber = [75462, 16858, 67724, 97613];
		private var _gameData:Object;
		private var store:MovieClip;
		private var gainGift:MovieClip;
		private var _ce:CitrusEngine;
		
		public function Store(ce) 
		{	
			super();
			_gameData = ce.gameData;
			_ce = ce;
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			load(new URLRequest("levels/SoundPatchDemo/store.swf"));
		}
		
		private function onComplete(e:Event):void 
		{
			store = content as MovieClip;
			gainGift = store.GainGift_mc;
			store.back_btn.addEventListener(MouseEvent.CLICK, back);
			store.openGift_btn.addEventListener(MouseEvent.CLICK, openGift);
			
			checkDate();
			checkGiftNumber();
			
		}
		
		//檢查禮物數量
		private function checkGiftNumber():void {
			if (_gameData.gift == 99) {
				//顯示99個字卡
				store.LevelGiftPanel_mc.gotoAndStop(3);
				store.LevelGiftPanel_mc.visible = true;
				//按確定後關閉字卡
				store.LevelGiftPanel_mc.ok_btn.addEventListener(MouseEvent.CLICK, closeLevelGiftPanel);
			}
			if (_gameData.gift > 9) {
				store._a.gotoAndStop("_f"+String(_gameData.gift).charAt(1));
				store._b.gotoAndStop("_f"+String(_gameData.gift).charAt(0));
				store._b.visible = true;
			}else {
				store._a.gotoAndStop("_f" + _gameData.gift);
				store._b.gotoAndStop(1);
				store._b.visible = false;
			}
		}
		
		//檢查遊戲是否可開啟
		private function checkDate():void 
		{
			if (_gameData.today > 20140407) {
				store.level2Pic_mc.gotoAndStop(2);
				if (_gameData.today > 20140414) {
					store.level3Pic_mc.gotoAndStop(2);
					if (_gameData.today > 20140421) {
						store.level4Pic_mc.gotoAndStop(2);
					}
				}
			}
			
			if (_gameData.level1 == 1) { //第一關過關
				store.level1Pic_mc.gotoAndStop(3);
				store.level1_mc.gotoAndStop(2);
				store.level1_mc.number_txt.addEventListener(FocusEvent.FOCUS_IN, startInput);
				store.level1_btn.addEventListener(MouseEvent.CLICK, checkLevelGift);
			}else if (_gameData.level1 == 2) { //第一關已兌換
				store.level1Pic_mc.gotoAndStop(3);
				store.level1_mc.gotoAndStop(3);
				store.level1_btn.visible = false;
			}
			if (_gameData.level2 == 1) { //第二關過關
				store.level2Pic_mc.gotoAndStop(3);
				store.level2_mc.gotoAndStop(2);
				store.level2_mc.number_txt.addEventListener(FocusEvent.FOCUS_IN, startInput);
				store.level2_btn.addEventListener(MouseEvent.CLICK, checkLevelGift);
			}else if (_gameData.level2 == 2) { //第二關已兌換
				store.level2Pic_mc.gotoAndStop(3);
				store.level2_mc.gotoAndStop(3);
				store.level2_btn.visible = false;
			}
			if (_gameData.level3 == 1) { //第三關過關
				store.level3Pic_mc.gotoAndStop(3);
				store.level3_mc.gotoAndStop(2);
				store.level3_mc.number_txt.addEventListener(FocusEvent.FOCUS_IN, startInput);
				store.level3_btn.addEventListener(MouseEvent.CLICK, checkLevelGift);
			}else if (_gameData.level3 == 2) { //第三關已兌換
				store.level3Pic_mc.gotoAndStop(3);
				store.level3_mc.gotoAndStop(3);
				store.level3_btn.visible = false;
			}
			if (_gameData.level4 == 1) { //第四關過關
				store.level4Pic_mc.gotoAndStop(3);
				store.level4_mc.gotoAndStop(2);
				store.level4_mc.number_txt.addEventListener(FocusEvent.FOCUS_IN, startInput);
				store.level4_btn.addEventListener(MouseEvent.CLICK, checkLevelGift);
			}else if (_gameData.level4 == 2) { //第四關已兌換
				store.level4Pic_mc.gotoAndStop(3);
				store.level4_mc.gotoAndStop(3);
				store.level4_btn.visible = false;
			}
		}
		
		//檢查輸入序號是否正確
		private function checkLevelGift(e:MouseEvent):void 
		{
			var _level:int = int(e.currentTarget.name.slice(5, 6));
			if (store["level" + _level + "_mc"].number_txt.text == _giftNumber[_level - 1]) {
				//顯示已送到小屋字卡
				store.LevelGiftPanel_mc.gotoAndStop(1);
				store.LevelGiftPanel_mc.visible = true;
				//存檔
				_gameData["level" + _level] = 2;
				_gameData.L = _level;
				_gameData.mode = 2;
				dispatchEvent(new Event("changeGameData"));
				//顯示為已兌換,移除確定按鈕偵聽
				store["level" + _level + "Pic_mc"].gotoAndStop(3);
				store["level" + _level + "_mc"].gotoAndStop(3);
				store["level" + _level + "_btn"].removeEventListener(MouseEvent.CLICK, checkLevelGift);
				e.currentTarget.visible = false;
			}else {
				//顯示輸入錯誤字卡
				store.LevelGiftPanel_mc.gotoAndStop(2);
				store.LevelGiftPanel_mc.visible = true;
				_ce.sound.playSound("Miss");
			}
			//按確定後關閉字卡
			store.LevelGiftPanel_mc.ok_btn.addEventListener(MouseEvent.CLICK, closeLevelGiftPanel);
		}
		
		private function closeLevelGiftPanel(e:MouseEvent):void 
		{
			store.LevelGiftPanel_mc.visible = false;
		}
		
		private function startInput(e:Event):void 
		{
			e.currentTarget.text = "";
			e.currentTarget.parent.t_mc.visible = false;
		}
		
		private function openGift(e:MouseEvent):void 
		{
			if (_gameData.gift == 0) return;
			//減少禮物數量
			_gameData.gift --;
			checkGiftNumber();
			//顯示開禮物畫面,亂數決定禮物
			_gameData.send_gift = Math.ceil(Math.random() * gainGift.allGift_mc.totalFrames);
			gainGift.allGift_mc.gotoAndStop(_gameData.send_gift);
			if (_gameData.send_gift < 11) {
				_ce.sound.playSound("gift1");
			}else if (_gameData.send_gift < 15) {
				_ce.sound.playSound("gift2");
			}else {
				_ce.sound.playSound("gift3");
			}
			//存檔
			_gameData.mode = 3;
			dispatchEvent(new Event("changeGameData"));
			gainGift.visible = true;
			gainGift.gotoAndPlay(2);
			gainGift.ok_btn.addEventListener(MouseEvent.CLICK, closeGainGift);
		}
		//關閉開禮物畫面
		private function closeGainGift(e:MouseEvent):void 
		{
			gainGift.visible = false;
		}
		
		private function back(e:MouseEvent):void 
		{
			dispatchEvent(new Event("goBack"));
		}
		
		public function get gameData():Object 
		{
			return _gameData;
		}
		
	}

}