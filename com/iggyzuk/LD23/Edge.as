package com.iggyzuk.LD23 {
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Edge {
		
		public var v1:Vertex;
		public var v2:Vertex;
		public var id:int;
		public var faction:int = 0;
		public var building:Building;
		
		public function Edge(_v1:Vertex, _v2:Vertex, _id:int) {
			v1 = _v1;
			v2 = _v2;
			id = _id;
		}
		
		public function getAngle():Number {
			var dx:Number = v1.x - v2.x;
			var dy:Number = v1.y - v2.y;
			return Math.atan2(dy,dx)/(Math.PI/180);
		}
		
		public function getLength():Number {
			var dx:Number = v1.x - v2.x;
			var dy:Number = v1.y - v2.y;
			return Math.sqrt(dx*dx+dy*dy);
		}
		
	}

}