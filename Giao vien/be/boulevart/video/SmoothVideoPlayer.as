package be.boulevart.video
{
	import mx.controls.VideoDisplay;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	use namespace mx_internal;

	public class SmoothVideoPlayer extends VideoDisplay
	{
		
		private var _smoothing:Boolean
		private var _inited:Boolean
		
		public function SmoothVideoPlayer()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE,init)
		}
		
		private function init(e:FlexEvent):void{
			videoPlayer.smoothing = _smoothing;
			_inited=true
		}
		
		public function set smoothing(val:Boolean):void{
			if (val == _smoothing) return;
			_smoothing = val;
			
			if(_inited){
				videoPlayer.smoothing = _smoothing;
			}
		}
		
		public function get smoothing():Boolean{
			return _smoothing;
		}
		
		
		
	}
}

