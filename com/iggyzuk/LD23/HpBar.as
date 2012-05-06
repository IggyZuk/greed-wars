package com.iggyzuk.LD23 {
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class HpBar extends MovieClip {
		
		public var active:Boolean = true;
		public var target:Object;
		
		public var totalHp:int = 0;
		public var currentHp:int = 0;
		public var currentHpOld:int = 0;
		
		public var visibleTimer:int = 0;
		
		
		public function HpBar(px:Number, py:Number, _target:Object, hp:int = 0) {
			x = px;
			y = py;
			alpha = 0;
			
			target = _target;
			
			if(target != null) totalHp = target.HP;
			else totalHp = hp;
			
			currentHp = totalHp;
			currentHpOld = totalHp;
			
			gotoAndStop(Math.floor((currentHp/totalHp)*100)); //Show frame on HpBar
		}
		
		public function changeHp(newHp:Number):void {
			totalHp = newHp;
			currentHp = totalHp;
			currentHpOld = totalHp;
			
			gotoAndStop(Math.floor((currentHp/totalHp)*100)); //Show frame on HpBar
			
			alpha = 0;
			visibleTimer = 0;
			
			active = true;
		}
		
		public function update():void {
			
			if(!active) return;
			
			//Show HpBar when it gets hurt
			if(currentHpOld != currentHp){
				currentHpOld = currentHp;
				visibleTimer = 100;
			}
			
			//Timed visibility...
			if(visibleTimer > 0) {
				if(visibleTimer >= 90 ) {
					if(alpha < 0.5) alpha += 0.1;
					else alpha = 0.5;
				} else if(visibleTimer <= 20) {
					if(alpha > 0) alpha -= 0.1;
					else alpha = 0;
				}
				visibleTimer--;
				
				gotoAndStop(Math.floor((currentHp/totalHp)*100)); //Show frame on HpBar
			}
			
			if(currentHp <= 0) {
				alpha = 0;
				active = false;
			}
		}
		
	}

}