package com.iggyzuk.LD23 {
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Tank extends Actor {
		
		public function Tank(_edge:Edge, _faction:int, direction:int) {
			super(_edge, _faction, direction);
			
			HP = 100;
			range = 1;
			damage = 30;
			attackRate = 35;
			moveSpeed = 0.7;
			
			//Skin
			if (skin.parent) skin.parent.removeChild(skin);
			skin = new TankActor();
			
			HPBar = new HpBar( 0, -50, this);
			HPBar.scaleX = HPBar.scaleY = 0.25;
			
			render();
		}
		
		override public function attack():void {
			
			//If there is enemy target
			if (enemyTarget) {
				//Attack with rate
				if (attackTimer >= attackRate) {
					//Hurt and check if enemy is dead
					if (enemyTarget.hurt(damage) <= 0) {
						enemyTarget = null;
						Controller.level.planet.takeTerritory(edge, faction);
					}
					attackTimer = 0;
					
					playAnimation("shoot", true);
					GameController.playSound("canonSfx");
				}
			}
			
			if(attackTimer < attackRate) attackTimer++;
		}
		
	}

}