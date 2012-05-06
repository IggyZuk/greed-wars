package com.iggyzuk.LD23 {
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Commander {
		
		public var player:Boolean = false;
		public var faction:int;
		public var minerals:int;
		
		public var builder:Builder
		
		//Timers
		private var brainTimer:int = 100;
		private var placementTimer:int = 100;
		
		public var base:Base;
		
		public function Commander(_faction:int, _player:Boolean = false):void {
			faction = _faction;
			player = _player;
			builder = new Builder(this, _player);
			minerals = 30;
		}
		
		public function update():void {
			
			builder.update();
			
			if (player) return;
			
			//Computer is thinking what action to perform
			if (brainTimer <= 0) {
				think();
				brainTimer += Math.random()*200+100;
			} else brainTimer--;
			
			//Computer is thinking if
			
		}
		
		public function think():void {
			//trace(minerals);
			
			//if (minerals > 11) 
			if(Math.random() < 0.5){
				builder.setBuildEdge(Controller.level.planet.getEdge(Math.random() * Controller.level.planet.edgesList.length));
				builder.newBuilding(Math.random() * 6 + 1, faction, false, true);
				builder.build();
			}
		}
		
		public function getIncome():int {
			var income:int;
			for each(var b:Building in Controller.level.buildingList) {
				if (b.faction != faction) continue;
				income += b.income;
			}
			return income;
		}
		
	}

}