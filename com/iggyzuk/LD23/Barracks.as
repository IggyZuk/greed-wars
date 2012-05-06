package com.iggyzuk.LD23 {
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Barracks extends Building {
		
		public function Barracks(_edge:Edge, _faction:int, _type:int, takeTerritory:Boolean = true) {
			
			super(_edge, _faction, _type, takeTerritory);
			
			HP = 200;
			income = 1;
			
			skin = new BarracksBuilding();
			skin.scaleX = skin.scaleY = 2;
			HPBar.changeHp(HP);
			
			render();
		}
		
		override public function update():void {
			HPBar.update();
		}
		
		public function produceUnits():void {
			Controller.level.addActor(edge, faction, 0, 0);
			Controller.level.addActor(edge, faction, 1, 0);
		}
		
	}

}