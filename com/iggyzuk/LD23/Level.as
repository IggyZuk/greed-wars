package com.iggyzuk.LD23 {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class Level {
		
		//Faction colors
		public const NONE_FACTION:uint = 0xFF000000;
		public const BLUE_FACTION:uint = 0xFF0099FF;
		public const RED_FACTION:uint = 0xFFCC0000;
		public const GREEN_FACTION:uint = 0xFF00FF22;
		public const YELLOW_FACTION:uint = 0xFFFF9932;
		
		public var hudClip:Sprite = new Sprite();
		public var gameClip:Sprite = new Sprite();
		
		public var center:Point = new Point(135, 100);
		public var cameraSmooth:Point = new Point(center.x, center.y);
		public var mousePoint:Point = new Point();
		
		public var hud:HUD;
		public var planet:Planet;
		
		public var buildingList:Array/*Building*/ = [];
		public var actorList:Array/*Actor*/ = [];
		public var commanderList:Array/*Commander*/ = [];
		public var effectList:Array = [];
		
		public var commander:Commander; //Player
		
		public var isPlacingBase:Boolean = true;
		
		public function create():void {
			
			trace("Level Created");
			
			//Background
			var bg:Bitmap = new Bitmap(new BG(0, 0));
			bg.scaleX = bg.scaleY = 2;
			bg.transform.colorTransform = new ColorTransform(1, 1, 1, 1, Math.random() * 100, Math.random() * 100, Math.random() * 100, 0);
			Controller.content.addChild(bg);
			
			//Game Clip, basically contains the whole game
			
			//Set GameClip
			Controller.content.addChild(gameClip);
			gameClip.x = cameraSmooth.x
			gameClip.y = cameraSmooth.y
			
			//Add player commander
			commander = addCommander(Controller.faction, true);
			
			//Set Hud
			hud = new HUD();
			hudClip.addChild(hud);
			Controller.stage.addChild(hudClip);
			
			//Set Planet
			planet = new Planet(Controller.radius, Controller.edges);
			gameClip.addChild(planet);
			
			//Add enemies
			addEnemyFactions();
			
			//Place your base!
			commander.builder.newBuilding(0, Controller.level.commander.faction, true, false);
			
			GameController.playMusic("GameMusic");
		}
		
		
		public function addEnemyFactions() {
			
			var possibleFaction:Array = [1, 2, 3, 4];
			
			for (var i:int = 0; i < possibleFaction.length; i++) {
				if (possibleFaction[i] == Controller.faction) {
					possibleFaction.splice(i, 1);
					break;
				}
			}
			
			for (var d:int = 0; d < Controller.factions; d++) {
				
				var randomID:int = Math.random() * possibleFaction.length;
				var randomFaction:int = possibleFaction[randomID];
				possibleFaction.splice(randomID, 1);
				
				addCommander(randomFaction);
				addBase(
						planet.getEdge(Math.random() * planet.edgesList.length),
						randomFaction
				);
			}
			
			/*
			var addedFactions:Array = [];
			
			while (commanderList.length - 1 < Controller.factions) {
				var randomFaction:int = Math.random() * 4 + 1;
				var isCopy:Boolean = false;
				
				for each(var addedFaction:int in addedFactions) {
					if (randomFaction == addedFaction || addedFaction == Controller.faction) {
						isCopy = true;
					}
				}
				
				//If its not copy then add it!
				if(!isCopy){
					addCommander(randomFaction);
					addBase(
							planet.getEdge(Math.random() * planet.edgesList.length),
							randomFaction
					);
					addedFactions.push(randomFaction);
				}
			}
			*/
		}
		
		public function destroy():void {
			trace("Level Destroyed");
			
			planet.parent.removeChild(planet);
			planet = null;
			
			Controller.content.removeChild(gameClip);
			hudClip.removeChild(hud);
			Controller.stage.removeChild(hudClip);
		}
		
		public function update():void {
			
			if (Controller.gamePaused) return;
			
			/*
			if (Input.isKeyDown(Input.MINUS)) Controller.zoom -= 0.01;
			else if (Input.isKeyDown(Input.EQUAL)) Controller.zoom += 0.01;
			*/
			
			if(!isPlacingBase) hud.update();
			
			updateCommanders();
			updateBuildings();
			updateActors();
			updateEffects();
			cameraUpdate();
		}
		
		public function incomeTick():void {
			checkVictory();
			addMinerals();
			produceUnits(); //Produce Units!
			GameController.playSound("addIncomeSfx", 1);
		}
		
		public function addCommander(faction, player:Boolean = false):Commander {
			var commander:Commander = new Commander(faction, player);
			commanderList.push(commander);
			return commander;
		}
		
		public function updateCommanders():void {
			for each(var commander:Commander in commanderList) commander.update();
		}
		
		public function addBase(edge:Edge, faction:int):void {
			addBuilding(edge, faction, 0);
			planet.populateNearTerritory(edge, faction);
		}
		
		//Buildings
		public function addBuilding(edge:Edge, faction:int, type:int, takeTerritory:Boolean = true, active:Boolean = true):Building {
			
			var types:Array = [
				Base,
				Wall,
				Mine,
				Barracks,
				Factory,
				LightTower,
				Tower
			];
			
			var classRef:Class = types[type] as Class;
			var building:Building = new classRef(edge, faction, type, takeTerritory);
			planet.buildingClip.addChild(building);
			if(active) buildingList.push(building);
			
			return building;
		}
		
		private function updateBuildings():void {
			for (var i:int = 0; i < buildingList.length; i++) {
				var building:Building = buildingList[i];
				
				if (building.active) building.update();
				else {
					building.edge.building = null;
					building.parent.removeChild(building);
					building = null;
					buildingList.splice(i, 1);
					i--;
				}
			}
		}
		
		//Actors
		public function addActor(startEdge:Edge, faction:int, direction:int, type:int):void {
			
			var types:Array = [
				Actor,
				Tank
			];
			
			var classRef:Class = types[type] as Class;
			var actor:Actor = new classRef(startEdge, faction, direction);
			planet.actorClip.addChild(actor);
			actorList.push(actor);
		}
		
		private function updateActors():void {
			for (var i:int = 0; i < actorList.length; i++) {
				var actor:Actor = actorList[i];
				
				if (actor.active) actor.update();
				else {
					actor.parent.removeChild(actor);
					actor = null;
					actorList.splice(i, 1);
					i--;
				}
			}
		}
		
		//Effects
		public function addEffect(px:Number, py:Number, rt:Number = 0):void {
			var effect:MovieClip = new Explosion();
			effect.x = px;
			effect.y = py;
			effect.rotation = rt;
			planet.addChild(effect);
			effectList.push(effect);
			GameController.playSound("explosionSfx");
		}
		
		private function updateEffects():void {
			for (var i:int = 0; i < effectList.length; i++) {
				var effect:MovieClip = effectList[i];
				
				if (effect.currentFrame >= effect.totalFrames){
					effect.parent.removeChild(effect);
					effect = null;
					effectList.splice(i, 1);
					i--;
				}
			}
		}
		
		private function cameraUpdate():void {
			
			var cameraSpeed:Number = planet.radius * 0.034;
			
			
			//Controls
			if (Input.isKeyDown(Input.A) || Input.isKeyDown(Input.LEFT)) cameraSmooth.x += cameraSpeed;
			else if (Input.isKeyDown(Input.D) || Input.isKeyDown(Input.RIGHT)) cameraSmooth.x -= cameraSpeed;
			if (Input.isKeyDown(Input.W) || Input.isKeyDown(Input.UP)) cameraSmooth.y += cameraSpeed;
			else if (Input.isKeyDown(Input.S) || Input.isKeyDown(Input.DOWN)) cameraSmooth.y -= cameraSpeed;
			
			
			mousePoint = new Point(Controller.stage.mouseX, Controller.stage.mouseY);
			
			if (Controller.stage.mouseX < 100) mousePoint.x = 100;
			else if (Controller.stage.mouseX > 700) mousePoint.x = 700;
			if (Controller.stage.mouseY < 100) mousePoint.y = 100;
			else if (Controller.stage.mouseY > 500) mousePoint.y = 500;
			
			gameClip.x -= (gameClip.x - cameraSmooth.x) * 0.14;
			gameClip.y -= (gameClip.y - cameraSmooth.y) * 0.14;
		}
		
		public function getMouse():Point {
			return new Point(
						Controller.stage.mouseX - gameClip.x,
						Controller.stage.mouseY - gameClip.y
			)
		}
		
		//Give Minerals to each commander
		public function addMinerals():void {
			for each(var c:Commander in commanderList) {
				c.minerals += c.getIncome();
			}
		}
		
		public function produceUnits():void {
			for each(var b:Building in buildingList) {
				if (b is Base || b is Barracks || b is Factory)  Object(b).produceUnits();
			}
		}
		
		//Check to see if we won or lost (on every tick)
		public function checkVictory():void {
			
			var victory:Boolean = true;
			var defeat:Boolean = true;
			
			for each(var edge:Edge in planet.edgesList) {
				if (edge.faction != commander.faction) victory = false;
				if (edge.faction == commander.faction) defeat = false;
			}
			
			if (victory) hud.instructions = "You Win!\nPress R to restart or Q to go back to menu";
			if (defeat) {
				hud.instructions = "You Lost!\nPress R to restart or Q to go back to menu";
				hud.instructionsTxt.transform.colorTransform = new ColorTransform(2, 1, 1, 1, 250, 0, 0, 0);
			}
		}
		
		//Get base building by passed in faction
		public function getBase(faction:int):Base {
			for each(var base:Building in buildingList) {
				if (!(base is Base)) continue;
				if (base.faction == faction) return Base(base);
			}
			return null;
		}
		
	}

}