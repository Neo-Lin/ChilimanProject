package BillAre.ASBox{
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class DBBox extends Object{
		import BillAre.ASBox.PublicFunBox;
		
		import flash.data.SQLConnection;
		import flash.data.SQLResult;
		import flash.data.SQLStatement;
		import flash.events.SQLErrorEvent;
		import flash.events.SQLEvent;
		import flash.filesystem.File;
		
		import mx.collections.ArrayCollection;
		import mx.controls.Alert;
		import mx.formatters.DateFormatter;
		//====================================
		[Bindable]
		public var customer:Array;
		public var dbFile:File;
		public var conn:SQLConnection;
		//---
		public var UserID:String;
		public var Obj_DBOverFun:Object;
		//---
		public var MyPublicFun:PublicFunBox=new PublicFunBox();//自訂公用函式物件
		//---接收資料庫的DB資料存放
		[Bindable]
		public var AccountAddChoseBar_DBData:Array;
		[Bindable]
		public var Bill_DBData:Array;
		[Bindable]
		public var Bill_DBData_Sum:Array;
		[Bindable]
		public var Bill_ArrayCollectionData:ArrayCollection;
		[Bindable]
		public var Cless_DBData:Array;
		[Bindable]
		public var Cless_ArrayCollectionData:ArrayCollection;
		[Bindable]
		public var IOCless_DBData:Array;
		//====================================
		public function DBBox(DBOverFun:Object,getUserID:String,getDBWay:String){
			UserID=getUserID;
			Obj_DBOverFun=DBOverFun;
			//---
			//dbFile = File.applicationDirectory.resolvePath(getDBWay);
			//請怪凱回來
			dbFile =new File(File.documentsDirectory.resolvePath("users"+"/"+UserID+"/Bill.db").nativePath)
			conn = new SQLConnection();
			//---
			if(!chkDB(dbFile)){//無檔案
				conn.addEventListener(SQLEvent.OPEN,firstCreateTable);//建立資料表
			}else{//有檔案
				conn.addEventListener(SQLEvent.OPEN,startData);//連結資料表
			}
			conn.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);//錯誤動作
			conn.open(dbFile);
		}
		public function	firstCreateTable(e:SQLEvent):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			var TempText:String="CREATE TABLE IF NOT EXISTS AccountTable (AccountId INTEGER PRIMARY KEY AUTOINCREMENT,UserId CHAR,AccountName TEXT,SearchStartDate DATE,SearchEndDate DATE)";
			sql.text=TempText;
			sql.execute();
			TempText="CREATE TABLE IF NOT EXISTS InOutputTable (IOPutId INTEGER PRIMARY KEY AUTOINCREMENT,IOPName TEXT)";
			sql.text=TempText;
			sql.execute();
			TempText="CREATE TABLE IF NOT EXISTS ClessTable (ClessId INTEGER PRIMARY KEY AUTOINCREMENT,ClessName TEXT,IOPutId INTEGER)";
			sql.text=TempText;
			sql.execute();
			TempText="CREATE TABLE IF NOT EXISTS BillTable (BillId INTEGER PRIMARY KEY AUTOINCREMENT,AccountId INTEGER,ClessId INTEGER,IOId INTEGER,InputDate DATE,Money INTEGER,Note TEXT)";
			sql.text=TempText;
			sql.execute();
			//---
			TempText="INSERT INTO InOutputTable VALUES (NULL,'支出')";
			sql.text=TempText;
			sql.execute();
			TempText="INSERT INTO InOutputTable VALUES (NULL,'收入')";
			sql.text=TempText;
			sql.execute();
			/*TempText="INSERT INTO InOutputTable VALUES (NULL,'轉帳')";
			sql.text=TempText;
			sql.execute();*/
			//---新增基本帳戶
			var TempNowDate:Date=new Date();
			var TempDateText:String=MyPublicFun.dateToStr(TempNowDate);
			TempText="INSERT INTO AccountTable VALUES (NULL,'"+UserID+"','現金','"+TempDateText+"','"+TempDateText+"')";
			sql.text=TempText;
			sql.execute();
			//---新增基本類型
			TempText="INSERT INTO ClessTable VALUES (NULL,'食',1)";
			sql.text=TempText;
			sql.execute();
			TempText="INSERT INTO ClessTable VALUES (NULL,'衣',1)";
			sql.text=TempText;
			sql.execute();
			TempText="INSERT INTO ClessTable VALUES (NULL,'住',1)";
			sql.text=TempText;
			sql.execute();
			TempText="INSERT INTO ClessTable VALUES (NULL,'行',1)";
			sql.text=TempText;
			sql.execute();
			//Alert.show("基本資料庫建立完成!");
			Obj_DBOverFun();
		}
		//---擁有個人屬性 函式庫---
		public function	startData(e:SQLEvent):void{
			//作使用者判斷作
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,UserMsg_Dec);
			var TempText:String="SELECT * FROM AccountTable WHERE UserId='"+UserID+"'";
			sql.text=TempText;
			sql.execute();
		}
		public function UserMsg_Dec(e:SQLEvent):void{
			if(e.target.getResult().data==null){
				//---新增基本帳戶
				var sql:SQLStatement = new SQLStatement();
				sql.sqlConnection=conn;
				sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
				sql.addEventListener(SQLEvent.RESULT,UserMsg_Add);
				var TempNowDate:Date=new Date();
				var TempDateText:String=MyPublicFun.dateToStr(TempNowDate);
				var TempStartDate:Date=new Date();
				var TempStartDateText:String=MyPublicFun.dateToStr(TempStartDate);
				var TempText:String="INSERT INTO AccountTable VALUES (NULL,'"+UserID+"','現金','"+TempStartDateText+"','"+TempDateText+"')";
				sql.text=TempText;
				sql.execute();
			}else{
				Obj_DBOverFun();
			}
		}
		public function UserMsg_Add(e:SQLEvent):void{
			Alert.show("新增使用者完成!");
			Obj_DBOverFun();
		}
		//---Tempppppppppp------
		public function	TxtBack(funOverDo:Function):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,AccountMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempText:String="SELECT * FROM AccountTable WHERE UserId='"+UserID+"'";
			sql.text=TempText;
			sql.execute();
		}
		//---取得帳戶資料
		public function	getAccountData(funOverDo:Function):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,AccountMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			sql.text="SELECT * FROM AccountTable WHERE UserId='"+UserID+"'";
			sql.execute();
		}
		public function	AccountMsg_Slt(e:SQLEvent):void{//Alert.show("MsgBack:"+(e.target.getResult().data as Array)[0]['AccountName']);
			AccountAddChoseBar_DBData=e.target.getResult().data as Array;
		}
		//---取得收支類別資料
		public function	getInIOSet(funOverDo:Function):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,InIOMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempText:String="SELECT * FROM InOutputTable";
			sql.text=TempText;
			sql.execute();
		}
		public function	InIOMsg_Slt(e:SQLEvent):void{
			IOCless_DBData=e.target.getResult().data as Array;
		}
		//---取得類型資料
		public function	getClessSet(funOverDo:Function):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,ClessMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempText:String="SELECT * FROM ClessTable";
			sql.text=TempText;
			sql.execute();
		}
		public function	ClessMsg_Slt(e:SQLEvent):void{
			Cless_DBData=e.target.getResult().data as Array;
			Cless_ArrayCollectionData=new ArrayCollection();
			for(var i:Number=0;i<Cless_DBData.length;i++){
				//Alert.show(""+Cless_DBData[i].ClessId);
				Cless_ArrayCollectionData.addItem({
					ClessId:Cless_DBData[i].ClessId,
					ClessName:Cless_DBData[i].ClessName,
					IOPutId:Cless_DBData[i].IOPutId,
					Fun:dltClessData
				});
				Cless_ArrayCollectionData[i].IOPutId=IOCless_DBData[Cless_ArrayCollectionData[i].IOPutId-1].IOPName;
			}
		}
		public function	ClessMsg_Slt_GDB():void{
			Cless_ArrayCollectionData=new ArrayCollection();
			for(var i:Number=0;i<Cless_DBData.length;i++){
				//Alert.show(""+Cless_DBData[i].ClessId);
				Cless_ArrayCollectionData.addItem({
					ClessId:Cless_DBData[i].ClessId,
					ClessName:Cless_DBData[i].ClessName,
					IOPutId:Cless_DBData[i].IOPutId,
					Fun:dltClessData
				});
				Cless_ArrayCollectionData[i].IOPutId=IOCless_DBData[Cless_ArrayCollectionData[i].IOPutId-1].IOPName;
			}
		}
		public function	Temp(Str:String):void{
			Alert.show(Str);
		}
		//---新增類型資料
		public function	addClessData(funOverDo:Function,Name:String,IOID:Number):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			var TempText:String="INSERT INTO ClessTable VALUES (NULL,'"+Name+"',"+IOID+")";
			sql.text=TempText;//Alert.show(""+TempText);
			sql.execute();
			sql.addEventListener(SQLEvent.RESULT,ClessMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			TempText="SELECT * FROM ClessTable";
			sql.text=TempText;
			sql.execute();
		}
		//---更新類型資料
		public function	upClessData(funOverDo:Function,Name:String,IOID:Number,CID:Number):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			var TempText:String="UPDATE ClessTable SET ClessName='"+Name+"',IOPutId="+IOID+" WHERE ClessId="+CID;
			sql.text=TempText;
			sql.execute();
			sql.addEventListener(SQLEvent.RESULT,ClessMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			TempText="SELECT * FROM ClessTable";
			sql.text=TempText;
			sql.execute();
			//---
			var sql2:SQLStatement = new SQLStatement();
			sql2.sqlConnection=conn;
			sql2.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql2.addEventListener(SQLEvent.RESULT,funOverDo);
			sql2.text="UPDATE BillTable SET IOId="+IOID+" WHERE ClessId="+CID;
			sql2.execute();
		}//---刪除類型資料
		public function	dltClessData(funOverDo:Function,CID:Number):void{
			if(Cless_DBData.length==1){
				Alert.show("至少要擁有一個類別");
			}else{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			//sql.addEventListener(SQLEvent.RESULT,funOverDo);
			sql.text="DELETE FROM ClessTable WHERE ClessId="+CID;
			sql.execute();
			var sql2:SQLStatement = new SQLStatement();
			sql2.sqlConnection=conn;
			sql2.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql2.text="DELETE FROM BillTable WHERE ClessId="+CID;
			//Alert.show(""+CID);
			//sql2.addEventListener(SQLEvent.RESULT,funOverDo);
			sql2.execute();
			sql2.addEventListener(SQLEvent.RESULT,funOverDo);
			sql.addEventListener(SQLEvent.RESULT,ClessMsg_Slt);
			
			//---
			sql.text="SELECT * FROM ClessTable";
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			sql.execute();
			}
		}
		
		//---新增帳戶資料
		public function	addAccountData(funOverDo:Function,AName:String):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			var TempNowDate:Date=new Date();
			var TempDateText:String=MyPublicFun.dateToStr(TempNowDate);
			var TempText:String="INSERT INTO AccountTable VALUES (NULL,'"+UserID+"','"+AName+"','"+TempDateText+"','"+TempDateText+"')";
			sql.text=TempText;
			sql.execute();
			sql.addEventListener(SQLEvent.RESULT,AccountMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			TempText="SELECT * FROM AccountTable WHERE UserId='"+UserID+"'";
			sql.text=TempText;
			sql.execute();
		}
		//---更新帳戶名稱資料
		public function	upNameAccountData(funOverDo:Function,GoalObj:Object,AID:Number,UpName:String):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,AccountMsg_UpName);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempText:String="UPDATE AccountTable SET AccountName='"+UpName+"' WHERE AccountId="+AID;
			sql.text=TempText;
			sql.execute();
			//---
			GoalObj.labelText=UpName;
			GoalObj.AccountBtn.labelDisplay.text=UpName;
		}
		public function	AccountMsg_UpName(e:SQLEvent):void{//Alert.show("MsgBack:"+(e.target.getResult().data as Array)[0]['AccountName']);
			//AccountAddChoseBar_DBData=e.target.getResult().data as Array;
		}
		//---更新帳戶日期資料
		public function	upDateAccountData(funOverDo:Function,AID:Number,SSDate:String,SEDate:String):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,AccountMsg_upDate);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempText:String="UPDATE AccountTable SET SearchStartDate='"+SSDate+"',SearchSEndDate='"+SEDate+"' WHERE AccountId="+AID;
			sql.text=TempText;
			sql.execute();
		}
		public function	AccountMsg_upDate(e:SQLEvent):void{//Alert.show("MsgBack:"+(e.target.getResult().data as Array)[0]['AccountName']);
			//AccountAddChoseBar_DBData=e.target.getResult().data as Array;
		}
		//---刪除帳戶帳單資料
		public function	dltAccountBillData(funOverDo:Function,AID:Number):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,BillMsg_DltBill);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempText:String="DELETE FROM BillTable WHERE AccountId="+AID;
			sql.text=TempText;
			sql.execute();
		}
		public function	BillMsg_DltBill(e:SQLEvent):void{//Alert.show("MsgBack:"+(e.target.getResult().data as Array)[0]['AccountName']);
			//AccountAddChoseBar_DBData=e.target.getResult().data as Array;
		}
		//---刪除帳戶資料
		public function	dltAccountData(funOverDo:Function,AID:Number):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,AccountMsg_Dlt);
			var TempText:String="DELETE FROM AccountTable WHERE AccountId="+AID;
			sql.text=TempText;
			sql.execute();
			sql.addEventListener(SQLEvent.RESULT,AccountMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			TempText="SELECT * FROM AccountTable WHERE UserId='"+UserID+"'";
			sql.text=TempText;
			sql.execute();
		}
		public function	AccountMsg_Dlt(e:SQLEvent):void{//Alert.show("MsgBack:"+(e.target.getResult().data as Array)[0]['AccountName']);
			//AccountAddChoseBar_DBData=e.target.getResult().data as Array;
		}
		//---取得帳單資料
		public function	getBillData(funOverDo:Function,Aid:Number,SSDate:String,SEDate:String):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,BillMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempText:String="SELECT * FROM BillTable WHERE AccountId="+Aid+" AND strftime('%Y-%m-%d',InputDate) >= '"+SSDate+"' AND strftime('%Y-%m-%d',InputDate) <= '"+SEDate+"' ORDER BY strftime('%Y-%m-%d',InputDate)";
			sql.text=TempText;
			sql.execute();
		}
		public function	BillMsg_Slt(e:SQLEvent):void{//取得資料回傳函式
			Bill_DBData=e.target.getResult().data as Array;//帳單資料放置
			BillDB_ReSeting();
		}
		//---取得帳單資料_給統計
		public function	getBillData_Sum(funOverDo:Function,Aid:Number,SSDate:String,SEDate:String):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,BillMsg_Slt_Sum);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempText:String="SELECT * FROM BillTable WHERE AccountId="+Aid+" AND strftime('%Y-%m-%d',InputDate) >= '"+SSDate+"' AND strftime('%Y-%m-%d',InputDate) <= '"+SEDate+"' ORDER BY strftime('%Y-%m-%d',InputDate)";
			sql.text=TempText;
			sql.execute();
		}
		public function	getBillData_AllAccount_Sum(funOverDo:Function,AidAry:Array,SSDate:String,SEDate:String):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			sql.addEventListener(SQLEvent.RESULT,BillMsg_Slt_Sum);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			var TempStr:String="(AccountId="+AidAry[0];
			for(var i:int=1;i<AidAry.length;i++){
				TempStr+=" OR AccountId="+AidAry[i];
			}
			TempStr+=")";
			sql.text="SELECT * FROM BillTable WHERE "+TempStr+" AND strftime('%Y-%m-%d',InputDate) >= '"+SSDate+"' AND strftime('%Y-%m-%d',InputDate) <= '"+SEDate+"' ORDER BY strftime('%Y-%m-%d',InputDate)";
			//Alert.show(sql.text);
			sql.execute();
		}
		public function	BillMsg_Slt_Sum(e:SQLEvent):void{//取得資料回傳函式
			var TempAry:Object=e.target.getResult().data;
			if( TempAry==null ){
				Bill_DBData_Sum=new Array();
			}else{
				Bill_DBData_Sum=TempAry as Array;//帳單資料放置
			}
		}
		//---刪除帳單選擇資料
		public function	dltBillSltData(funOverDo:Function,BIDAry:Array,Aid:Number,SSDate:String,SEDate:String):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			var TempDltBillId:String="";
			for(var i:Number=0;i<BIDAry.length;i++){
				if(i==BIDAry.length-1){
					TempDltBillId+=("BillId="+BIDAry[i]);
				}else{
					TempDltBillId+=("BillId="+BIDAry[i]+",");
				}
			}
			var TempText:String="DELETE FROM BillTable WHERE "+TempDltBillId;
			//Alert.show(TempText);
			sql.text=TempText;
			sql.execute();
			
			sql.addEventListener(SQLEvent.RESULT,BillMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			TempText ="SELECT * FROM BillTable WHERE AccountId="+Aid+" AND strftime('%Y-%m-%d',InputDate) >= '"+SSDate+"' AND strftime('%Y-%m-%d',InputDate) <= '"+SEDate+"' ORDER BY strftime('%Y-%m-%d',InputDate)";
			sql.text=TempText;
			sql.execute();
		}
		//---新增帳單資料
		public function	addBillData(funOverDo:Function,AID:Number,CID:Number,IOID:Number,InDate:String,Money:Number,Note:String,SSDate:String,SEDate:String){
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			var TempText:String="INSERT INTO BillTable VALUES (NULL,"+AID+","+CID+","+IOID+",'"+InDate+"',"+Money+",'"+Note+"')";
			sql.text=TempText;//Alert.show(""+TempText);
			sql.execute();
			sql.addEventListener(SQLEvent.RESULT,BillMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			TempText="SELECT * FROM BillTable WHERE AccountId="+AID+" AND strftime('%Y-%m-%d',InputDate) >= '"+SSDate+"' AND strftime('%Y-%m-%d',InputDate) <= '"+SEDate+"' ORDER BY strftime('%Y-%m-%d',InputDate)";
			sql.text=TempText;
			sql.execute();
		}
		//---更新帳單資料
		public function	upBillData(funOverDo:Function,BID:Number,AID:Number,CID:Number,IOID:Number,InDate:String,Money:Number,Note:String,SSDate:String,SEDate:String):void{
			var sql:SQLStatement = new SQLStatement();
			sql.sqlConnection=conn;
			sql.addEventListener(SQLErrorEvent.ERROR,dbErrorMsg);
			var TempText:String="UPDATE BillTable SET ClessId="+CID+",IOId="+(IOID-1)+",InputDate='"+InDate+"',Money="+Money+",Note='"+Note+"' WHERE BillId="+BID;
			sql.text=TempText;
			sql.execute();
			sql.addEventListener(SQLEvent.RESULT,BillMsg_Slt);
			sql.addEventListener(SQLEvent.RESULT,funOverDo);
			TempText="SELECT * FROM BillTable WHERE AccountId="+AID+" AND strftime('%Y-%m-%d',InputDate) >= '"+SSDate+"' AND strftime('%Y-%m-%d',InputDate) <= '"+SEDate+"' ORDER BY strftime('%Y-%m-%d',InputDate)";
			sql.text=TempText;
			sql.execute();
		}
		public function	BillMsg_up(e:SQLEvent):void{//Alert.show("MsgBack:"+(e.target.getResult().data as Array)[0]['AccountName']);
			//AccountAddChoseBar_DBData=e.target.getResult().data as Array;
		}
		//---共通屬性 函式庫----------------
		public function	BillDB_ReSeting():void{
			if(Bill_DBData!=null){//當資料不等於無
				/*Bill_ArrayCollectionData=new ArrayCollection(Bill_DBData);
				for(var i:Number=0;i<Bill_ArrayCollectionData.length;i++){
					var TDate:Date=Bill_ArrayCollectionData[i].InputDate;
					Bill_ArrayCollectionData[i].InputDate=TDate.getFullYear()+"/"+(TDate.getMonth()+1)+"/"+TDate.getDate();
					Bill_ArrayCollectionData[i].ClessId=Cless_DBData[Bill_ArrayCollectionData[i].ClessId-1].ClessName;
					Bill_ArrayCollectionData[i].IOId=IOCless_DBData[Bill_ArrayCollectionData[i].IOId-1].IOPName;
				}*/
				Bill_ArrayCollectionData=new ArrayCollection();
				for(var i:Number=0;i<Bill_DBData.length;i++){
					var TDate:Date=Bill_DBData[i].InputDate;
					var formatter:DateFormatter = new DateFormatter();
					formatter.formatString = "YYYY/MM/DD";
					var NoteCh:String="";
					var TempNoteAry:Array;
					var NoteLong:int=0;
					TempNoteAry=Bill_DBData[i].Note.split("");
					for(var j:Number=0;j<TempNoteAry.length;j++){
						if(TempNoteAry[j]>"z"&&TempNoteAry[j]>"Z"){
							NoteLong+=2;
						}else{
							NoteLong++;
						}
						if(NoteLong<102){
							NoteCh+=TempNoteAry[j];
						}else{
							break;
						}
					}
					Bill_ArrayCollectionData.addItem({
						BillId:Bill_DBData[i].BillId,
						AccountId:Bill_DBData[i].AccountId,
						ClessId:Bill_DBData[i].ClessId,
						IOId:Bill_DBData[i].IOId,
						InputDate:Bill_DBData[i].InputDate,
						Money:Bill_DBData[i].Money,
						Note:NoteCh,
						Fun:dltBillSltData,
						CID:0
					});
					Bill_ArrayCollectionData[i].InputDate=formatter.format(TDate);
					Bill_ArrayCollectionData[i].CID=ClessIDToGetListId(Cless_DBData,Bill_ArrayCollectionData[i].ClessId);
					Bill_ArrayCollectionData[i].ClessId=Cless_DBData[ClessIDToGetListId(Cless_DBData,Bill_ArrayCollectionData[i].ClessId)].ClessName;
					Bill_ArrayCollectionData[i].IOId=IOCless_DBData[Bill_ArrayCollectionData[i].IOId-1].IOPName;
				}
			}else{
				Bill_ArrayCollectionData=new ArrayCollection();
			}
		}
		public function	ClessIDToGetListId(AryObj:Object,Num:int):int{
			var BackNum=0;
			if(AryObj.length!=0){
				for(var i=0;i<AryObj.length;i++){
					if(Cless_DBData[i].ClessId==Num){
						BackNum=i;
						break;
					}
				}
			}
			return BackNum;
		}
		public function	dbErrorMsg(e:SQLErrorEvent):void{
			Alert.show("MsgError");
		}
		public function open():void{
			conn.open(dbFile);
		}
		public function close():void{
			conn.close();
		}
		private function chkDB(dbFile:File):Boolean{
			if(!dbFile.exists){
				
				var fs:FileStream = new FileStream();			
				fs.open(dbFile, FileMode.WRITE)
				fs.close();	
				return false;
			}
			return true;
		}

		//"SELECT * FROM config;";
		//ORDER BY sDate ASC
	}
}