package  {
	
	import flash.display.MovieClip;
	
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
	
	import flash.sampler.NewObjectSample; // dùng cho addchild
	
	import flashx.textLayout.factory.StringTextLineFactory;
	
	//import red5.*;
	//import mx.core.FlexBitmap;
	public class Main1 extends MovieClip {
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
		
		public var tenMH:String;
		
		//SharedObject
		//public var so_ol:SharedObject;
		//public var so_name:String="OnlineList";
		public function Main1() {
			this.btn_dangnhap.addEventListener(MouseEvent.CLICK, ham_dangnhap)
			//this.ava1_btn.addEventListener(MouseEvent.CLICK, ham_ava1)
			//this.init();
			//stop();
		}
						
		// ham dang nhap
		public function ham_dangnhap (event: MouseEvent):void{
			
			trace(this.txt_inputten.text + " " + this.txt_inputmk.text);
			if(this.txt_inputten.text=="")
			{
				this.txt_inputten.text="Hay nhap username";
			} else {
				gotoAndStop(2);
				//var tendn= this.txt_inputten.text;
				//trace(tendn);
				//var a= tendn + "_mc";
				//trace (a)
				//var myavatar:a = new a();
				//addChild (myavatar);
			}
			
					
		}// end ham_dang nhap
		
	}// end movie clip
	
	
	
}//end package
