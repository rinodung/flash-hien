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
		//public var btn_vote:fl.controls.Button;
		
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
				
				this.icon_position = "-1";
				
				
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
				
				var users:Array=new Array();
				users=data["ol"] as Array;
				var arr_data:Array=new Array();
				
				var myavatar = null;
				
				// Empty Class room
				this.resetAllChair(users);
				// Set Old Chair
				this.setSetOldChair(users);
				// Set New Chair
				this.setNewChair(users);
					
			}
			
		}//end update_online_list	
		
		// Reset All Chair to empty room
		public function resetAllChair(users:Array): void {
			
			for(var c:String in this.chairArray){
				var tmpChair:Chair = this.chairArray[c];								
				
				tmpChair.id = 0;
				tmpChair.status = false;
				if(tmpChair.avatar) {
					this.removeChild(tmpChair.avatar);
					tmpChair.avatar = null;
				}
				
			
			}	
			
		}
		
		// Set Old Chair to empty room
		public function setSetOldChair(users:Array): void {			
		
			for(var i:String in users){
				
				//Anh xa client java red5 => client actionscript 3
				var user:Client=users[i] as Client;							
				if(user.client_icon_position != "-1"){
					this.setChairPosition(user);				
				}				
				
			} //end for
			
		}
		
		// Set New Chair to empty room
		public function setNewChair(users:Array): void {
			
			for(var i:String in users){
				
				//Anh xa client java red5 => client actionscript 3
				var user:Client=users[i] as Client;							
				if(user.client_icon_position == "-1"){
					this.setChairPosition(user);				
				}				
				
			} //end for
			
		}
		/**
		Tao so random tu max - min
		*/
		function randomRange(max:Number, min:Number = 0):Number	{
				return Math.random() * (max - min) + min;
		}
		
		
		// Set Chair
		public function setChairPosition(user:Client): MovieClip{
			var myavatar = null;
			if(user.client_icon_name=="ava1"){
					
					myavatar = new ava1_mc();									
			}
			else if (user.client_icon_name=="ava2"){
					myavatar = new ava2_mc();
			}
			else if (user.client_icon_name=="ava3"){
					myavatar = new ava3_mc();					
			}
			else{
					myavatar = new ava4_mc();					
			}
			
			var position = user.client_icon_position;
			var tmpChair:Chair = null;
			// Neu chua co vi tri
			if(position == "-1") {
				var newChairIndex: String = this.getEmptyChairIndex();
				if(newChairIndex != "-1") {
				   
				    tmpChair = this.chairArray[newChairIndex];
							
					myavatar.x =tmpChair.x;
					myavatar.y =tmpChair.y;
					tmpChair.id = user.client_cer;
					tmpChair.avatar = myavatar;
					this.addChild(myavatar);
					
					trace("Set new chair successfully: " + user.client_cer);
					
					if(user.client_cer == this.user_id) {
						this.notifyPosition(newChairIndex);
					}
				} else {
					trace("Set new chair failure: " + user.client_cer);
				}
				
			} else {
				// Da co vi tri
				tmpChair = this.chairArray[position];
							
				myavatar.x =tmpChair.x;
				myavatar.y =tmpChair.y;
				tmpChair.status = true;
				tmpChair.id = user.client_cer;
				tmpChair.avatar = myavatar;
				this.addChild(myavatar);
				trace("Set old chair successfully: " + user.client_cer);
			}			
			
			return myavatar;
		} // end setChairPorition
		
		// Get Empty Chair Index
		public function getEmptyChairIndex(): String {
			var result:String = "-1";
			for(var i:String in this.chairArray){
				if(this.chairArray[i].status == false) {
					return i;		
				}				
			}
			return result;
		}// end getEmptyChairIndex
		
		// Notify Position to Server 
		public function notifyPosition(newChairIndex:String): void{
			var scope:String="room" + this.room_id;
			var command:String="setPosition";
			var args:String = newChairIndex;
			var responder:Responder = new Responder(on_set_position_complete, on_set_position_fail);
			this.nc.call("sendCommand",responder,scope,command,this.user_id,args);
		}
		/*public function getChairAvatar(user_id:String): MovieClip {
			var result:MovieClip = null;
			for(var i:String in this.chairArray){
				
				
				if( this.chairArray[i].id == user_id) result = this.chairArray[i].myavatar;
			}
			
			return result;
		}*/
		
		private function on_set_position_complete(result:Object):void
		{
			
			trace("on_set_position_complete");
		}
		
		private function on_set_position_fail(result:Object):void
		{
			trace("on_set_position_fail");
		}
		
		public function receiveCommand(mesg:String):void
		{
			// This blank will fill by some code to occour some thing.
			
			var comArray:Array = mesg.split("-");
			trace("Commmad: " + comArray[0]);
			trace("Client cer:" + comArray[1]);
			var clientCer:String = comArray[1];
			var command:String = comArray[0];
			/*
			if(command == "accept")
			{
				if(clientCer == masv)
				{
					btn_vote.gotoAndStop(4);
					ns_voteback = new NetStream(nc);
					ns_voteback.addEventListener(NetStatusEvent.NET_STATUS, handleStreamStatus);
					ns_voteback.inBufferSeek = true;
					ns_voteback.attachAudio(mic);
					video_voteback.attachNetStream(ns_voteback);
					ns_voteback.publish(clientCer, "live");
					trace("Client has been publish stream: " + masv);
				}else
				{
					ns_voteback = new NetStream(nc);
					ns_voteback.addEventListener(NetStatusEvent.NET_STATUS, handleStreamStatus);
			//		ns_voteback.inBufferSeek = true;
					video_voteback.attachNetStream(ns_voteback);
					ns_voteback.play(clientCer, -1);
					trace("Client has been Subscribe stream: " + masv);
				}
			}
			
			if(command =="reject")
			{
				btn_vote.gotoAndStop(2);
				if(ns_voteback != null) {
					ns_voteback.close();
				}
				trace("All client has been remove stream");
			}
			
			if(command == "stopvote") {
				btn_vote.gotoAndStop(2);
				if(ns_voteback != null) {
					ns_voteback.close();
				}
				
				trace("Stop vote");
			}		
			*/
			if(command == "setPosition") {
				
				trace("Send Message: " + command);
			}		
			
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
			gotoAndStop(2);
			//this.btn_vote.addEventListener(MouseEvent.CLICK,btn_vote_click);
			this.btn_dangxuat.addEventListener(MouseEvent.CLICK, ham_dangxuat);
			
			connect();
					
		}// end ham_dang nhap
		
		// ham dang xuat
		public function ham_dangxuat (event: MouseEvent):void{
			this.nc.close();
			this.gotoAndStop(1);
		}
		//end ham_dang xuat
		
		// ham btn_vote_click
		/*public function btn_vote_click (event: MouseEvent):void{
			myavatar.gotoAndStop(2);
		}*/
		//end btn_vote_click
		
		// test
		function clickHandler (event:MouseEvent):void
		{
			trace("button clicked:", event.currentTarget.i)
		}
	}// end movie clip
	
	
	
}//end package
