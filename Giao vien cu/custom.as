package
{
	import com.bit101.components.*;
    import flash.display.Sprite;
    import flash.events.Event;
	import fl.controls.*;
	
	public class custom extends Sprite
	{
        private var list:List;
        private var label:Label;
 
		public function custom()
		{
            Component.initStage(stage);
 
            label = new Label(this, 10, 10);
 
            list = new List(this, 10, 50);
            list.listItemClass = CheckListItem;
            for(var i:int = 0; i < 20; i++)
            {
                list.addItem({label:"item " + i, checked:i % 2 == 0, masv:"sv" + i});
            }
            list.addEventListener(Event.SELECT, onSelect);
			label.text = "Số học viên tham gia: ";
		}		
 
        protected function onSelect(event:Event):void
        {
            //label.text = list.selectedItem.label + ". checked: " + list.selectedItem.checked;
        }
	}
}