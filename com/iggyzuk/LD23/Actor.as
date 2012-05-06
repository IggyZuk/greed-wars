package com.iggyzuk.LD23 {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Actor extends Sprite {
		
		public var active:Boolean = true;
		
		public var HP:Number = 30;
		public var range:int = 1;
		public var damage:Number = 5;
		public var attackRate:int = 15;
		public var faction:int = 0;
		public var moveSpeed:Number = 0.85;
		
		public var edge:Edge;
		
		private var moveDirection:int = 1;
		private var distanceAlongLine:Number = 1;
		
		public var HPBar:MovieClip;
		public var skin:MovieClip;
		
		public var enemyTarget:Object = null;
		public var attackTimer:int = 0;
		private var hurtValue:int = 0;
		
		private var rangeEdges:Array/*Edge*/ = [];
		
		private var frame:String;
		
		public function Actor(_edge:Edge, _faction:int, direction:int) {
			
			//Set properties
			edge = _edge;
			faction = _faction;
			moveDirection = direction;
			
			x = edge.v1.x;
			y = edge.v1.y;
			rotation = edge.getAngle()-180;
			distanceAlongLine = edge.getLength() / 2;
			
			//Skin
			skin = new BasicActor();
			
			HPBar = new HpBar( 0, -50, this);
			HPBar.scaleX = HPBar.scaleY = 0.25;
			
			render();
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
			skin.transform.colorTransform = new ColorTransform(1, 1, 1, 1, rgb.red/4, rgb.green/4, rgb.blue/4);
			addChild(skin);
			
			addChild(HPBar); //Add HP Bar
		}
		
		public function update():void {
			
			//If no enemy target is set, look for one and keep moving
			if (!enemyTarget) {
				
				//Move towards direction
				if (moveDirection == 0) {
					distanceAlongLine -= moveSpeed;
					scaleX = 1;
					HPBar.scaleX = 0.25;
				} else if (moveDirection == 1) {
					distanceAlongLine += moveSpeed;
					scaleX = -1;
					HPBar.scaleX = -0.25;
				}
				playAnimation("run");
			}
			
			//Hurt color
			if (hurtValue > 0) {
				transform.colorTransform = new ColorTransform(1, 1, 1, 1, hurtValue, hurtValue, hurtValue, 0);
				hurtValue -= 5;
			}
			
			HPBar.update();
			
			lookAhead();
			attack();
			move();
		}
		
		private function move():void {
			
			var edgePos:Vertex = edge.v1;
			var edgeAngle:Number = edge.getAngle();
			var edgeLength:Number = edge.getLength();
			
			//Move along the edge
			x = edgePos.x - Math.cos(edgeAngle * (Math.PI / 180)) * distanceAlongLine;
			y = edgePos.y - Math.sin(edgeAngle * (Math.PI / 180)) * distanceAlongLine;
			rotation = edgeAngle-180;
			
			//When distance along line is the same as the length go to the next edge
			if (distanceAlongLine >= edgeLength) advanceToEdge(1);
			else if (distanceAlongLine <= 0) advanceToEdge(-1);
		}
		
		private function advanceToEdge(direction:int):void {
			
			var newEdge:Edge;
			var newEdgeID:int = edge.id + direction;
			
			//Wrap around min and max
			var maxEdge:int = Controller.level.planet.edgesList.length-1;
			if (direction == 1 && edge.id == maxEdge) newEdgeID = 0;
			if (direction == -1 && edge.id == 0) newEdgeID = maxEdge;
			
			newEdge = Controller.level.planet.getEdge(newEdgeID);
			
			//Reset distance along line
			var extraStep:Number;
			if (direction == 1) {
				extraStep = distanceAlongLine - edge.getLength();
				distanceAlongLine = extraStep + 1;
			} else if (direction == -1) {
				extraStep = distanceAlongLine;
				distanceAlongLine = (newEdge.getLength() + extraStep) - 1;
			}
			
			edge = newEdge;
			
			Controller.level.planet.takeTerritory(edge, faction);
			populateNearTerritory();
			
			move();
		}
		
		private function populateNearTerritory():void {
			
			rangeEdges = [];
			rangeEdges.push(edge.id);
			
			for (var i:int = 0; i < range; i++) {
				rangeEdges.push(Controller.level.planet.getEdge(edge.id - (i+1)).id);
				rangeEdges.push(Controller.level.planet.getEdge(edge.id + (i+1)).id);
			}
		}
		
		private function lookAhead():void {
			if (enemyTarget) return;
			
			enemyTarget = filterEnemyList(Controller.level.actorList);
			enemyTarget = filterEnemyList(Controller.level.buildingList);
		}
		
		private function filterEnemyList(list:Array):Object {
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
					GameController.playSound("shotSfx_"+int(Math.random()*5+1));
				}
			}
			
			if(attackTimer < attackRate) attackTimer++;
		}
		
		public function hurt(hurtDamage:Number):Number {
			
			//Inflict damage
			HP -= hurtDamage;
			HPBar.currentHp = HP;
			
			if (HP <= 0) {
				active = false;
				Controller.level.addEffect(getCenter().x, getCenter().y, rotation);
				GameController.playSound("actorDieSfx", 2);
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
		
		public function playAnimation(_frame, reset:Boolean = false):void {
			if (reset) frame = "";
			if (frame != _frame) {
				frame = _frame;
				skin.gotoAndPlay(frame);
			}
		}
		
	}

}