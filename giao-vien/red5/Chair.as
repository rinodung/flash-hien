﻿package red5
{
	import flash.display.MovieClip;
	import flash.utils.Timer;
    import flash.events.TimerEvent;
	public class Chair
	{
		protected var _x:Number;
		protected var _y:Number;
		protected var _status:Boolean;
		protected var _id:Number;
		protected var _avatar:MovieClip;
		protected var _timer:Timer;
		protected var _icon_action:String;
		/**
		   Creates a new Point3d.
		   @param x: The horizontal coordinate of the point.
		   @param y: The vertical coordinate of the point.
		   @param id: chair id.
		   @param status: false/true status chair.
		 */
		public function Chair(x:Number = 0, y:Number = 0, id:Number = 0, status:Boolean = false, avatar:MovieClip= null, timer:Timer= null, icon_action:String = "")
		{
			this._x = x;
			this._y = y;
			this._id = id;
			this._status = status;
			this.avatar= avatar;
			this.timer = timer;
			this._icon_action = icon_action;
		}

		/**
		   The horizontal coordinate of the point.
		 */
		public function get x():Number
		{
			return this._x;
		}

		public function set x(position:Number):void
		{
			this._x = position;
		}

		/**
		   The vertical coordinate of the point.
		 */
		public function get y():Number
		{
			return this._y;
		}

		public function set y(position:Number):void
		{
			this._y = position;
		}
		
		/**
		   The horizontal coordinate of the point.
		 */
		public function get id():Number
		{
			return this._id;
		}

		public function set id(id:Number):void
		{
			this._id = id;
		}

		/**
		   The depth coordinate of the point.
		 */
		public function get status():Boolean
		{
			return this._status;
		}

		public function set status(status:Boolean):void
		{
			this._status= status;
		}		
		
		/**
		   The avatar object of chair.
		 */
		public function get avatar():MovieClip
		{
			return this._avatar;
		}

		public function set avatar(avatar:MovieClip):void
		{
			this._avatar = avatar;
		}
		
		/**
		   The timer object of chair.
		 */
		public function get timer():Timer
		{
			return this._timer;
		}

		public function set timer(timer:Timer):void
		{
			this._timer = timer;
		}
		
		/**
		   The avatar action of chair.
		 */
		public function get icon_action():String
		{
			return this._icon_action;
		}

		public function set icon_action(icon_action:String):void
		{
			this._icon_action = icon_action;
		}
	}
}