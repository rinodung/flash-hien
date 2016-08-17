package
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ListItem;
	import com.bit101.components.PushButton;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import com.bit101.components.Label;
	
	public class CheckListItem extends ListItem
	{
		protected var _myLabel:Label;
		protected var _name:String;
		protected var _address:String;
		
		
		public function CheckListItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, data:Object = null)
		{
			super(parent, xpos, ypos, data);
		}
		
		protected override function addChildren():void
		{
			super.addChildren();
			_label.visible = false;
			_myLabel = new Label(this, 5, 5, "");
		}
		
		public override function draw():void
		{
			super.draw();
			if(_data == null)
				return;
			if(_data is String)
			{
				//_checkBox.label = _data as String;
				_myLabel.text= _data as String;
			}
			else if(_data.name is String)
			{
				_name = _data.name;
				_address = _data.address;
				
				_myLabel.text = _name+ " " + _address;
			}
			else
			{
				//_checkBox.label = _data.toString();
				_myLabel.text = _data.toString();
			}
			if(_data.checked != null)
			{
				//_checkBox.selected = _data.checked;
			}
		}
		
		protected function onCheck(event:Event):void
		{
			//_data.checked = _checkBox.selected;
		}
		
		protected function onClick(e:Event):void
		{
			//_button.label = _masv;
		}
	}
}