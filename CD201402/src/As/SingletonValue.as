package As 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Neo
	 */
	public class SingletonValue 
	{
		private static var  _instance:SingletonValue;
		
		private var _testMode:Boolean = true;	//測試模式
		private var HP:uint = 100;
		private var _caseNum:uint = 4;		//目前進行案件0~3,4=無
		private var _unitNum:uint = 5;		//目前進行案件進度--0:INTO, 1:QEX, 2:Q, 3:GEX, 4:G, 5:EVENTS
		private var _caseArr:Array = [1, 1, 1, 1];		//案件狀態array [1,1,1,1] 未選1  進行中2  破案3  再玩一次4
		private var _allGameSwf:Array;
		private var _nowSiteName:String;	//目前所在場景,發出MainEvent.CHANGE_SITE事件時會在MainEvent.as裡改變這個值
		private var _beforeSiteName:String;	//換場景前的所在場景,發出MainEvent.CHANGE_SITE事件時會在MainEvent.as裡改變這個值
		
		public function SingletonValue(sSingleton:Singleton) 
		{
			if(sSingleton==null)throw new Error("請使用類別方法getInstance");
		   /*避免建構函式由外部建構
			 如果使用者從外部進行初始化會強制出錯!
		   */
		}
		
		public static function getInstance():SingletonValue{
		  if(SingletonValue._instance==null)
		  SingletonValue._instance=new SingletonValue(new Singleton());
		  /*如果A的類別屬性 _instance是null才會建構A物件
			如果沒有需要此實體，就不會產生此實體
			只有在需要時才會產生，這就稱為"拖延實體化"
		  */
		  return SingletonValue._instance;
		  /*當執行到return表示已經有了實體
			並將SingletonValue._instance當傳回值
		  */
		}
		
		public function get hp():uint {
			return HP;
		}
		
		public function set hp(_n:uint):void {
			HP = _n;
		}
		
		public function get caseNum():uint 
		{
			return _caseNum;
		}
		
		public function set caseNum(value:uint):void 
		{
			_caseNum = value;
		}
		
		public function get caseArr():Array 
		{
			return _caseArr;
		}
		
		public function set caseArr(value:Array):void 
		{
			_caseArr = value;
		}
		
		public function get allGameSwf():Array 
		{
			return _allGameSwf;
		}
		
		public function set allGameSwf(value:Array):void 
		{
			_allGameSwf = value;
		}
		
		public function get testMode():Boolean 
		{
			return _testMode;
		}
		
		public function set testMode(value:Boolean):void 
		{
			_testMode = value;
		}
		
		public function get unitNum():uint 
		{
			return _unitNum;
		}
		
		public function set unitNum(value:uint):void 
		{
			_unitNum = value;
		}
		
		public function get nowSiteName():String 
		{
			return _nowSiteName;
		}
		
		public function set nowSiteName(value:String):void 
		{
			_nowSiteName = value;
		}
		
		public function get beforeSiteName():String 
		{
			return _beforeSiteName;
		}
		
		public function set beforeSiteName(value:String):void 
		{
			_beforeSiteName = value;
		}
		
	}
}
class Singleton{}
//前面不寫存取方式的話~預設是internal