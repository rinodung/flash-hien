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
			this.addEventListener(MouseEvent.ROLL_OVER,btn_over);
			this.addEventListener(MouseEvent.ROLL_OUT,btn_out);
			this.status=1;
			this.click=false;
			stop();
			
		}
		private function btn_over(me:MouseEvent)
		{
			Mouse.cursor="button";
		}
		private function btn_out(me:MouseEvent)
		{
			Mouse.cursor="auto";
		}
		public function on_CLICK(me:MouseEvent)
		{
			
			this.click=true;
			
			
			//trace(this._data.id +" Click"+ "Bell status: "+this._data.bell_status);
			if(this._data.bell_status == 2 || this._data.bell_status == 1)
			{
			main.demofunction(this._data.masv);
			}
			if(this._data.bell_status == 3)
			{
				main.closeStreamClient(this._data.masv);
			}
			
		}
		public function set data(d:Object):void { 
			_data = d; 
			this.name=d.name;
			if(this.click==false) this.set_status(d.bell_status);
			this.x+=20;
			this.y+=18;
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