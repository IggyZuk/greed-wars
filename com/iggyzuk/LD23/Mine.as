package com.iggyzuk.LD23 {
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Mine extends Building {
		
		public function Mine(_edge:Edge, _faction:int, _type:int, takeTerritory:Boolean = true) {
			super(_edge, _faction, _type, takeTerritory);
			
			HP = 100;
			income = 4;
			
			skin = new MineBuilding();
			skin.scaleX = skin.scaleY = 2;
			
			HPBar.changeHp(HP);
			
			render();
		}
		
	}

}