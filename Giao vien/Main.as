/*
	Read function instruction in the main file of phonghoca.
	The only difference is student application receiving stream and teacher application
	broastcast stream.
*/
package 
{
	import com.bit101.components.*;	
	import fl.controls.*;
	import fl.data.DataProvider;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.events.SyncEvent;
	import flash.events.TimerEvent;
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
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import flashx.textLayout.elements.BreakElement;
	
	import red5.*;

	public class Main extends MovieClip
	{

		public var nc:NetConnection;
		public var input_chat:fl.controls.TextInput;
		public var status_a:fl.controls.Label;
		public var total_ol:fl.controls.Label;
		public var room_info:fl.controls.Label;
		public var room_info1:fl.controls.Label;
		public var aCb:fl.controls.ComboBox;
		public var button:fl.controls.Button;
		public var btn_NetConnect:MovieClip;
		public var cbb_He:fl.controls.ComboBox;
		public var bigbell:MovieClip;
		private var tengv:String;
		private var lop:String;
		public var ta_chat:fl.controls.TextArea;
		
		// Video  var
		
	//	private var bmpds:ArrayCollection;
		
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

		//public var ol:TextArea;

		public var grid_online:DataGrid;
		public var textformat1:TextFormat;
		//info
		public var room_id:String;
		public var name_client:String;
		public var address_client:String;
		public var type_client:String;
		public var masv:String;
		public var lastmasv:String;
		public var input_host:String;
		public var he:String;
		public var arr_data:Array=new Array();
		public var detectrung:int = 0;


		//list



		public function Main()
		{
			//init();
			this.input_tengv = fl.controls.TextInput(this.getChildByName("input_tengv"));
			this.input_lop = fl.controls.TextInput(this.getChildByName("input_lop"));
			this.btn_login = fl.controls.Button(this.getChildByName("btn_login"));
//			this.cbb_He = fl.controls.ComboBox(this.getChildByName("cbb_He"));
			btn_login.addEventListener(MouseEvent.CLICK, btn_login_click);
			trace(input_tengv.text);
			stop();
			//connect();

		}
		private function init():void
		{
			//INIT
			h264Settings = new H264VideoStreamSettings();
			h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_4);
			options = new MicrophoneEnhancedOptions();
			options.mode = MicrophoneEnhancedMode.OFF;
			options.echoPath = 128;
			options.nonLinearProcessing = false;
			options.autoGain = false;
			lastmasv = "null";

			//this.input_host = fl.controls.TextInput(this.getChildByName("link"));
			this.input_chat = fl.controls.TextInput(this.getChildByName("input_chat"));

			this.status_a = fl.controls.Label(this.getChildByName("lbl_status"));
			this.total_ol = fl.controls.Label(this.getChildByName("lbl_total"));
			this.room_info = fl.controls.Label(this.getChildByName("lbl_room_info"));
			this.room_info1 = fl.controls.Label(this.getChildByName("lbl_room_info1"));
			this.btn_NetConnect = MovieClip(this.getChildByName("btn_NetConnect"));
			this.bigbell = MovieClip(this.getChildByName("bigbell"));
			this.bigbell.visible = false;

			this.ta_chat = fl.controls.TextArea(this.getChildByName("ta_chat"));
			//EVENT
			this.input_chat.addEventListener(KeyboardEvent.KEY_DOWN,input_chat_enter);

			this.btn_NetConnect.addEventListener(MouseEvent.CLICK,btn_connect_click);

			//REMOTECLASS;

			registerClassAlias("org.red5.core.Client",Client);

			//NET CONNECTION
			nc = new NetConnection();
			nc.client = { onBWDone: function():void{ trace("onBWDone") } };
			nc.addEventListener(NetStatusEvent
			.NET_STATUS , netStatus);


			var numCam:int = Camera.names.indexOf("XSplitBroadcaster",0);
			if (numCam != -1)
			{
				cam = Camera.getCamera(numCam.toString());
			}
			else
			{
				cam = Camera.getCamera();
			}

			cam.setMode(1000, 450, 15);
			cam.setQuality(0,90);

			mic = Microphone.getEnhancedMicrophone();

			mic.codec = SoundCodec.SPEEX;
			mic.framesPerPacket = 1;
			mic.setSilenceLevel(0, 2000);
			mic.gain = 50;
			mic.setLoopBack(false);
			mic.enhancedOptions = options;


			video_voteback = new Video(5,5);
			video_voteback.x = 15;
			video_voteback.y = 5;


			video_publish = new Video(800,360);
			video_publish.x = 9;
			video_publish.y = 100;

			addChild(video_publish);


			//Datagrid OnlineList
			
			this.grid_online = DataGrid(this.getChildByName("grid_online"));
			this.grid_online.showHeaders = false;
			this.grid_online.columns = ["name","Action2"];
			this.grid_online.columns[0].width = 180;
			//this.grid_online.columns[1].width=180;

			Bell.main = this;
			this.grid_online.columns[1].cellRenderer = Bell;

			this.grid_online.rowHeight = 40;


			this.textformat1=new TextFormat();
			this.textformat1.size = 11;

			this.grid_online.setRendererStyle("textFormat",this.textformat1);

			loaderComplete();
		}
		public function loaderComplete():void
		{
			//get FlashVars Here
			var paras:Object = this.root.loaderInfo.parameters;
			var key:String;
			var value:String;

			for (key in paras)
			{
				value = String(paras[key]);


			}
			if (paras["room_id"] != null)
			{
				this.room_id = paras["room_id"];
			}
			else
			{
				//this.room_id = he;
				this.room_id = "default";
			}
			this.room_info.text +=  "\nPhòng: room_" + this.room_id + "\n";
			this.input_host = "rtmp://118.69.55.61:3935/firstapp/room" + room_id;
			this.input_host = "rtmp://127.0.0.1:1935/firstapp/room" + room_id;
			if (paras["address"] != null)
			{
				this.address_client = paras["address"];
			}
			else
			{
				this.address_client = "Address 1";

			}
			if (paras["name"] != null)
			{
				this.name_client = paras["name"];
			}
			else
			{
				this.name_client = tengv + "-" + lop;

			}
			
			this.masv = randomRange(5000,2).toString(4);
			trace(this.masv);
			type_client = "gv";
			connect();
		}//end loadcomplete
		private function connect()
		{
			var link:String = this.input_host;
			trace("Connecting to: " + this.input_host + " " + this.name_client + " " + this.masv);
			nc.connect(link,this.name_client,this.masv,this.type_client,"","");

			var so_name:String = "OnlineList";
			this.so_ol = SharedObject.getRemote(so_name,nc.uri,false);
			this.so_ol.client = this;
			this.so_ol.addEventListener(SyncEvent.SYNC,on_so_ol_sync);
			this.so_ol.connect(nc);

			var room:String = "room" + this.room_id;
			var responder:Responder = new Responder(on_getOldMessage_Complete,on_getOldMessage_fail);
			this.nc.call("getOldMessage",responder,room);
		}

		private function btn_connect_click(event:MouseEvent):void
		{
			//var tempt:Button=Button(event.currentTarget);
			if (btn_NetConnect.currentFrame == 1)
			{
				trace("Connect");
				connect();
			}
			else
			{
				nc.close();
				trace("disconnect");
			}
		}
		private function input_chat_enter(event:KeyboardEvent):void
		{
			if (event.charCode == 13)
			{

				//var room_name:String="room"+this.room_id;
				var scope:String = "room" + this.room_id;
				var message:String = this.name_client.split("-")[0] + ": " + this.input_chat.text;
				if (message!=""&&this.nc.connected==true)
				{
					var responder:Responder = new Responder(on_btn_connect_Complete,on_btn_connect_fail);
					this.nc.call("sendMessage",null,scope,message);
				}
				this.input_chat.text = "";
			}
		}//end input_chat_enter

		private function publishVideo():void
		{
			ns_publish = new NetStream(nc);
			ns_publish.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			ns_publish.attachCamera(cam);
			ns_publish.attachAudio(mic);
			ns_publish.videoStreamSettings = h264Settings;
			ns_publish.publish(room_id, "live");

			trace();
		}

		private function on_btn_connect_Complete(result:Object):void
		{
			this.ta_chat.appendText(result.toString());
		}
		private function on_btn_connect_fail(result:Object):void
		{
			this.ta_chat.appendText(result.toString());
		}
		//get old message chat in room;
		private function on_getOldMessage_Complete(result:Object):void
		{
			if (result.toString() != "")
			{
				this.ta_chat.text = result.toString();
				this.ta_chat.verticalScrollPosition = this.ta_chat.maxVerticalScrollPosition;

			}
		}
		function randomRange(max:Number, min:Number = 0):Number
		{
			return Math.random() * (max - min) + min;
		}
		private function on_getOldMessage_fail(result:Object):void
		{
			this.ta_chat.appendText(result.toString());
		}

		public function receiveMessage(mesg:String):void
		{
			this.ta_chat.appendText(mesg+"\n");
			this.ta_chat.verticalScrollPosition = this.ta_chat.maxVerticalScrollPosition;
		}


		private function on_so_ol_sync(event:SyncEvent):void
		{
			if (event.changeList[0].code == "clear")
			{
				switch (event.changeList[1].code)
				{
					case "success" :
						update_online_list(event.target.data);
						break;
					case "change" :
						update_online_list(event.target.data);
						break;
				}
			}
			else
			{
				switch (event.changeList[1].code)
				{
					case "success" :
						update_online_list(event.target.data);
						break;
					case "change" :
						update_online_list(event.target.data);
						break;
				}
			}

		}


		private function update_online_list(data:Object):void
		{
			this.room_info.text = "Giảng viên chưa vào phòng";
			var rung:int = 0;
			if (data["count"] != null)
			{
				this.total_ol.text = data["count"];
				var list_SV:Array=new Array();
				list_SV = data["ol"] as Array;
			//	var arr_dataTerm:Array=new Array();
				for (var i:String in list_SV)
				{
					var obj:Object = new Object();
					var client:Client = list_SV[i] as Client;
					//define properties to the objects
					obj.id = client.client_id;
					obj.masv = client.getclient_cer();
					obj.name = client.name;
					obj.address = client.address;
					obj.bell_status = client.vote_status;
					if (client.getclient_type() == "gv")
					{
						this.room_info.text = "Giảng viên: " + client.getname().split("-")[0];
						this.room_info1.text = "Lớp: " + client.getname().split("-")[1];
						this.total_ol.text = (parse(data["count"]) - 1).toString();
					}
					else if (checkHave(arr_data,client))
					{
						if (client.vote_status == 3)
						{
							if (checkchangestate(arr_data,client))
							{
								arr_data[searchpos(arr_data,client)].bell_status = 3;
							}else
							{
								// Moi them
							//	arr_data[searchpos(arr_data,client)].bell_status = 1;
							}
						}
						if (client.vote_status == 2)
						{	
							if (checkchangestate(arr_data,client))
							{
								if (checktalk(arr_data)== true && detectrung == 1)
								{
									arr_data[searchpos(arr_data,client)].bell_status = 2;
								}
								else
								{
									//trace(arr_data.indexOf(obj).toString());
									arr_data.splice(searchpos(arr_data,client),1);
									arr_data.unshift(obj);
								}
							}
							rung = 1;
							detectrung=1;
							if (bigbell.currentFrame == 1)
							{
								bigbell.visible = true;
								bigbell.gotoAndStop(2);
							}
						}
						if (client.vote_status == 1)
						{
							if (checkchangestate(arr_data,client))
							{
								arr_data[searchpos(arr_data,client)].bell_status = 1;
							}
						}
					}
					else
					{
						obj.bell_status = 1;
						arr_data.push(obj);
		//				arr_dataTerm.push(obj);
					}
				}
				if (rung == 0)
				{
					detectrung=0;
					if (bigbell.currentFrame == 2)
					{
						bigbell.gotoAndStop(1);
						bigbell.visible = false;
					}
				}
				//define properties to the objects
				if(arr_data.length != 0){
					for (var a:int =0; a< arr_data.length; a++)
					{
						var cl:int = arr_data[a].id;
						if(searchpos1(list_SV,cl)== -1)
						{
							arr_data.splice(searchpos2(arr_data,cl),1);
						}
					}
				}
				trace(arr_data);
				this.grid_online.dataProvider = new DataProvider(arr_data);
				//this.grid_online.showHeaders = false;
			}
		}//end update_online_list
		private function checkchangestate(array:Array,obj:Client):Boolean
		{
			for (var i:String in array)
			{
				if (array[i].masv == obj.getclient_cer())
				{
					if (array[i].bell_status != obj.getVote_status())
					{
						return true;
					}
					else
					{
						return false;
					}
				}
			}
			return false;
		}
		private function removeClientOutut(newlistsv:Array, oldlistsv:Array):void
		{
			for(var a:String in oldlistsv)
			{
				var cl:Client = oldlistsv[a] as Client;
				if(searchpos(newlistsv,cl)== -1)
				{
					oldlistsv.splice(searchpos(oldlistsv,cl),1);
				}
			}
		}
		private function searchpos(array:Array,obj:Client):int
		{
			var j:int = 0;
			for (var i:String in array)
			{
				if (array[i].masv == obj.getclient_cer())
				{
					return j;
				}
				j++;
			}
			return -1;
		}
		private function searchpos1(array:Array,obj:int):int
		{
			var j:int = 0;
			for (var i:String in array)
			{
				if (array[i].client_id == obj)
				{
					return j;
				}
				j++;
			}
			return -1;
		}
		private function searchpos2(array:Array,obj:int):int
		{
			var j:int = 0;
			for (var i:int =0; i< array.length; i++)
			{
				if (array[i].id == obj)
				{
					return j;
				}
				j++;
			}
			return -1;
		}
		private function checktalk(array:Array):Boolean
		{
			for (var i:String in array)
			{
				if (array[i].bell_status == 3)
				{
					return true;
				}
			}
			return false;
		}

		private function checkHave(array:Array,obj:Client):Boolean
		{
			for (var i:String in array)
			{
				if (array[i].masv == obj.getclient_cer())
				{
					return true;
				}
			}
			return false;
		}
		private function netStatus(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case "NetConnection.Connect.Rejected" :
					btn_NetConnect.gotoAndStop(1);
					this.status_a.text = "Rejected";
					break;
				case "NetConnection.Connect.Success" :
					//playbackVideo();
					publishVideo();
					video_publish.attachCamera(cam);
					//video_publish.attachNetStream(ns_publish);
					this.status_a.text = this.name + " Connected ";
					btn_NetConnect.gotoAndStop(2);
					break;
				case "NetConnection.Connect.Closed" :

					this.status_a.text = "Closed";
					//this.result.text="";

					this.ta_chat.text = "";
					this.total_ol.text = "";
					btn_NetConnect.gotoAndStop(1);
					break;
				case "NetConnection.Call.Failed" :

					this.status_a.text = "Call Fail";
					btn_NetConnect.gotoAndStop(1);
					break;

			}//end switch
		}//end netstatus
		private function handleStreamStatus(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case 'NetStream.Buffer.Empty' :
					trace("Video Netstream Buffer Empty");
					break;
				case 'NetStream.Buffer.Full' :
					trace("Video Netstream Buffer Full");
					break;
				case 'NetStream.Buffer.Flush' :
					trace("Video Netstream Buffer Flushed!!!!");
					break;
			}
		}
		function parse(str:String):Number
		{
			for (var i = 0; i < str.length; i++)
			{
				var c:String = str.charAt(i);
				if (c != "0")
				{
					break;
				}
			}

			return Number(str.substr(i));
		}
		private function on_btn_vote_Complete(result:Object):void
		{
			trace("Accept Complete");
		}
		private function on_btn_vote_fail(result:Object):void
		{
			trace("Accept False");
		}

		public function demofunction(currenMasv:String):void
		{
			trace("last massv"+ lastmasv);
			if (lastmasv!="null")
			{
				closeStreamClient(lastmasv);
			}
			var scope:String = "room" + this.room_id;
			var message:String = "accept";
			if (message!=""&&this.nc.connected==true)
			{
				var responder:Responder = new Responder(on_btn_vote_Complete,on_btn_vote_fail);
				this.nc.call("sendCommand",responder,scope,message, currenMasv);
			}
			//mic.gain = 0;
			trace("Accept Client vote");
			lastmasv = currenMasv;
		}
		public function closeStreamClient(currenMasv:String):void
		{
			var scope:String = "room" + this.room_id;
			var message:String = "reject";
			if (message!=""&&this.nc.connected==true)
			{
				var responder:Responder = new Responder(on_btn_vote_Complete,on_btn_vote_fail);
				this.nc.call("sendCommand",responder,scope,message, currenMasv);
			}
			//mic.gain = 50;
			trace("Close all stream");
		}
		private function btn_login_click(event:MouseEvent):void
		{
			tengv = input_tengv.text;
			lop = input_lop.text;
			he = "b"
			gotoAndStop(2);
			init();
			trace(he);

		}
		public function receiveCommand(mesg:String):void
		{
			// This blank will fill by some code to occour some thing.
			trace(mesg);
			var comArray:Array = mesg.split("-");
			trace("Commmad: " + comArray[0]);
			trace("Client cer:" + comArray[1]);
			var clientCer:String = comArray[1];
			var command:String = comArray[0];
			if (command == "accept")
			{

				ns_voteback = new NetStream(nc);
				ns_voteback.addEventListener(NetStatusEvent.NET_STATUS, handleStreamStatus);
				ns_voteback.inBufferSeek = true;
				video_voteback.attachNetStream(ns_voteback);
				ns_voteback.play(clientCer, -1);
				trace("Client has been Subscribe stream: " + masv);

			}
			if (command =="reject")
			{
				ns_voteback.close();
				trace("All client has been remove stream");
			}
			
			if(command == "stopvote") {
				bigbell.gotoAndStop(1);
				if(ns_voteback != null) {
					ns_voteback.close();
				}				
				trace("Stop vote");
			}			
		}

	}

}