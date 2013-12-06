package As 
{
	import As.Events.MainEvent;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	/**
	 * ...indexMV會判斷是否有玩過的存檔,若有就會載入此swf,詢問是否要載入存檔或重新遊戲
	 * @author Neo
	 */
	public class OpenSave extends GM 
	{
		private var saveDataSharedObject:SharedObject = SharedObject.getLocal("saveData", "/");
		
		public function OpenSave() 
		{
			stop();
			open_btn.addEventListener(MouseEvent.MOUSE_OVER, playBtnSound);
			open_btn.addEventListener(MouseEvent.CLICK, openGame);
			new_btn.addEventListener(MouseEvent.CLICK, newGame);
			new_btn.addEventListener(MouseEvent.MOUSE_OVER, playBtnSound);
			playSound("TSC", sound_txt);
		}
		
		private function openGame(e:MouseEvent):void 
		{
			SingletonValue.getInstance().hp = saveDataSharedObject.data.hp;
			SingletonValue.getInstance().caseNum = saveDataSharedObject.data.caseNum;
			SingletonValue.getInstance().unitNum = saveDataSharedObject.data.unitNum;
			SingletonValue.getInstance().caseArr = saveDataSharedObject.data.caseArr;
			SingletonValue.getInstance().nowSiteName = saveDataSharedObject.data.nowSiteName;
			SingletonValue.getInstance().beforeSiteName = saveDataSharedObject.data.beforeSiteName;
			stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "221B.swf"));
		}
		
		private function newGame(e:MouseEvent):void 
		{
			stage.dispatchEvent(new MainEvent(MainEvent.CHANGE_SITE, true,  "221B_EX.swf"));
		}
		
		private function playBtnSound(e:MouseEvent):void 
		{
			stopSound("TSC");
			stopSound("BTNSC");
			if (e.currentTarget.name == "open_btn") {
				playSound("BTNSC", sound_open);
			}else {
				playSound("BTNSC", sound_new);
			}
		}
		
	}

}