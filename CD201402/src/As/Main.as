package As
{
	import As.Events.MainEvent;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import net.hires.debug.Stats;
	
	/**
	 * ...
	 * @author Neo
	 */
	public class Main extends Sprite
	{
		private var EVENTS:Array = ["G01_EVENT.swf", "G02_EVENT.swf", "G03_EVENT.swf", "G04_EVENT.swf"];		//案發過程動畫(221B室按下案件按鈕時載入撥放)
		private var INTO:Array = ["G01_INTO.swf", "G02_INTO.swf", "G03_INTO.swf", "G04_INTO.swf"];				//子遊戲開場動畫
		private var QEX:Array = ["G01_Q_EX.swf", "G02_Q_EX.swf", "G03_Q_EX.swf", "G04_Q_EX.swf"];				//題庫說明動畫
		private var Q:Array =  ["G01_Q.swf", "G02_Q.swf", "G03_Q.swf", "G04_Q.swf"];							//題庫
		private var GEX:Array = ["G01_G_EX.swf", "G02_G_EX.swf", "G03_G_EX.swf", "G04_G_EX.swf"];				//遊戲說明動畫
		private var G:Array = ["G01.swf", "G02.swf", "G03.swf", "G04.swf"];										//遊戲
		private var allGameSwf:Array = [INTO, QEX, Q, GEX, G, EVENTS];
		private var myLoader:Loader = new Loader();
		private var myUrl:URLRequest = new URLRequest("221B_EX.swf");
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(new Stats());
			SingletonValue.getInstance().allGameSwf = allGameSwf;
			//以下之後需要改成讀取記錄檔======================================
			//設定一開始血量
			SingletonValue.getInstance().hp = 0;
			//設定一開始所有案件狀態
			//SingletonValue.getInstance().caseArr = [1, 1, 2, 1];
			//SingletonValue.getInstance().caseNum = 2;
			//======================================以上之後需要改成讀取記錄檔
			stage.addEventListener(MainEvent.CHANGE_SITE, ChangeSide);
			this.addChild(myLoader);
			LoadSwf();
		}
		
		//換場景
		private function ChangeSide(e:MainEvent):void
		{
			trace("Main: 換場景前: stage.numChildren=", stage.numChildren, "  ///  this.numChildren=" + this.numChildren);
			trace("Main: ", e.currentTarget, e.target);
			myUrl = new URLRequest(e.ChangeSiteName);
			
			myLoader.unloadAndStop();
			
			LoadSwf();
			trace("Main: 換場景後: stage.numChildren=", stage.numChildren, "  ///  this.numChildren=" + this.numChildren);
		}
		
		//載入swf
		private function LoadSwf():void
		{
			trace("Main: LoadSw載入前:", "stage.numChildren:" + stage.numChildren, "this.numChildren:" + this.numChildren);
			
			myLoader.load(myUrl);
			
			trace("Main: LoadSwf載入後:", "stage.numChildren:" + stage.numChildren, "this.numChildren:" + this.numChildren);
		}
	
	}

}