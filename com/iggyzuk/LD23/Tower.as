package com.iggyzuk.LD23 {
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Tower extends Building {
		
		public var range:int;
		public var damage:int;
		public var attackRate:int;
		public var enemyTarget:Object = null;
		
		public var attackTimer:int = 0;
		
		public var rangeEdges:Array = [];
		
		public function Tower(_edge:Edge, _faction:int, _type:int, takeTerritory:Boolean = true) {
			super(_edge, _faction, _type, takeTerritory);
			
			HP = 150;
			range = 4;
			damage = 30;
			attackRate = 75;
			income = 1;
			
			skin = new HeavyTowerBuilding();
			skin.scaleX = skin.scaleY = 2;
			HPBar.changeHp(HP);
			
			render();
			
			populateNearTerritory(); //Add near edges to the tower
		}
		
		override public function update():void {
			HPBar.update();
			
			//Hurt color
			if (hurtValue > 0) {
				transform.colorTransform = new ColorTransform(1, 1, 1, 1, hurtValue, hurtValue, hurtValue, 0);
				hurtValue -= 5;
			}
			
			lookAhead();
			attack();
		}
		
		public function populateNearTerritory():void {
			
			rangeEdges = [];
			rangeEdges.push(edge.id);
			
			for (var i:int = 0; i < range; i++) {
				rangeEdges.push(Controller.level.planet.getEdge(edge.id - (i+1)).id);
				rangeEdges.push(Controller.level.planet.getEdge(edge.id + (i+1)).id);
			}
		}
		
		public function lookAhead():void {
			if (enemyTarget) return;
			
			enemyTarget = filterEnemyList(Controller.level.actorList);
			enemyTarget = filterEnemyList(Controller.level.buildingList);
			
			if(enemyTarget) GameController.playSound("alarmSfx");
		}
		
		public function filterEnemyList(list:Array):Object {
			if (enemyTarget) return enemyTarget;
			
			//Look for buildings
			for each(var enemy:Object in list) {
				if (enemy.faction == faction) continue;
				
				for (var i:int = 0; i < rangeEdges.length; i++) {
					var nearEdge:Edge = Controller.level.planet.getEdge(rangeEdges[i]);
					
					if (enemy.edge.id == nearEdge.id) return enemy;
				}
			}
			return enemyTarget;
		}
		
		public function attack():void {
			
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
					
					GameController.playSound("canonSfx");
					//GameController.playSound("shotSfx_" + int(Math.random() * 5 + 1));
					
					hurtValue = 100;
				}
			}
			
			if(attackTimer < attackRate-20) attackTimer++;
		}
	}

}