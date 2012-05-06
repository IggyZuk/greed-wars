package com.iggyzuk.LD23 {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Building extends Sprite {
		
		public var active:Boolean = true;
		
		public var HP:int = 100;
		public var edge:Edge;
		public var faction:int;
		public var type:int;
		public var income:int = 1;
		
		public var HPBar:HpBar;
		public var skin:MovieClip;
		
		public var hurtValue:int = 0;
		
		public function Building(_edge:Edge, _faction:int, _type:int, takeTerritory:Boolean = true) {
			
			//Set properties
			edge = _edge;
			faction = _faction;
			type = _type;
			
			if (takeTerritory) {
				Controller.level.planet.takeTerritory(edge, faction);
				edge.building = this;
			}
			
			var edgePos:Vertex = edge.v1;
			var edgeAngle:Number = edge.getAngle();
			var edgeLength:Number = edge.getLength();
			var distanceAlongLine:Number = edgeLength / 2;
			
			//Move along the edge
			x = edgePos.x - Math.cos(edgeAngle * (Math.PI / 180)) * distanceAlongLine;
			y = edgePos.y - Math.sin(edgeAngle * (Math.PI / 180)) * distanceAlongLine;
			rotation = edgeAngle-180;
			
			HPBar = new HpBar(0, -60, this);
			HPBar.scaleX = HPBar.scaleY = 0.5;
		}
		
		public function render():void {
			
			graphics.clear();
			
			//Add skin
			var color:uint = Controller.level.NONE_FACTION;
			if (faction == 1) color = Controller.level.BLUE_FACTION;
			else if (faction == 2) color = Controller.level.RED_FACTION;
			else if (faction == 3) color = Controller.level.GREEN_FACTION;
			else if (faction == 4) color = Controller.level.YELLOW_FACTION;
			
			var rgb:Object = Controller.hexToRGB(color);
			skin.transform.colorTransform = new ColorTransform(1, 1, 1, 1, rgb.red / 4, rgb.green / 4, rgb.blue / 4);
			addChild(skin);
			
			addChild(HPBar); //Add HP Bar
		}
		
		public function update():void {
			
			HPBar.update();
			
			//Hurt color
			if (hurtValue > 0) {
				transform.colorTransform = new ColorTransform(1, 1, 1, 1, hurtValue, hurtValue, hurtValue, 0);
				hurtValue -= 5;
			}
			
			/*
			//Base
			if (type == 0) {
				if(addActorTimer >= 90){
				Controller.level.addActor(edge, faction, 0);
				Controller.level.addActor(edge, faction, 1);
				addActorTimer = 0;
			} else addActorTimer++;
			
			}
			*/
		}
		
		public function hurt(hurtDamage:Number):Number {
			
			//Inflict damage
			HP -= hurtDamage;
			HPBar.currentHp = HP;
			
			if (HP <= 0) {
				active = false;
				Controller.level.addEffect(getCenter().x, getCenter().y, rotation);
			}
			
			//Turn actor white
			hurtValue = 150;
			
			return HP;
		}
		
		public function getCenter():Point {
			var center:Point = new Point();
			var height:Number = 20;
			center.x = height * Math.cos((rotation-90) * (Math.PI/180)) + x;
			center.y = height * Math.sin((rotation-90) * (Math.PI/180)) + y;
			return center;
		}
		
	}

}