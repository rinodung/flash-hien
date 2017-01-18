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
	import flash.utils.Timer;
    
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
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import com.chang.motiontracker.CMotionTacker;
	
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
		private var ns_playback:NetStream;
		private var ns_voteback:NetStream;
		private var video_playback:Video;
		private var video_voteback:Video;
		private var mic:Microphone;
		private var cam:Camera;	
		//SharedObject
		public var so_ol:SharedObject;
		public var so_name:String="OnlineList";
		
		// Chair Array
		public var chairArray: Array;
		public var avatarArray: Array;
		public var avatarAction:Array;
		
		//global temp
		public var tmpAvatar:MovieClip;
		public var tmpIconAction:String;
		
		//Tracker Motion
		private var mt:CMotionTacker;
		
		private var v:Video;
		private var view:Bitmap;
		private var camX:int = 320;
		private var camY:int = 240;
		
		private var bound:Sprite = new Sprite();
		
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
		public static const AVATAR_EMPTY:int = 11; // empty
		
		public static const AVATAR_TIMEOUT_MAXIMUM:int = 6;
		public static const AVATAR_TIMEOUT_MINIMUM:int = 2;
		
		public static const DIFF_FRAME:int = 50;
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
						playbackVideo();
						trackerMotion();
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
				this.chairArray = [new Chair(320,462),
								   new Chair(420,462), 
								   new Chair(530,462), 
								   new Chair(660,462),
								   new Chair(760,455), 
								   new Chair(865,455), 
								   new Chair(150,550), 
								   new Chair(270,550), 
								   new Chair(395,550), 
								   new Chair(525,550)];
				
				this.icon_position = "-1";
				this.icon_action = Main.AVATAR_SMILE.toString();//default 4
				
				/*
				var numCam:int = Camera.names.indexOf("XSplitBroadcaster",0);
				if (numCam != -1)
				{
					cam = Camera.getCamera(numCam.toString());
				}
				else
				{
					cam = Camera.getCamera();
				}
	
				this.cam.setMode(50,50, 15);
				this.cam.setQuality(0,90);
				*/
				this.mic = Microphone.getMicrophone();
				
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
				
				var room:String="room"+this.room_id;
				var responder:Responder = new Responder(on_getOldMessage_Complete,on_getOldMessage_fail);
				this.nc.call("getOldMessage",responder,room);
				
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
			
			this.cua_so_chat.parent.setChildIndex( this.cua_so_chat, this.cua_so_chat.parent.numChildren - 1);
			
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
				
				// xu ly hinh anh
				this.setAvatarAction(user);
				
				// 4. user dang phat bieu 
				if(user.status == 3) {
					// Neu la minh
					if(user.client_cer == this.user_id){
						//-----add thêm mũi tên được ko
						this.ns_voteback = new NetStream(this.nc);
						this.ns_voteback.addEventListener(NetStatusEvent.NET_STATUS, handleStreamStatus);
						//this.ns_voteback.inBufferSeek = true;
						this.ns_voteback.attachAudio(mic);						
						//this.ns_voteback.attachCamera(cam);
						this.ns_voteback.publish(user.client_cer, "live");
						
						this.video_voteback.attachNetStream(ns_voteback);
						this.addChild(this.video_voteback);
						trace("Client has been publish stream: " + user.client_cer);
					}else { //neu khong la minh
						this.ns_voteback = new NetStream(this.nc);
						this.ns_voteback.addEventListener(NetStatusEvent.NET_STATUS, handleStreamStatus);
						//this.ns_voteback.inBufferSeek = true;						
						this.ns_voteback.play(user.client_cer, -1);						
						this.video_voteback.attachNetStream(ns_voteback);
						this.addChild(this.video_playback);
						trace("Client has been Subscribe stream: " + user.client_cer);
					}
					
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
			
			//neu ma empty
			if(user.status == Main.AVATAR_EMPTY ) {
				tmpChair.timer.stop();
			}else{
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
					//trace("avatar Action " + user.client_icon_name +" stop");
				} else {
					tmpChair.avatar.gotoAndStop(avatar_random_frame);
					//trace("avatar Action " + user.client_icon_name + " TimerHandler: " + iconAction + "=>setAvatarAction: " + avatar_random_frame);
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
					
					//trace("Set new chair successfully: " + user.client_cer);
					
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
				tmpChair.status = true;
				tmpChair.id = user.client_cer;
				tmpChair.avatar = avatar;
				this.addChild(avatar);
				//trace("Set old chair successfully: " + user.client_cer);
				if(user.client_cer == this.user_id) {
						
						this.updataAvatar(avatar);
						
				}
			}			
			
			return avatar;
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
		
		// Get Avatar Movie clip by user id
		public function getTimerByUserId(userId:String): Timer {
			var result:Timer= null;
			for(var i:String in this.chairArray){
				if(this.chairArray[i].id == userId) {
					return this.chairArray[i].timer;		
				}				
			}
			return result;
		}// end getEmptyChairIndex
		
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
		
		// Notify Position to Server 
		public function notifyPosition(newChairIndex:String): void{
			var scope:String="room" + this.room_id;
			var command:String="setPosition";
			var args:String = newChairIndex;
			var responder:Responder = new Responder(on_set_position_complete, on_set_position_fail);
			this.nc.call("sendCommand",responder,scope,command,this.user_id,args);
		}
		
		// Notify Status to Server 
		public function notifyStatus(status:String): void{
			var scope:String="room" + this.room_id;
			var command:String="setStatus";
			var args:String = status;
			var responder:Responder = new Responder(on_set_position_complete, on_set_position_fail);
			this.nc.call("sendCommand",responder,scope,command,this.user_id,args);
		}
		
		// Notify Status to Server 
		public function notifyAvatarAction(action:String): void{
			var scope:String="room" + this.room_id;
			var command:String="setAvatarAction";
			var args:String = action;
			var responder:Responder = new Responder(on_set_position_complete, on_set_position_fail);
			this.nc.call("sendCommand",responder,scope,command,this.user_id,args);
		}
		
		
		private function on_set_position_complete(result:Object):void
		{
			
			//trace("on_set_position_complete");
		}
		
		private function on_set_position_fail(result:Object):void
		{
			//trace("on_set_position_fail");
		}
		
		public function receiveCommand(mesg:String):void
		{
			// This blank will fill by some code to occour some thing.
			
			var comArray:Array = mesg.split("-");
			//trace("Commmad: " + comArray[0]);
			//trace("Client cer:" + comArray[1]);
			var clientCer:String = comArray[1];
			var command:String = comArray[0];
			
			if(command == "setPosition") {
				
				//trace("Send Message: " + command);
			}		
			
		}
		
		// ham dang nhap
		public function ham_dangnhap (event: MouseEvent):void{
			
			//....	
			this.room_id = "default";
			//Local
			this.input_host = "rtmp://127.0.0.1:1935/firstapp/room"+ this.room_id;			
			
			//citd remote, thay ip va port! 
			//this.input_host = "rtmp://118.55.69.51:4935/firstapp/room"+ this.room_id;		
			
			//citd local, thay ip va port! 
			//this.input_host = "rtmp://192.168.1.128:1935/firstapp/room"+ this.room_id;		
			
			this.user_id = randomRange(5000,2).toString(4);
			this.user_name = "Sinh vien " + this.user_id;
			this.type_client = "sv";
			this.icon_name = this.txt_inputten.text;
			
			//var avatar = new ava1_mc();
			trace(this.txt_inputten.text + " " + this.txt_inputmk.text);
			gotoAndStop(2);
			
			this.btn_chat.addEventListener(MouseEvent.CLICK, ham_hien_cs_chat);
			this.btn_chat.addEventListener(MouseEvent.ROLL_OVER,btn_over);
			this.btn_chat.addEventListener(MouseEvent.ROLL_OUT,btn_out);
			
			this.close_chat.addEventListener(MouseEvent.CLICK, ham_close_chat);
			this.btn_vote.addEventListener(MouseEvent.CLICK,btn_vote_click);
			
			//this.input_chat.addEventListener(KeyboardEvent.KEY_DOWN,input_chat_enter);
			this.cua_so_chat.btn_send.addEventListener(MouseEvent.CLICK,chat_button_send_click);
			this.cua_so_chat.btn_send.addEventListener(KeyboardEvent.KEY_DOWN,input_chat_enter);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, input_chat_enter);
			
			this.cua_so_chat.btn_send.addEventListener(MouseEvent.ROLL_OVER,btn_over);
			this.cua_so_chat.btn_send.addEventListener(MouseEvent.ROLL_OUT,btn_out);
			//this.btn_talk.addEventListener(MouseEvent.CLICK,btn_talk_click);
			//this.btn_shook.addEventListener(MouseEvent.CLICK,btn_shook_click);
			//this.btn_shook.addEventListener(MouseEvent.CLICK,btn_wink_click);
			this.btn_dangxuat.addEventListener(MouseEvent.CLICK, ham_dangxuat);
			this.cb_4.addEventListener(MouseEvent.CLICK, check_avatar_action);
			this.cb_5.addEventListener(MouseEvent.CLICK, check_avatar_action);
			this.cb_6.addEventListener(MouseEvent.CLICK, check_avatar_action);
			this.cb_7.addEventListener(MouseEvent.CLICK, check_avatar_action);
			this.cb_8.addEventListener(MouseEvent.CLICK, check_avatar_action);
			this.cb_9.addEventListener(MouseEvent.CLICK, check_avatar_action);
			this.cb_10.addEventListener(MouseEvent.CLICK, check_avatar_action);
			connect();
					
		}// end ham_dang nhap
		
		// ham dang xuat
		public function check_avatar_action (event: MouseEvent):void{
			this.icon_action = "";
			if(this.cb_4.selected) {
				this.icon_action+="4,";
			} 
			if(this.cb_5.selected) {
				this.icon_action+="5,";
			} 
			if(this.cb_6.selected) {
				this.icon_action+="6,";
			} 
			if(this.cb_7.selected) {
				this.icon_action+="7,";
			} 
			if(this.cb_8.selected) {
				this.icon_action+="8,";
			}
			if(this.cb_9.selected) {
				this.icon_action+="9,";
			}
			if(this.cb_10.selected) {
				this.icon_action+="10,";
			}
			
			if(this.icon_action == "") {
				this.icon_action = "4";
				this.cb_4.selected = true;
			} else {
				this.icon_action = this.icon_action.substr(0,this.icon_action.length-1);
			}
			this.notifyAvatarAction(this.icon_action);
			
		}
		
		// ham dang xuat
		public function ham_dangxuat (event: MouseEvent):void{
			this.nc.close();
			this.gotoAndStop(1);
		}
		//end ham_dang xuat
		
		//Ham hien cua so chat
		public function ham_hien_cs_chat (event: MouseEvent):void{
			cua_so_chat.visible=true;
			close_chat.visible=true;
			cua_so_chat.parent.setChildIndex( cua_so_chat, cua_so_chat.parent.numChildren - 1);
			stage.focus = this.cua_so_chat.input_chat;
			
		}
		
		//Ham close_chat
		public function ham_close_chat (event: MouseEvent):void{
			cua_so_chat.visible=false;
			close_chat.visible=false;
			//cua_so_chat.parent.setChildIndex( cua_so_chat, cua_so_chat.parent.numChildren - 1);
		}
		
	
		// ham btn_vote_click
		public function btn_vote_click (event: MouseEvent):void{
			var avatar:MovieClip = this.getAvatarByUserId(this.user_id);
			if(avatar == null) {
				return;
			}
			// 
			if(avatar.currentFrame != 2) {				
				this.notifyStatus("vote");
			} else {								
				this.notifyStatus("canvote");
			}			
		}
		
		
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
		
		private function playbackVideo():void
		{
			this.ns_playback = new NetStream(nc);
			this.ns_playback.addEventListener(NetStatusEvent.NET_STATUS, handleStreamStatus);
			
			this.video_playback = new Video(600,300);
			this.video_playback.x = 260;
			this.video_playback.y = 120;
			this.video_playback.attachNetStream(ns_playback);
			this.ns_playback.play(this.room_id, -1);
		
			this.addChild(video_playback);
		}
		
		private function input_chat_enter(event:KeyboardEvent):void
		{
			if(event.charCode == 13){
				
				// your code here
				var scope:String="room"+this.room_id;
				var message:String=this.user_name+": "+this.cua_so_chat.input_chat.text;
				if(message!=""&&this.nc.connected==true)
				{
					var responder:Responder = new Responder(on_send_message_complete, on_send_message_fail);
					this.nc.call("sendMessage",null,scope,message);	
				}
				this.cua_so_chat.input_chat.text="";
			}
		}
		
		public function receiveMessage(mesg:String):void
		{
			this.cua_so_chat.noidung_chat.appendText(mesg+"\n");
			this.cua_so_chat.noidung_chat.verticalScrollPosition=this.cua_so_chat.noidung_chat.maxVerticalScrollPosition;
			this.btn_chat.emphasized =true;
			
		}
		
		private function chat_button_send_click(event: MouseEvent):void
		{
			if(this.cua_so_chat.input_chat.text == "") return;
			// your code here
			var scope:String="room"+this.room_id;
			var message:String=this.user_name+": " + this.cua_so_chat.input_chat.text;
			if(message!=""&&this.nc.connected==true)
			{
				var responder:Responder = new Responder(on_send_message_complete, on_send_message_fail);
				this.nc.call("sendMessage",null,scope,message);	
			}
			this.cua_so_chat.input_chat.text="";
			
		}
		
		private function on_send_message_complete(result:Object):void
		{
			
			trace("on_send_message_complete");
		}
		
		private function on_send_message_fail(result:Object):void
		{
			trace("on_send_message_fail");
		}
		
		//get old message chat in room
		private function on_getOldMessage_Complete(result:Object):void
		{
			if(result.toString()!="") this.cua_so_chat.noidung_chat.text=result.toString();
			this.cua_so_chat.noidung_chat.verticalScrollPosition = this.cua_so_chat.noidung_chat.maxVerticalScrollPosition;
			
		}
		private function on_getOldMessage_fail(result:Object):void
		{
			this.cua_so_chat.noidung_chat.appendText(result.toString());
			
		}
		
		private function btn_over(me:MouseEvent)
		{
			Mouse.cursor="button";
		}
		private function btn_out(me:MouseEvent)
		{
			Mouse.cursor="auto";
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
		
		// Xu ly camera phát hiện rời khỏi màn hình
		public function trackerMotion():void 
		{			
			var c:Camera = Camera.getCamera();
			c.setMode(camX, camY, 30);
			
			v = new Video();
			v.attachCamera(c);
			v.x = v.y = 10;
	
			//addChild(v);
			
			// provide a video instance to CMotionTracker			
			mt = new CMotionTacker(v);
			
			// Draw a bitmap to see what actually is happening
			view = new Bitmap(new BitmapData(camX,camY));
			view.x = 10 + camX + 10;
			view.y = 10;
			
			//addChild(view);
			
			//addChild(bound);
			v.addEventListener(Event.EXIT_FRAME, trackerMotionLoop);
			
		}
		private function trackerMotionLoop(e:Event):void {
			var p:Point = new Point();
			
			// if there is motion
			if (mt.track()){
				
				p.x = mt.x + view.x;
				p.y = mt.y + view.y;			
				
				bound.graphics.clear();				
				bound.graphics.lineStyle(2, 0x0000ff);
				
				// CMotionTracker's bound property returns a rectangle containing the tracked area
				bound.graphics.drawRect(mt.bound.x + view.x, mt.bound.y, mt.bound.width, mt.bound.height);
				
				bound.graphics.lineStyle(2, 0x0000ff);				
				bound.graphics.drawCircle(p.x, p.y, 3);
				bound.graphics.lineStyle(2, 0xff0000);
				bound.graphics.drawCircle(p.x - view.x, p.y, 3);
				
				// Xu ly chinh o day
				var avatar:MovieClip = this.getAvatarByUserId(this.user_id);
					if(avatar == null) {
						return;
					}
				if(mt.x >= Main.DIFF_FRAME && mt.x <= view.width - Main.DIFF_FRAME &&
				   mt.y >= Main.DIFF_FRAME && mt.y <= view.height - Main.DIFF_FRAME) {
					
					if(avatar.currentFrame == Main.AVATAR_EMPTY) {				
						this.notifyStatus("normal");
						
						//avatar.gotoAndStop(Main.AVATAR_NORMAL);
						//trace("Sinh viên có mặt: " + mt.x + ":" + mt.y + " View: " + view.width +":" + view.height );
						
						// o ngoai di vo
						
					} 	
				} else {
					
					// o trong di ra
					if(avatar.currentFrame != Main.AVATAR_EMPTY) {				
						this.notifyStatus("empty");
						//avatar.gotoAndStop(Main.AVATAR_EMPTY);
						//trace("Sinh viên vắng mặt: " + mt.x + ":" + mt.y +  " View: " + view.width +":" + view.height );
					} 	
				}
				
			}
			
			// CMotionTracker's trackImage is the processed bitmapdata
			// show it in the view bitmap
			view.bitmapData = mt.trackImage;			
		}
	}// end movie clip
	
	
	
}//end package
