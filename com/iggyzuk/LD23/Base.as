package com.iggyzuk.LD23 {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Base extends Building {
		
		private var alarmTimer:int = 0;
		
		public function Base(_edge:Edge, _faction:int, _type:int, takeTerritory:Boolean = true) {
			super(_edge, _faction, _type, takeTerritory);
			
			HP = 800;
			income = 2;
			
			skin = new Rocket();
			skin.scaleX = skin.scaleY = 2.25;
			HPBar.changeHp(HP);
			
			render();
		}
		
		override public function update():void {
			
			//Our base make a sound when its damaged
			if(faction == Controller.level.commander.faction){
				if (HP <= 400) {
					if (alarmTimer <= 0) {
						GameController.playSound("alarmSfx", 1);
						alarmTimer = 65;
					} else alarmTimer--;
				}
			}
			
			HPBar.update();
			
			//Hurt color
			if (hurtValue > 0) {
				transform.colorTransform = new ColorTransform(1, 1, 1, 1, hurtValue, hurtValue, hurtValue, 0);
				hurtValue -= 5;
			}
		}
		
		public function produceUnits():void {
			Controller.level.addActor(edge, faction, 0, 0);
			Controller.level.addActor(edge, faction, 1, 0);
		}
		
	}

}