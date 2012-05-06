package com.iggyzuk.LD23 {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Planet extends Sprite {
		
		public var verticesList:Array = [];
		public var edgesList:Array = [];
		
		public var radius:int;
		public var edges:int;
		
		//public var planetBitmapData:BitmapData;
		public var planetClip:Sprite = new Sprite();
		public var buildingClip:Sprite = new Sprite();
		public var actorClip:Sprite = new Sprite();
		
		private var texture:BitmapData = new StoneTex(0, 0);
		
		private var center:Point;
		
		private var trees:int;
		
		public function Planet(_radius:int, _edges:int) {
			
			radius = _radius
			edges = _edges;
			trees = 20;
			
			//Add clips
			var randomGlowColor:uint = Math.random() * 0xFFFFFFFF;
			planetClip.filters = [new GlowFilter(randomGlowColor, 0.4, 50, 50, 2, 1, true), new GlowFilter(randomGlowColor, 0.7, 2, 2, 50, 1, true), new GlowFilter(randomGlowColor, 0.5, 30, 30, 1, 1)];
			addChild(planetClip);
			addChild(buildingClip);
			addChild(actorClip);
			
			generatePlanet(radius, edges);
			
			//Popular edges
			for (var i:int = 0; i <  verticesList.length-1; i++) {
				var v1:Vertex = getVertex(i);
				var v2:Vertex = getVertex(i + 1);
				edgesList.push(new Edge(v1, v2, i));
			}
			edgesList.push(new Edge(getVertex(verticesList.length-1), getVertex(0), verticesList.length-1)); //Add last edge
			
			//Add trees
			for each(var e:Edge in edgesList) {
				if(int(Math.random() * trees) == 0){
					var tree:Building = new Building(e, 0, 1, false);
					addChild(tree);
				}
			}
			
			render();
		}
		
		private function generatePlanet(radius:int, edges:int):void {
			for(var i:int = 0; i < edges; i++){
				var angle:Number = (360 / edges)*i;
				
				var dx:int = Math.cos(angle*(Math.PI/180))*radius;
				var dy:int = Math.sin(angle*(Math.PI/180))*radius;
				
				verticesList.push(new Vertex(dx+radius, dy+radius));
			}
			center = findCenter();
			randomizeVertices(radius / 40);
		}
		
		private function findCenter():Point {
			var totalX:Number = 0;
			var totalY:Number = 0;
			for each(var v:Vertex in verticesList) {
				totalX += v.x;
				totalY += v.y;
			}
			totalX = totalX / verticesList.length;
			totalY = totalY / verticesList.length;
			
			return new Point(totalX, totalY);
		}
		
		public function render():void {
			
			graphics.clear();
			
			//Draw center lines
			planetClip.graphics.clear();
			
			for each(var e:Edge in edgesList) {
				
				var color:uint = Controller.level.NONE_FACTION;
				if (e.faction == 1) color = Controller.level.BLUE_FACTION;
				else if (e.faction == 2) color = Controller.level.RED_FACTION;
				else if (e.faction == 3) color = Controller.level.GREEN_FACTION;
				else if (e.faction == 4) color = Controller.level.YELLOW_FACTION;
				
				//graphics.lineStyle(1, outColor);
				var angle:Number = (e.getAngle()-180) * (Math.PI / 180);
				var texRadius:Number = radius/125;
				var m:Matrix = new Matrix(
											Math.cos(angle)*texRadius,
											Math.sin(angle)*texRadius,
											-Math.sin(angle)*texRadius,
											Math.cos(angle)*texRadius,
											center.x,
											center.y
										)
				
				//texture.colorTransform(texture.rect, new ColorTransform(1, 1, 1, 1, 255, 0, 0, 0));
				planetClip.graphics.beginBitmapFill(texture, m, true, true);
				planetClip.graphics.moveTo(e.v1.x, e.v1.y);
				planetClip.graphics.lineTo(center.x, center.y);
				planetClip.graphics.lineTo(e.v2.x, e.v2.y);
				planetClip.graphics.lineTo(e.v1.x, e.v1.y);
				planetClip.graphics.endFill();
				
				
				planetClip.graphics.beginFill(color, 0.15);
				planetClip.graphics.moveTo(e.v1.x, e.v1.y);
				planetClip.graphics.lineTo(center.x, center.y);
				planetClip.graphics.lineTo(e.v2.x, e.v2.y);
				planetClip.graphics.lineTo(e.v1.x, e.v1.y);
				planetClip.graphics.endFill();
				
			}
		}
		
		public function getVertex(id:int):Vertex {
			
			while (id >= verticesList.length) id -= verticesList.length;
			while (id < 0) id += verticesList.length;
			
			if (verticesList[id]) return verticesList[id];
			return null;
		}
		
		public function getEdge(id:int):Edge {
			
			while (id >= edgesList.length) id -= edgesList.length;
			while (id < 0) id += edgesList.length;
			
			if (edgesList[id]) return edgesList[id];
			return null;
		}
		
		public function randomizeVertices(amount:int):void {
			for each(var v:Vertex in verticesList) {
				v.x += (Math.random() - Math.random()) * amount;
				v.y += (Math.random() - Math.random()) * amount;
			}
			render();
		}
		
		public function takeTerritory(edge:Edge, faction:int):void {
			var e:Edge = getEdge(edge.id);
			if (e.faction == faction) return;
			
			
			if (faction == Controller.level.commander.faction) GameController.playSound("territoryGain",2);
			if (faction != Controller.level.commander.faction && e.faction == Controller.level.commander.faction) GameController.playSound("territoryLost",2);
			
			e.faction = faction;
			render();
		}
		
		public function populateNearTerritory(edge:Edge, faction:int):void {
			
			for (var i:int = 0; i < Controller.level.planet.edges/8; i++) {
				getClosestEdge(new Point(edge.v1.x, edge.v1.y), faction, true, false).faction = faction;
			}
			render();
		}
		
		public function getClosestEdge(point:Point, faction:int, startMode:Boolean = false, buildMode:Boolean = false):Edge {
			var closestDis:Number = Infinity;
			var closestEdge:Edge = null;
			
			for each(var e:Edge in edgesList) {
				
				if (e.building) continue; //Only one building for each edge.
				if (buildMode && e.faction != faction) continue; //Ignore edges that have a different faction
				if (startMode && e.faction == faction) continue; //Ignore edges with the same faction
				if (startMode && e.faction != 0) continue; //Allow to start building only on neutral faction (0)
				
				var dx:Number = e.v1.x - point.x;
				var dy:Number = e.v1.y - point.y;
				var dis:Number = Math.sqrt(dx * dx + dy * dy);
				if (dis < closestDis) {
					closestDis = dis;
					closestEdge = e;
				}
			}
			return closestEdge;
		}
		
		public function getFactionTerritoryCount(faction:int):int {
			var count:int = 0;
			for each(var e:Edge in edgesList) {
				if (e.faction != faction) continue;
				count++;
			}
			return count;
		}
		
	}

}