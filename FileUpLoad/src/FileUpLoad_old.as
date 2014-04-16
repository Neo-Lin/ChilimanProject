package 
{
    import FileUpLoad.*;
    import flash.display.*;
    import flash.events.*;
    import flash.external.*;
    import flash.net.*;

    public class FileUpLoad extends Sprite
    {
        private var debugEnabled:Boolean;
        private var fileBrowserMany:FileReferenceList;
        private var fileBrowserOne:FileReference = null;
        private var _ul_type:int;
        private var _ul_q:int;
        private var _ul_ex:String;
        private var _ul_size:int;
        private var _ul_:int = 1;
        private var _ul_url:String;
        private var _fileList:Object;
        private var _file:FileReference;

        public function FileUpLoad()
        {
            this.fileBrowserMany = new FileReferenceList();
            this._fileList = [];
            this.SetupExternalInterface();
            this._ul_type = root.loaderInfo.parameters.ul_type;
            this._ul_q = root.loaderInfo.parameters.ul_q;
            this._ul_ex = root.loaderInfo.parameters.ul_ex;
            this._ul_size = root.loaderInfo.parameters.ul_size;
            if (root.loaderInfo.parameters.ul_)
            {
                this._ul_ = root.loaderInfo.parameters.ul_;
            }
            if (root.loaderInfo.parameters.ul_url)
            {
                this._ul_url = root.loaderInfo.parameters.ul_url;
            }
            if (this._ul_type == 1)
            {
                stage.addEventListener(MouseEvent.CLICK, this.SelectFile);
            }
            else if (this._ul_type == 2)
            {
                stage.addEventListener(MouseEvent.CLICK, this.SelectFiles);
            }
            this.fileBrowserMany.addEventListener(Event.SELECT, this.Select_Many_Handler);
            this.fileBrowserMany.addEventListener(Event.CANCEL, this.DialogCancelled_Handler);
            return;
        }// end function

        private function SelectFiles(event:MouseEvent) : void
        {
            var e:* = event;
            try
            {
                this.fileBrowserMany.browse([new FileFilter("Image " + this._ul_ex, this._ul_ex)]);
            }
            catch (ex:Error)
            {
                this.Debug("Exception: " + ex.toString());
            }
            return;
        }// end function

        private function Select_Many_Handler(event:Event) : void
        {
            var _loc_2:int = 0;
            var _loc_3:FileReference = null;
            trace("Select_Many_Handler", this._ul_);
            this._fileList = event.currentTarget.fileList;
            if (ExternalInterface.available)
            {
                for each (_loc_3 in this._fileList)
                {
                    
                    _loc_2 = _loc_2 + 1;
                    ExternalInterface.call("ul_cb_select", _loc_2, _loc_3.name, _loc_3.size, "1");
                }
            }
            if (this._ul_ == 1)
            {
                this.load_Many();
            }
            return;
        }// end function

        private function load_Many() : void
        {
            var _loc_1:int = 0;
            var _loc_2:FileReference = null;
            for each (_loc_2 in this._fileList)
            {
                
                _loc_1 = _loc_1 + 1;
                trace(_loc_1, _loc_2.name, _loc_2.size);
                _loc_2.addEventListener(Event.OPEN, this.manyUpLoadStart);
                _loc_2.addEventListener(ProgressEvent.PROGRESS, this.manyUpLoading);
                _loc_2.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.manyUpLoadComplete);
                _loc_2.upload(new URLRequest(this._ul_url));
            }
            return;
        }// end function

        private function manyUpLoadStart(event:Event) : void
        {
            trace(event.currentTarget.name + " 開始上傳!!");
            return;
        }// end function

        private function manyUpLoading(event:ProgressEvent) : void
        {
            trace(event.currentTarget.name + " 上傳中....");
            if (ExternalInterface.available)
            {
                ExternalInterface.call("ul_cb_status", event.currentTarget.name, "1");
            }
            trace("已上傳:" + event.bytesLoaded, "總大小:" + event.bytesTotal, "進度:" + event.bytesLoaded / event.bytesTotal * 100);
            if (ExternalInterface.available)
            {
                ExternalInterface.call("ul_cb_kb", event.currentTarget.name, event.bytesLoaded / event.bytesTotal * 100);
            }
            return;
        }// end function

        private function manyUpLoadComplete(event:DataEvent) : void
        {
            trace(event.currentTarget.name + " 上傳完畢!!");
            if (ExternalInterface.available)
            {
                ExternalInterface.call("ul_cb_status", event.currentTarget.name, "2");
            }
            return;
        }// end function

        private function SelectFile(event:MouseEvent) : void
        {
            var e:* = event;
            this.fileBrowserOne = new FileReference();
            this.fileBrowserOne.addEventListener(Event.SELECT, this.Select_One_Handler);
            this.fileBrowserOne.addEventListener(Event.CANCEL, this.DialogCancelled_Handler);
            try
            {
                this.fileBrowserOne.browse([new FileFilter("Image " + this._ul_ex, this._ul_ex)]);
            }
            catch (ex:Error)
            {
                this.Debug("Exception: " + ex.toString());
            }
            return;
        }// end function

        private function Select_One_Handler(event:Event) : void
        {
            trace("Select_One_Handler");
            this._file = event.currentTarget as FileReference;
            if (ExternalInterface.available)
            {
                ExternalInterface.call("ul_cb_select", "1", this._file.name, this._file.size, "1");
            }
            if (this._ul_ == 1)
            {
                this.load_One();
            }
            return;
        }// end function

        private function load_One() : void
        {
            this._file.addEventListener(Event.OPEN, this.manyUpLoadStart);
            this._file.addEventListener(ProgressEvent.PROGRESS, this.manyUpLoading);
            this._file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, this.manyUpLoadComplete);
            this._file.upload(new URLRequest(this._ul_url));
            return;
        }// end function

        private function DialogCancelled_Handler(event:Event) : void
        {
            return;
        }// end function

        private function start_upload() : void
        {
            if (this._ul_type == 1)
            {
                this.load_One();
            }
            else if (this._ul_type == 2)
            {
                this.load_Many();
            }
            return;
        }// end function

        private function SetupExternalInterface() : void
        {
            try
            {
                ExternalInterface.addCallback("start_upload", this.start_upload);
            }
            catch (ex:Error)
            {
                this.Debug("Callbacks where not set: " + ex.message);
                return;
            }
            return;
        }// end function

        private function Debug(param1:String) : void
        {
            var lines:Array;
            var i:Number;
            var msg:* = param1;
            try
            {
                if (this.debugEnabled)
                {
                    lines = msg.split("\n");
                    i;
                    while (i < lines.length)
                    {
                        
                        lines[i] = "SWF DEBUG: " + lines[i];
                        i = (i + 1);
                    }
                }
            }
            catch (ex:Error)
            {
                trace(ex);
            }
            return;
        }// end function

    }
}
