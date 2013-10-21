package As {
	
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	//將As資料夾放於Fla程式位置
	import As.yu.display.VarsSent;
	
	
	public class AsName extends MovieClip {
		
		
		var VS:VarsSent;//此處stage == null 無法使用
		
		public function AsName() {
			
			//new VarsSent(); 參數為指定偵聽方
			VS = new VarsSent(stage);
		}
		
		
		
		
		//====================================子遊戲須備功能=====================================
		
		public function Pause():void{
			//各製作自行設定暫停遊戲之功能，可由主程式調用。
	
			//遊戲滑入功能列表、再看說明時，需停止時間，道具移動、播放等狀態，視各遊戲狀態而設定暫停功能。
		}
		public function Continute():void{
			//各製作自行設定繼續遊戲之功能，可由主程式調用。
	
			//遊戲滑出功能列表、看完說明時，需繼續時間，道具移動、播放等狀態，視各遊戲狀態而設定繼續功能。
		}
		public function Clear():void{
			//各製作自行設定移除偵聽之功能，可由主程式調用。
	
			//為避免返回選單切換遊戲時，有音樂及Timer等偵聽未停止狀況。
			//請將所有啟用偵聽的移除偵聽放置在此。
			//並將所以使用到音效SoundChannel設定停止在此。
		}
		

		//====================================子物件須備功能=====================================
		
		
		
		//====================================VarsSent範例功能=====================================
		
		/*
		var tmpVar:String = VS.getValue();//子swf可直接取得值，單機測試固定回傳"0"
		var tmpVar:String = VS.getValue("abc");//abc為範例變數,主程式無指定變數則回傳"0"
		
		VS.send( "PASS" , "win");//遊戲勝利傳送
		VS.send( "PASS" , "lose");//遊戲失敗傳送
		VS.send( "PAUSE" , "false");//設定關閉暫停功能
		VS.send( "PAUSE" , "true");//設定開啟暫停功能
		VS.send( "SCORE" , "50");//當遊戲需要紀錄最高分數時使用
		VS.send( "PAUSE" , "false");//設定關閉暫停功能
		VS.send( "PAUSE" , "true");//設定開啟暫停功能
		
		VS.swfEnd();//不代參數由主程式控制流程，暫時都以此方式
		VS.swfEnd(this,"SwfName");//如果是由loader物件載入時，會取得this.parent的loader並刪除，載入SwfName.swf
		
		VS.back();//回主選單
		*/
		
		//====================================VarsSent範例功能=====================================
	}
}

