package BillAre.ASBox{
	import flash.utils.ByteArray;

	public class LinkETool{
		import flash.events.*;
		import flash.net.URLLoader;
		import flash.net.URLLoaderDataFormat;
		import flash.net.URLRequest;
		import flash.net.URLRequestMethod;
		
		import mx.collections.ArrayCollection;
		import mx.controls.Alert;
		
		private var token:String;
		private var OverDoFun:Object;
		private var SSD:String;
		private var SED:String;
		[Binable]
		public var LoadAry:Array;
		public var LoadKindAry:Array;
		public var ns:Namespace=new Namespace("soap","http://schemas.xmlsoap.org/soap/envelope/")
		public var newNs:Namespace=new Namespace(null,"https://msg.nat.gov.tw")
		public function LinkETool(Token:String,StartDate:String,EndDate:String,OverFun:Object){
			SSD=StartDate;
			SED=EndDate;
			OverDoFun=OverFun;
			token=Token;				
			LoadAry=new Array();
			getTagXml();

		}

		
		private function getTagXml():void{
			//
			var loader:URLLoader=new URLLoader();							
			var url:String="https://msg.nat.gov.tw/WSProxy/Emsg4Services.asmx"		
			var req:URLRequest=new URLRequest(url);
			
			var pra_xml:XML=							
				<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
				  <soap:Body>
					<GetExpenseTotal xmlns="https://msg.nat.gov.tw">
					  <token>{token}</token>
					  <client>t</client>
					  <datetimeStart>{SSD}</datetimeStart>
					  <dateEnd>{SED}</dateEnd>
					</GetExpenseTotal>
				  </soap:Body>
				</soap:Envelope>
			
			req.data=pra_xml
			req.method = URLRequestMethod.POST;			
			req.contentType = "text/xml"; 			
			loader.dataFormat=URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, eToogetTagCompleteHandler);			
			loader.load(req);
		}
		
		
		
		
		private function eToogetTagCompleteHandler(event:Event):void{
			var TempBA:ByteArray=event.target.data;
			var tag_xml:XML=new XML(TempBA.toString());
			//var array:Array = new Array(tag_xml);
			//tag_xml.Bills.BillInfo.Money

			//getObj.text=tag_xml.length();
			/*var bill_xlist:XMLList=tag_xml.ns::Body.newNs::GetExpenseTotalResponse.newNs::GetExpenseTotalResult.newNs::Bills.newNs::BillInfo;GroupInfos
			var i:int;
			var arr:Array=[]
			var bill_obj:Object;
			for(i=0;i<bill_xlist.length();i++){
				bill_obj={};
				//var title:String
				bill_obj.title=String(bill_xlist[i].newNs::Title)
				bill_obj.Money=String(bill_xlist[i].newNs::Money)
				bill_obj.DueDate=String(bill_xlist[i].newNs::DueDate)
				arr.push(bill_obj)
			}*/
			var bill_xlist:XMLList=tag_xml.ns::Body.newNs::GetExpenseTotalResponse.newNs::GetExpenseTotalResult.newNs::Bills.newNs::BillInfo;
			var allbill_xlist:XMLList=tag_xml.ns::Body.newNs::GetExpenseTotalResponse.newNs::GetExpenseTotalResult.newNs::GroupInfos.newNs::GroupExpenseInfo;
			var i:int;
			var Billarr:Array=[];
			var AllBillarr:Array=[];
			var bill_obj:Object;
			//判斷是否有值
			if(bill_xlist.length()>0){
				for(i=0;i<allbill_xlist.length();i++){
					AllBillarr.push({name:allbill_xlist[i].newNs::Name,money:"$ "+allbill_xlist[i].newNs::Money});
				}
				for(i=0;i<bill_xlist.length();i++){
					bill_obj={};
					bill_obj.title=String(bill_xlist[i].newNs::Title)
					bill_obj.Money=String(bill_xlist[i].newNs::Money)
					bill_obj.DueDate=String(bill_xlist[i].newNs::DueDate)
					//bill_obj.DueDate=bill_xlist[i].newNs::DueDate;
					Billarr.push(bill_obj);
				}
				LoadAry=Billarr;
				LoadKindAry=AllBillarr;
				/*var BillNameTxt:String="------------e管加帳單------------"+String.fromCharCode(10);
				var AllSumTxt:String=AllBillarr[0]+"類型總計:"+AllBillarr[1]+" 元"+String.fromCharCode(10)+"---------------------------------"+String.fromCharCode(10);
				var AnyBillTxt:String="";
				for(i=0;i<Billarr.length;i++){
					AnyBillTxt+=Billarr[i].DueDate+" "+Billarr[i].title+"費 : "+Billarr[i].Money+String.fromCharCode(10);
				}
				var AllText:String=BillNameTxt+AllSumTxt+AnyBillTxt+String.fromCharCode(10);*/
			}else{
				LoadAry=new Array();
				LoadKindAry=new Array();
			}
			OverDoFun();
		}	
	}
}