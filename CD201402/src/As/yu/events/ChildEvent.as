package As.yu.events {
/*****************************************************************************************
		撰寫人員：CheinYu
		撰寫日期：20120828
		程式功能：巧連智 / 12月光碟 / 功能 / 呼叫偵聽者執行Function
		使用參數：p_type , p_Name , p_Value
		資　　料：p_type:	function代碼(必須)
				  p_Name:	指定資料名稱(非必須)
				  p_Value:	指定資料值(非必須)
		修改人員：
		修改日期：
		註　　解：
*****************************************************************************************/
	import flash.events.Event; 
	
	public class ChildEvent extends Event{
		
		public static const SAVE :String = "save";//傳值
		public static const SAVE_ERROR :String = "saveError";//傳值錯誤
		public static const BACK :String = "back";//回主畫面
		public static const GET_VALUE :String = "getValue";//給值
		public static const SWF_END :String = "swfEnd";//調用下一流程
		
		public var dataName:String;
		public var dataValue:String;
		public var ErrorType:String;
		public var Obj;
		
		public function ChildEvent(p_type:String , p_Name = null , p_Value = null) {
			super( p_type );
			switch(p_type){
				case "save":
					//在Save : p_Name當成變數名稱使用 , p_Value當成變數的值使用
					this.dataName = p_Name.toUpperCase();
					this.dataValue = p_Value.toUpperCase();
					this.ErrorType = "";
					this.Obj = null;
					break;
				case "saveError":
					//在saveError : p_Name當成錯誤訊息
					this.dataName = "";
					this.dataValue = "";
					this.ErrorType = p_Name;
					this.Obj = null;
					break;
				case "back":
					this.dataName = "";
					this.dataValue = "";
					this.ErrorType = "";
					this.Obj = null;
					break;
				case "getValue":
					//在GetValue : p_Name當成VarsSent物件使用 , p_Value當成變數名稱使用
					this.dataName = p_Value;
					this.dataValue = "";
					this.ErrorType = "";
					this.Obj = p_Name;
					break;
				case "swfEnd":
					//在swfEnd : p_Name當成Loader物件使用 , p_Value當成下一個Swf的名稱使用
					if(p_Value != null && p_Value != ""){
						if(p_Value.toLowerCase().substr(-4) == ".swf"){
							//有.swf副檔名
							this.dataName = p_Value;//下一個載入的swf名稱，要被載入使用
						}else{
							//沒有.swf副檔名
							this.dataName = p_Value + ".swf";//下一個載入的swf名稱，要被載入使用
						}
					}else{
						this.dataName = "";
					}
					
					this.dataValue = "";
					this.ErrorType = "";
					if(p_Name != null){
						if(p_Name.parent == "[object Loader]"){
							this.Obj = p_Name.parent;//取得loader，要被刪除使用
						}else{
							this.Obj = p_Name;//上一層不是Loader，那要怎辦．．．
						}
					}else{
						this.Obj = null;
					}
					
					break;
				default:
					//this.dataName = null;
					//this.dataValue = null;
					break;
			}
			
		}

	}
	
}
