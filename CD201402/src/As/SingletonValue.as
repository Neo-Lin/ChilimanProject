package As 
{
	/**
	 * ...
	 * @author Neo
	 */
	public class SingletonValue 
	{
		private static var  _instance:SingletonValue;
		
		private var HP:uint;
		private var _caseNum:uint;		//目前進行案件
		private var _caseArr:Array = [1,1,1,1];		//案件狀態array [1,1,1,1] 未選1  進行中2  破案3  再玩一次4
		
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
		
	}
}
class Singleton{}
//前面不寫存取方式的話~預設是internal