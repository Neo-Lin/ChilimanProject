package As.yu.display {
/*****************************************************************************************
		撰寫人員：CheinYu
		撰寫日期：20120828
		程式功能：巧連智 / 12月光碟 / 功能 / 搭配ChildEvent
		使用參數：Mc , sentValue 
		資　　料：Mc:			調用偵聽位置(必須)
				  sentValue:	變數暫存
		修改人員：
		修改日期：
		註　　解：
*****************************************************************************************/
/*===============================================================================================================================================================
VarsSent功能列表

//名稱							//參數											//回傳值						//註解
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
getValue						(ValueName:String = "")							:String							取得偵聽者的值
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
send							(dataName:String = "" , dataValue = null)		:String							將值傳遞給偵聽者
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
swfEnd							(Obj:MovieClip = null , swfName:String = "")	:void							告知偵聽者下一個呼叫下一流程
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
back							()												:void							告知偵聽者回主畫面

===============================================================================================================================================================*/
	
	import As.yu.events.ChildEvent;	
	import flash.display.MovieClip;
	
	public class VarsSent extends MovieClip{
		private var Mc;
		public var sentValue:String;
		//預設偵聽位置 呼叫者取得偵聽位置並代入
		public function VarsSent(pMc) {
			// constructor code
			if(pMc != null){
				//Mc=偵聽的物件,stage或者this.parent.parent皆可使用，但如有兩層以上loader要另行尋找相對路徑
				Mc = pMc;
			}
			super();
		}
		
		//取值
		public function getValue(ValueName:String = ""):String{
			sentValue = "";
			//呼叫偵聽的物件將值傳給this
			Mc.dispatchEvent(new ChildEvent(ChildEvent.GET_VALUE, this , ValueName ));
			//此時this.sentValue是由接收方傳過來的值
			return sentValue;
		}
		
		//傳值
		public function send( dataName:String, dataValue = null):String{
			if(dataName == "" ){
				//參數錯誤，沒有名稱!!
				Mc.dispatchEvent(new ChildEvent(ChildEvent.SAVE_ERROR , "error:noDataName"));
				
				return "error:noDataName"
			}
			if(dataValue == null || dataValue == "" ){
				//參數錯誤，沒有值!!
				Mc.dispatchEvent(new ChildEvent(ChildEvent.SAVE_ERROR , "error:noDataValue"));
				
				return "error:noDataValue"
			}
			//傳送值給Event物件
			Mc.dispatchEvent(new ChildEvent(ChildEvent.SAVE,dataName,dataValue));
			
			return "success";
		}
		
		//Swf結束時呼叫
		public function swfEnd(Obj:MovieClip = null , swfName:String = ""):void{
			if(Obj == null){
				//呼叫偵聽的物件進入下一流程
				Mc.dispatchEvent(new ChildEvent(ChildEvent.SWF_END));
			}else{
				//呼叫偵聽的物件進行以下流程 Obj=要刪除的loader,通常以呼叫的Swf代入this；dataName=要載入的Swf名稱 
				Mc.dispatchEvent(new ChildEvent(ChildEvent.SWF_END , Obj , swfName));
			}
		}
		
		//返回
		public function back():void{
			//呼叫偵聽的物件回到基本選單視窗
			Mc.dispatchEvent(new ChildEvent(ChildEvent.BACK));
		}
	}
	
}
