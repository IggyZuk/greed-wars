package com.iggyzuk.components {
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Transition extends MovieClip {
		
		private var onStateChange:Function = null;
		
		public function Transition() {
			stop();
			mouseEnabled = false;
			mouseChildren = false;
			visible = false;
		}
		
		public function playTween(target:Object):void {
			play();
			if(target is Function){
				onStateChange = target as Function; //Add a custom function
			} else {
				onStateChange = function() {
					GameController.timeline.gotoAndStop(target); //Or simply go to a frame
				};
			}
			visible = true;
		}
		
		//End tween
		protected function endTween():void {
			//if(onStateChange != null) {
				gotoAndStop(1);
				visible = false;
			//}
		}
		
		//Call the state changing function
		protected function changeState():void {
			if (onStateChange != null) {
				onStateChange();
				onStateChange = null;
			}
		}
		
	}

}