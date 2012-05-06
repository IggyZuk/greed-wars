package com.iggyzuk.LD23 {
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Builder {
		
		private var commander:Commander;
		private var player:Boolean;
		
		private var isBuilding:Boolean = false;
		private var building:Building = null;
		private var edgeOld:Edge = null;
		private var type:int = 0;
		private var faction:int = 0;
		private var startMode:Boolean = false;
		private var buildMode:Boolean = false;
		
		//Computer
		private var buildEdge:Edge = null;
		private var placeBuilding:Boolean = false;
		
		public function Builder(_commander:Commander, _player:Boolean) {
			commander = _commander;
			player = _player;
		}
		
		public function update():void {
			if (player && Input.isMouseDown() && Controller.stage.mouseX < 580) build();
			updateBuilding();
		}
		
		public function setBuildEdge(_edge:Edge):void { buildEdge = _edge; } //Set building edge
		public function build():void { placeBuilding = true; } //Build it!
		
		public function newBuilding(_type:int, _faction, _startMode:Boolean = false, _buildMode:Boolean = false):void {
			trace("Placing a new building");
			
			isBuilding = true;
			placeBuilding = false;
			type = _type;
			faction = _faction;
			startMode = _startMode;
			buildMode = _buildMode;
		}
		
		private function updateBuilding():void {
			if (!isBuilding) return;
			
			var buildPoint:Point;
			if(player) buildPoint = buildPoint = new Point(Controller.level.getMouse().x, Controller.level.getMouse().y);
			else buildPoint = new Point(buildEdge.v1.x, buildEdge.v1.y);
			
			var edge:Edge = Controller.level.planet.getClosestEdge(
									buildPoint, 
									faction,
									startMode,
									buildMode);
			
			//If no more edges then just remove it
			if (!edge) {
				isBuilding = false;
				if (building && building.parent) building.parent.removeChild(building);
				return;
			}
			
			//Did we change placing position? efficency check
			if (edge != edgeOld) {
				edgeOld = edge;
				
				if (building && building.parent) building.parent.removeChild(building); //Remove old building
				building = Controller.level.addBuilding(edge, faction, type, false, false); //Add new building
				building.alpha = 0.5;
			}
			
			//Mouse Down - Place building!
			if (placeBuilding) {
				
				isBuilding = false;
				if (building && building.parent) building.parent.removeChild(building); //Remove semi building
				if (player) {
					Controller.level.hud.instructions = "";
					Controller.level.isPlacingBase = false; //First time when player builds, start game!
				}
				
				//Set up prices
				var cost:int = 0;
				if (type == 1) cost = 10;
				else if (type == 2) cost = 25;
				else if (type == 3) cost = 30;
				else if (type == 4) cost = 50;
				else if (type == 5) cost = 30;
				else if (type == 6) cost = 40;
				
				//Check Cash	
				if (commander.minerals >= cost) {
					
					//Pay
					commander.minerals -= cost;
					
					if (startMode) Controller.level.planet.populateNearTerritory(edge, faction); //Base is free
					Controller.level.addBuilding(edge, faction, type);
					GameController.playSound("buildBuildingSfx2");
					
					//Set new income in HUD
					if (player) Controller.level.hud.incomeValue = Controller.level.commander.getIncome();
					
				} else {
					if(player) GameController.playSound("buildBuildingSfx");
				}
			}
		}
		
	}

}