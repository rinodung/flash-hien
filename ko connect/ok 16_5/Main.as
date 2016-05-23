package  {
	
	//import fl.controls.*;
	//import fl.controls.dataGridClasses.DataGridColumn;
	//import fl.data.DataProvider;
	//import fl.events.ListEvent;
	
	import flash.display.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.events.SyncEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.H264Level;
	import flash.media.H264Profile;
	import flash.media.H264VideoStreamSettings;
	import flash.media.ID3Info;
	import flash.media.Microphone;
	import flash.media.MicrophoneEnhancedMode;
	import flash.media.MicrophoneEnhancedOptions;
	import flash.media.SoundCodec;
	import flash.media.Video;
	import flash.net.*;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.geom.Rectangle; 
	import flash.geom.Point;
	//import flash.sampler.NewObjectSample; // dùng cho addchild
	
	import flashx.textLayout.factory.StringTextLineFactory;
	
	import red5.*;
	//import mx.core.FlexBitmap;
	public class Main extends MovieClip {
		public var nc:NetConnection;
		public var room_id:String;
		public var khoa:String;
		public var user_name:String;
		public var address_client:String;
		public var type_client:String;
		public var user_id:String;		
		public var input_host:String;
		public var username:String;
		public var password:String;
		public var tenhv:String;
		public var port:String;
		public var dem:int;
		public var icon_name: String;
		public var icon_position: String;
		public var tenMH:String;
		
		//SharedObject
		public var so_ol:SharedObject;
		public var so_name:String="OnlineList";
		
		// Chair Array
		public var chairArray: Array;
		public var avatarArray: Array;
		public function Main() {
			
			this.init();			
		}
		
		public function init():void {
			
			this.btn_dangnhap.addEventListener(MouseEvent.CLICK, ham_dangnhap);
			
			//REMOTECLASS
			
			registerClassAlias("org.red5.core.Client",Client);

			//NET CONNECTION
			nc = new NetConnection();			
			nc.client = { onBWDone: function():void{ trace("onBWDone") } };
			nc.addEventListener(NetStatusEvent.NET_STATUS , netStatus);
			loaderComplete();				
			
		}		
		
		public function netStatus(event:NetStatusEvent):void{
				switch(event.info.code)
				{
					case "NetConnection.Connect.Rejected":
						
						trace("Rejected");
						break;
					case "NetConnection.Connect.Success":
						trace("Success");
						break;
					case "NetConnection.Connect.Closed":
						
						trace("Closed");
						break;
					case "NetConnection.Call.Failed":
						trace("Failed");
						
						break;
					
				}//end switch
		}//end netstatus
		
		public function loaderComplete():void	{		
				// init chair array
				this.chairArray = [new Chair(457,393),
								   new Chair(627,393), 
								   new Chair(797,393), 
								   new Chair(240,488),
								   new Chair(424,488), 
								   new Chair(658,488), 
								   new Chair(852,488), 
								   new Chair(158,594), 
								   new Chair(380,594), 
								   new Chair(680,586), 
								   new Chair(904,591)];
				
				
		}//end loadcomplete
		
		
		public function connect(){
				trace("Connecting to: " + this.input_host + " " + this.user_name + " " + this.user_id + " " + this.icon_name);
				this.nc.connect(this.input_host, this.user_name, this.user_id, this.type_client, this.icon_name, this.icon_position);			
				
				//Register to ShareObject OnlineList Red5
				this.so_ol=SharedObject.getRemote(this.so_name,this.nc.uri,false);
				this.so_ol.client=this;
				this.so_ol.addEventListener(SyncEvent.SYNC,on_so_ol_sync);
				this.so_ol.connect(nc);
				
		}
		
		//ShareObject Synchronization Event Handler
		private function on_so_ol_sync(event:SyncEvent):void{
			if(event.target.data != null)
			{
				update_online_list(event.target.data);
			}
			
		}
		
		/*
		* Update Online Lilst Function
		*/
		public function update_online_list(data:Object):void
		{
			
			if(data["count"]!=null)	{
				
				var list_SV:Array=new Array();
				list_SV=data["ol"] as Array;
				var arr_data:Array=new Array();
				
				var myavatar = null;
				
				//Empty Class room
				this.resetAllChair(list_SV);
				
				//Set Chair Position
				for(var i:String in list_SV){
					var obj:Object = new Object();
					//Anh xa client java red5 => client actionscript 3
					var client:Client=list_SV[i] as Client;
					//define properties to the objects
					obj.id =client.client_id ;
					obj.name = client.name;
					obj.client_icon_name = client.client_icon_name;
					obj.client_icon_position = client.client_icon_position;
					obj.client_cer = client.client_cer;
					trace(obj.id + " " + obj.name + obj.client_icon_name + " " + obj.client_icon_position);
					this.setChairPosition(obj.client_icon_name, obj.client_cer);			
					
					
				}				
					
			}
			
		}//end update_online_list	
		
		public function resetAllChair(users:Array): void {
			
			for(var c:String in this.chairArray){
				var tmpChair:Chair = this.chairArray[c];
				var needReset:Boolean = true;
				for(var i:String in users){					
					if(tmpChair.id == users[i].client_cer) {
						needReset = false;
						
					}
				}
				if(needReset) {
					tmpChair.id = 0;
					tmpChair.status = false;
					if(tmpChair.avatar) {
						this.removeChild(tmpChair.avatar);
						tmpChair.avatar = null;
					}
				}
			
			}	
			
		}
		/**
		Tao so random tu max - min
		*/
		function randomRange(max:Number, min:Number = 0):Number	{
				return Math.random() * (max - min) + min;
		}
		
		//}//end netstatus*/
		
		public function setChairPosition(icon_name:String, id:Number =0): MovieClip{
			var myavatar = null;
			if(icon_name=="ava1"){
					//var a= icon_name + "_mc";
					//trace (a);
					myavatar = new ava1_mc();									
			}
			else if (icon_name=="ava2"){
					myavatar = new ava2_mc();
			}
			else if (icon_name=="ava3"){
					myavatar = new ava3_mc();					
			}
			else{
					myavatar = new ava4_mc();					
			}
			var iEmpty:Number = -1;
			//Set Chair Position
			for(var i:String in this.chairArray){
				var tmpChair:Chair = this.chairArray[i];
				
				var existUser:Boolean = false;
				// Neu co nguoi ngoi
				if(this.chairArray[i].status) {
					//
					if(this.chairArray[i].id != id) {
						continue;//kiem ghe khac
					} else {
						iEmpty = int(i);
						existUser = true;
						break;
					}
				} else {
						if(iEmpty == -1) {
							iEmpty = int(i);
							existUser = false;
						}
						
				}
				
			}	
			if(!existUser && iEmpty != -1) {
				myavatar.x =this.chairArray[iEmpty].x;
				myavatar.y =this.chairArray[iEmpty].y;
				this.chairArray[iEmpty].status = true;
				this.chairArray[iEmpty].id = id;
				this.chairArray[iEmpty].avatar = myavatar;
				this.addChild(myavatar);
			}
				
							
			
			return myavatar;
		}
		
		// ham dang nhap
		public function ham_dangnhap (event: MouseEvent):void{
			
			//....	
			this.room_id = "default";
			this.input_host = "rtmp://127.0.0.1:1935/firstapp/room"+ this.room_id;			
			
			this.user_id = randomRange(5000,2).toString(4);
			this.user_name = "Sinh vien " + this.user_id;
			this.type_client = "sv";
			this.icon_name = this.txt_inputten.text;
			//var tendn = this.txt_inputten.text;
			//var a= tendn.text + "_mc";
			//trace (tendn);
			//var myavatar = new ava1_mc();
			trace(this.txt_inputten.text + " " + this.txt_inputmk.text);
			/*if(this.txt_inputten.text=="")
			{
				this.txt_inputten.text="Hay nhap username";
			} else {
				gotoAndStop(2);				
				addChild (myavatar);
				
			}*/
			
			//var myavatar = new ava3_mc();
			//addChild (myavatar);
			//var myavatar = null;
			//myavatar = this.setChairPosition(this.txt_inputten.text);
			
			this.icon_position = "0,0";
			//this.addChild (myavatar);
			gotoAndStop(2);
			this.btn_dangxuat.addEventListener(MouseEvent.CLICK, ham_dangxuat);
			
			connect();
					
		}// end ham_dang nhap
		
		// ham dang xuat
		public function ham_dangxuat (event: MouseEvent):void{
			this.nc.close();
			this.gotoAndStop(1);
		}
		//end ham_dang xuat
		
		// test
		function clickHandler (event:MouseEvent):void
		{
			trace("button clicked:", event.currentTarget.i)
		}
	}// end movie clip
	
	
	
}//end package
