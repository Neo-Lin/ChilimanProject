package BillAre.ASBox{
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.Label;
	
	import spark.components.DropDownList;
	import spark.components.Label;

	public class PublicFunBox{
		//日期資料轉文字格式 xxxx-xx-xx
		public function dateToStr(TDate:Date):String{
			var TempYear:String = String(TDate.getFullYear());
			var TempMonth:String =String(((TDate.getMonth()+1)<10)?"0"+(TDate.getMonth()+1):(TDate.getMonth()+1));
			var TempDay:String = String(((TDate.getDate()<10)?"0"+TDate.getDate():TDate.getDate()));
			var TempDate:String = TempYear+'-'+TempMonth+'-'+TempDay;
			return TempDate;
		}
		//視窗關閉
		public function WindowClose(GoalObj:Object):void{GoalObj.close();}
		//陣列資料導入DropDownList_類型
		public function dataInputDropDownList_Cless(GoalObj:DropDownList,DataArray:Array):void{
			var TempAry:Array=new Array();
			var i:Number;
			for(i=0;i<DataArray.length;i++){
				TempAry.push( {label: DataArray[i].ClessName, data: DataArray[i].ClessId.toString()} );
			}
			GoalObj.dataProvider = new ArrayList(TempAry);
			if(GoalObj.selectedIndex==-1){
				GoalObj.selectedIndex=0;
			}else{
				var Temp:int=GoalObj.selectedIndex;
				GoalObj.selectedIndex=-1;
				GoalObj.selectedIndex=Temp;
			}
		}
		public function framClessGetIO(GoalObj:spark.components.Label,Num:int,IOClessAry:Array,ClessAry:Array):void{
			GoalObj.text=IOClessAry[ClessAry[Num].IOPutId-1].IOPName;
		}
		//陣列資料導入DropDownList_收支類型
		public function dataInputDropDownList_IOKind(GoalObj:DropDownList,DataArray:Array):void{
			var TempAry:Array=new Array();
			var i:Number;
			for(i=0;i<DataArray.length;i++){
				TempAry.push( {label: DataArray[i].IOPName, data: DataArray[i].IOPutId.toString()} );
			}
			GoalObj.dataProvider = new ArrayList(TempAry);
			if(GoalObj.selectedIndex==-1){
				GoalObj.selectedIndex=0;
			}else{
				var Temp:int=GoalObj.selectedIndex;
				GoalObj.selectedIndex=-1;
				GoalObj.selectedIndex=Temp;
			}
		}
		//
		//陣列資料導入DropDownList_帳戶
		public function dataInputDropDownList_Account(GoalObj:DropDownList,DataArray:Array):void{
			var TempAry:Array=new Array();
			var i:Number;
			TempAry.push( {label: "全部", data: "0"} );
			for(i=0;i<DataArray.length;i++){
				//Alert.show(DataArray[i].AccountId.toString());
				TempAry.push( {label: DataArray[i].AccountName, data: DataArray[i].AccountId.toString()} );
			}
			GoalObj.dataProvider = new ArrayList(TempAry);
			if(GoalObj.selectedIndex==-1){
				GoalObj.selectedIndex=0;
			}else{
				var Temp:int=GoalObj.selectedIndex;
				GoalObj.selectedIndex=-1;
				GoalObj.selectedIndex=Temp;
			}
		}
	}
}