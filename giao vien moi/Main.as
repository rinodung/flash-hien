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
		public var icon_action: String;
		public var tenMH:String;
		//public var btn_vote:fl.controls.Button;
		
		// Video  var
		private var video_publish:Video;
		private var video_voteback:Video;
		private var ns_voteback:NetStream;
		private var ns_publish:NetStream;
		private var cam:Camera;
		private var mic:Microphone;
		private var h264Settings:H264VideoStreamSettings;
		private var options:MicrophoneEnhancedOptions;
		//SharedObject
		public var so_ol:SharedObject;
		public var so_name:String="OnlineList";
		
		// Chair Array
		public var chairArray: Array;
		public var avatarArray: Array;		
		
		//Constant
		public static const AVATAR_NORMAL:int = 1; //bình thường
		public static const AVATAR_VOTE:int = 2; //phát biểu
		public static const AVATAR_TALK:int = 3; //nói
		public static const AVATAR_SMILE:int = 4; //cười
		public static const AVATAR_SAD:int = 5; //buồn
		public static const AVATAR_SHOOK_LEFT:int = 6; //lắc đầu qua trái
		public static const AVATAR_SHOOK_RIGHT:int = 7; //lắc đầu qua phải
		public static const AVATAR_NOD:int = 8; // gật đầu
		public static const AVATAR_YAWN:int = 9; // ngáp
		public static const AVATAR_SLEEP:int = 10; // ngủ
		public static const AVATAR_TIMEOUT_MAXIMUM:int = 6;
		public static const AVATAR_TIMEOUT_MINIMUM:int = 2;
		public function Main() {
			
			this.init();			
		}
		
		public function init():void {
			
			this.btn_dangnhap.addEventListener(MouseEvent.CLICK, ham_dangnhap);
			
			//REMOTECLASS
			
			registerClassAlias("org.red5.core.Client",Client);

			//NET CONNECTION
			this.nc = new NetConnection();			
			this.nc.client = { onBWDone: function():void{ trace("onBWDone") } };
			this.nc.addEventListener(NetStatusEvent.NET_STATUS , netStatus);
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
						this.publishVideo();
						this.video_publish.attachCamera(this.cam);
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
				this.chairArray = [new Chair(770,510),
								   new Chair(630,510), 
								   new Chair(480,510), 
								   new Chair(350,505),
								   new Chair(205,505), 
								   new Chair(60,505), 
								   new Chair(940,390), 
								   new Chair(800,385), 
								   new Chair(660,385), 
								   new Chair(510,390)]; 
								
				
				this.icon_position = "-1";
				this.icon_action = "4";
				h264Settings = new H264VideoStreamSettings();
				h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_4);
				options = new MicrophoneEnhancedOptions();
				options.mode = MicrophoneEnhancedMode.OFF;
				options.echoPath = 128;
				options.nonLinearProcessing = false;
				options.autoGain = false;
				
				var numCam:int = Camera.names.indexOf("XSplitBroadcaster",0);
				if (numCam != -1)
				{
					this.cam = Camera.getCamera(numCam.toString());
				}
				else
				{
					this.cam = Camera.getCamera();
				}
	
				this.cam.setMode(1000, 450, 15);
				this.cam.setQuality(0,90);
	
				this.mic = Microphone.getEnhancedMicrophone();
	
				this.mic.codec = SoundCodec.SPEEX;
				this.mic.framesPerPacket = 1;
				this.mic.setSilenceLevel(0, 2000);
				this.mic.gain = 50;
				this.mic.setLoopBack(false);
				this.mic.enhancedOptions = options;
				
				this.mic = Microphone.getMicrophone();
				
				this.video_publish = new Video(800,360);
				this.video_publish.x = 9;
				this.video_publish.y = 100;
	
				//this.addChild(this.video_publish);
				
				this.video_voteback = new Video(5,5);
				this.video_voteback.x = 10;
				this.video_voteback.y = 10;
				this.video_voteback.visible = false;
				
				
		}//end loadcomplete
		
		
		public function connect(){
				trace("Connecting to: " + this.input_host + " " + this.user_name + " " + this.user_id + " " + this.icon_name);
				this.nc.connect(this.input_host, this.user_name, this.user_id, this.type_client, this.icon_name, this.icon_position, this.icon_action);						
				
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
				
				var avatar = null;
				
				// Empty Class room
				this.resetAllChair(users);
				// Set Old Chair
				this.setSetOldChair(users);
				// Set New Chair
				this.setNewChair(users);
				
				// Set Status
				this.setStatus(users);
					
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
				if(user.client_icon_position != "-1" && user.client_type == "sv"){
					this.setChairPosition(user);				
				}				
				
			} //end for
			
		}
		
		// Set New Chair to empty room
		public function setNewChair(users:Array): void {
			
			for(var i:String in users){
				
				//Anh xa client java red5 => client actionscript 3
				var user:Client=users[i] as Client;							
				if(user.client_icon_position == "-1" && user.client_type == "sv"){
					this.setChairPosition(user);				
				}				
				
			} //end for
			
		}
		
		// Set Old Chair to empty room
		public function setStatus(users:Array): void {			
			var avatar: MovieClip;
			var user:Client;			
			for(var i:String in users){
				
				//Anh xa client java red5 => client actionscript 3
				user = users[i] as Client;	
				avatar = this.getAvatarByUserId(user.client_cer);
				if(avatar == null) continue;
				
				avatar.gotoAndStop(user.status);
				
				this.setAvatarAction(user);
				
				// 4. user dang phat bieu 
				if(user.status == 3) {
					// Neu la minh
					
						this.ns_voteback = new NetStream(this.nc);
						this.ns_voteback.addEventListener(NetStatusEvent.NET_STATUS, handleStreamStatus);
						//this.ns_voteback.inBufferSeek = true;						
						this.ns_voteback.play(user.client_cer, -1);						
						this.video_voteback.attachNetStream(ns_voteback);
						this.addChild(this.video_voteback);
						trace("Client has been Subscribe stream: " + user.client_cer);
					
					
				} else {
					if(this.ns_voteback != null) {
						this.ns_voteback.close();
					}
					
				}
				
			} //end for
			
		}
		
		//Set random Avatar for Flash
		function setAvatarAction(user:Client):void{		
			if(user.client_icon_position == "-1") return;
			
								
           	var tmpChair:Chair = this.chairArray[user.client_icon_position];			
			
			
			
			if(tmpChair.icon_action != user.client_icon_action) {				
				if(tmpChair.timer !=null) {					
					tmpChair.timer.stop();
				}
				var avatar_random_time: int = randomRange(Main.AVATAR_TIMEOUT_MAXIMUM, Main.AVATAR_TIMEOUT_MINIMUM) * 1000; // milisecond
				tmpChair.timer =  new Timer(avatar_random_time);				 
				tmpChair.icon_action = user.client_icon_action;
				trace("avatar Action Timer Random: " + avatar_random_time);
				tmpChair.timer.addEventListener(TimerEvent.TIMER, avatarActionTimerHandler(user, this.chairArray));
				
			}		
			//Neu ma gio tay, hoac la phat bieu
			if(user.status == Main.AVATAR_VOTE ) {
				tmpChair.timer.stop();
			} else if(user.status == Main.AVATAR_TALK) {
				this.stopAllChairTimer(user.client_cer);
			} else {
				tmpChair.timer.start();
			}
				
			
		}
		
		// Reset All Chair to empty room
		public function stopAllChairTimer(user_id:String): void {
			
			for(var c:String in this.chairArray){
				var tmpChair:Chair = this.chairArray[c];			
				if(tmpChair.timer ) {
					tmpChair.timer.stop();					
				}
				if(tmpChair.avatar && tmpChair.id != int(user_id)) {
					tmpChair.avatar.gotoAndStop(Main.AVATAR_NORMAL);
				}
			
			}	
			
		}
		
		function avatarActionTimerHandler(user:Client, chairArray:Array):Function {
			
			
			return function(e:TimerEvent):void {
				var iconAction:String = user.client_icon_action;						
				var tmpChair:Chair = chairArray[user.client_icon_position];
				var chairTimer:Timer = tmpChair.timer;
				
				
				var avatar_action_array: Array = iconAction.split(",");
				var avatar_random_index: int = Math.round(randomRange(avatar_action_array.length-1,0));
				var avatar_random_frame: Number = avatar_action_array[avatar_random_index];
				if(tmpChair.avatar == null) {
					tmpChair.timer.stop();
					trace("avatar Action " + user.client_icon_name +" stop");
				} else {
					tmpChair.avatar.gotoAndStop(avatar_random_frame);
					trace("avatar Action " + user.client_icon_name + " TimerHandler: " + iconAction + "=>setAvatarAction: " + avatar_random_frame);
				}
				
			};
		}
		
		/**
		Tao so random tu max - min
		*/
		function randomRange(max:Number, min:Number = 0):Number	{
				return Math.random() * (max - min) + min;
		}
		
		
		// Set Chair
		public function setChairPosition(user:Client): MovieClip{
			var avatar = null;
			/*if(user.client_icon_name=="ava1"){
					
					avatar = new ava1_mc();									
			}
			else if (user.client_icon_name=="ava2"){
					avatar = new ava2_mc();
			}
			else if (user.client_icon_name=="ava3"){
					avatar = new ava3_mc();					
			}
			else if (user.client_icon_name=="ava4"){ 
					avatar = new ava4_mc();					
			}
			else if (user.client_icon_name=="ava5") {
					avatar = new ava5_mc();					
			}
			else if (user.client_icon_name=="ava6"){
					avatar = new ava6_mc();					
			}
			else if (user.client_icon_name=="ava7"){ 
					avatar = new ava7_mc();					
			}
			else if (user.client_icon_name=="ava8") {
					avatar = new ava8_mc();					
			}
			else if (user.client_icon_name=="ava9") {
					avatar = new ava9_mc();					
			}
			else { 
					avatar = new ava10_mc();					
			}*/
			if(user.client_icon_name=="ava1"){
					
					avatar = new ava1_mc();									
			}
			else if (user.client_icon_name=="ava2"){
					avatar = new ava2_mc();
			}
			else if (user.client_icon_name=="ava3"){
					avatar = new ava3_mc();					
			}
			else{
					avatar = new ava4_mc();					
			}
			
			var position = user.client_icon_position;
			var tmpChair:Chair = null;
			// Neu chua co vi tri
			if(position == "-1") {
				var newChairIndex: String = this.getEmptyChairIndex();
				if(newChairIndex != "-1") {
				   
				    tmpChair = this.chairArray[newChairIndex];
							
					avatar.x =tmpChair.x;
					avatar.y =tmpChair.y;
					tmpChair.id = user.client_cer;
					tmpChair.avatar = avatar;
					this.addChild(avatar);
					
					trace("Set new chair successfully: " + user.client_cer);
					
					if(user.client_cer == this.user_id) {
						this.notifyPosition(newChairIndex);
						this.updataAvatar(avatar);
						
					}
				} else {
					trace("Set new chair failure: " + user.client_cer);
				}
				
			} else {
				// Da co vi tri
				tmpChair = this.chairArray[position];
							
				avatar.x =tmpChair.x;
				avatar.y =tmpChair.y;
				avatar.addEventListener(MouseEvent.CLICK, avatarClickHandler);
				avatar.user = user;
				tmpChair.status = true;
				tmpChair.id = user.client_cer;
				tmpChair.avatar = avatar;
				this.addChild(avatar);
				trace("Set old chair successfully: " + user.client_cer);
				if(user.client_cer == this.user_id) {
						
						this.updataAvatar(avatar);
						
				}
			}			
			
			return avatar;
		} // end setChairPorition
		
		function avatarClickHandler(event:MouseEvent):void {
			var currentUser:Client =  event.currentTarget.user;
			if(currentUser == null) return;
			
			var tmpChair:Chair = this.getChairByUserId(currentUser.client_cer);
			var avatar:MovieClip = this.getAvatarByUserId(currentUser.client_cer);
			if(avatar == null) {
				return;
			}
			// 
			if(avatar.currentFrame == Main.AVATAR_VOTE) {				
				this.notifyStatus("accept",currentUser.client_cer);
			} 			
			if(avatar.currentFrame == Main.AVATAR_TALK) {				
				this.notifyStatus("reject",currentUser.client_cer);
			} 
			trace("Click: " + currentUser.client_cer);
			
		}
		
		// Get chair  by user id
		public function getChairByUserId(userId:String): Chair {
			var result:Chair= null;
			for(var i:String in this.chairArray){
				if(this.chairArray[i].id == userId) {
					return this.chairArray[i];		
				}				
			}
			return result;
		}// end getEmptyChairIndex
		
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
		
		// Get Avatar Movie clip by user id
		public function getAvatarByUserId(userId:String): MovieClip {
			var result:MovieClip= null;
			for(var i:String in this.chairArray){
				if(this.chairArray[i].id == userId) {
					return this.chairArray[i].avatar;		
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
		
		// Notify Status to Server 
		public function notifyStatus(status:String, user_id:String): void{
			var scope:String="room" + this.room_id;
			var command:String="setStatus";
			var args:String = status;
			var responder:Responder = new Responder(on_set_position_complete, on_set_position_fail);
			this.nc.call("sendCommand",responder,scope,command,user_id,args);
		}
		
		
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
			this.user_name = "Giao Vien " + this.user_id;
			this.type_client = "gv";
			this.icon_name = this.txt_inputten.text;
			
			//var avatar = new ava1_mc();
			trace(this.txt_inputten.text + " " + this.txt_inputmk.text);
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
		
		
		// thay đổi trạng thái avatar (giơ tay)		
		public function updataAvatar(avatar:MovieClip): void{
			
			if(avatar.currentFrame == 1) {
				avatar.gotoAndStop(2);
			} else {
				avatar.gotoAndStop(1);
			}
		}
		
		// test
		function clickHandler (event:MouseEvent):void
		{
			trace("button clicked:", event.currentTarget.i)
		}
		private function publishVideo():void
		{
			this.ns_publish = new NetStream(this.nc);
			this.ns_publish.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			this.ns_publish.attachCamera(this.cam);
			this.ns_publish.attachAudio(this.mic);
			this.ns_publish.videoStreamSettings = h264Settings;
			this.ns_publish.publish(room_id, "live");			
		}
		
		
		
		private function handleStreamStatus(e:NetStatusEvent):void {
			switch(e.info.code) {
				case 'NetStream.Buffer.Empty':
					trace("Video Netstream Buffer Empty");
					break;
				case 'NetStream.Buffer.Full':
					trace("Video Netstream Buffer Full");
					break;
				case 'NetStream.Buffer.Flush':
					trace("Video Netstream Buffer Flushed!!!!");
					break;
			}
		}
	}// end movie clip
	
	
	
}//end package
