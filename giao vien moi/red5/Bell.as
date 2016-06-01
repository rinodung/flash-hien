package red5
{
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import flash.ui.Mouse;
	import flash.display.MovieClip;
	import flash.events.MouseEvent; 
	public class Bell extends MovieClip implements ICellRenderer
	{
		public var _listData:ListData; 
		public var _data:Object; 
		public var _selected:Boolean; 
		public var status:int;
		public static var main:Main; 
		public var click:Boolean;
		public function Bell()
		{
			super();
			this.addEventListener(MouseEvent.CLICK,on_CLICK);
			//this.addEventListener(MouseEvent.ROLL_OVER,btn_over);
			//this.addEventListener(MouseEvent.ROLL_OUT,btn_out);
			this.status=1;
			this.click=false;
			stop();
			
		}
		public function on_CLICK(me:MouseEvent)
		{
			main.demofunction();
			
			
		}
		private function btn_over(me:MouseEvent)
		{
			Mouse.cursor="button";
		}
		private function btn_out(me:MouseEvent)
		{
			Mouse.cursor="auto";
		}
		public function set data(d:Object):void { 
			_data = d; 
			//this.name=d.name;
			this.set_status(d.bell_status);
			this.x+=20;
			this.y+=15;
			trace("SetData bell");
			
		} 
		public function get data():Object { 
			return _data; 
		} 
		public function set listData(ld:ListData):void { 
			_listData = ld; 
		} 
		public function get listData():ListData { 
			return _listData; 
		} 
		public function set selected(s:Boolean):void { 
			_selected = s; 
		} 
		public function get selected():Boolean { 
			return _selected; 
		} 
		public function setSize(width:Number, height:Number):void { 
		} 
		public function setStyle(style:String, value:Object):void { 
		} 
		public function setMouseState(state:String):void{ 
		} 
		
		
		public function set_status(frame:int):void
		{
			gotoAndStop(frame);
			this.status=status;
		}
			
	}
}