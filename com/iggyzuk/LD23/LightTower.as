package com.iggyzuk.LD23 {
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class LightTower extends Tower {
		
		public function LightTower(_edge:Edge, _faction:int, _type:int, takeTerritory:Boolean = true) {
			super(_edge, _faction, _type, takeTerritory);
			
			HP = 150;
			range = 5;
			damage = 2;
			attackRate = 3;
			income = 1;
			
			if(skin.parent) skin.parent.removeChild(skin)
			skin = new LightTowerBuilding();
			skin.scaleX = skin.scaleY = 2;
			
			HPBar.changeHp(HP);
			
			render();
			
			populateNearTerritory(); //Add near edges to the tower
		}
		
		override public function attack():void {
			
			if (enemyTarget) {
				
				if (attackTimer < attackRate) attackTimer++;
				
				//Attack with rate
				if (attackTimer >= attackRate) {
					//Hurt and check if enemy is dead
					if (enemyTarget.hurt(damage) <= 0) {
						enemyTarget = null;
						Controller.level.planet.takeTerritory(edge, faction);
					}
					attackTimer = 0;
					
					GameController.playSound("shotSfx_" + int(Math.random() * 5 + 1));
					
					hurtValue = 100;
				}
			}
			
			if(attackTimer < attackRate-20) attackTimer++;
		}
		
	}

}