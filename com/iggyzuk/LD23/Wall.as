package com.iggyzuk.LD23 {
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Wall extends Building {
		
		public function Wall(_edge:Edge, _faction:int, _type:int, takeTerritory:Boolean = true) {
			super(_edge, _faction, _type, takeTerritory);
			
			HP = 400;
			income = 0;
			
			skin = new WoodWall();
			skin.scaleX = skin.scaleY = 2;
			HPBar.changeHp(HP);
			
			render();
		}
	}

}