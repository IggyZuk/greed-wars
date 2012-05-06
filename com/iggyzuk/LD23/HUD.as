package com.iggyzuk.LD23 {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import com.greensock.*;
	import com.greensock.easing.*;
	/**
	 * ...
	 * @author Ignatus Zuk
	 */
	public class HUD extends Sprite {
		
		private var buttonList:Array = [];
		
		private var incomeTimer:int = 30;
		private var incomeSecond:int = 10;
		
		private var baseHP:HpBar;
		
		public var incomeValue:int = 0;
		public var itemDescription:String = "";
		public var instructions:String = "";
		
		public function HUD() {
			
			buttonList = [btn1, btn2, btn3, btn4, btn5, btn6];
			
			for (var i:int = 0; i < buttonList.length; i++ ) {
				var b:Object = buttonList[i];
				
				b.addEventListener(MouseEvent.MOUSE_UP, mDown, false, 0, true);
				b.addEventListener(MouseEvent.MOUSE_OVER, mOver, false, 0, true);
				b.addEventListener(MouseEvent.MOUSE_OUT, mOut, false, 0, true);
				b.buttonMode = true;
				b.gotoAndStop(i+1);
			}
			
			baseHP = new HpBar(690, 25, null, 800);
			baseHP.alpha = 1;
			baseHP.scaleX = baseHP.scaleY = 2;
			addChild(baseHP);
			
			instructions = "Pick starting position."
			
			render();
		}
		
		public function update():void {
			
			//Build with keys
			if (Input.isKeyDown(Input.NUMBER_1)) Controller.level.commander.builder.newBuilding(1, Controller.level.commander.faction, false, true);
			else if (Input.isKeyDown(Input.NUMBER_2)) Controller.level.commander.builder.newBuilding(2, Controller.level.commander.faction, false, true);
			else if (Input.isKeyDown(Input.NUMBER_3)) Controller.level.commander.builder.newBuilding(3, Controller.level.commander.faction, false, true);
			else if (Input.isKeyDown(Input.NUMBER_4)) Controller.level.commander.builder.newBuilding(4, Controller.level.commander.faction, false, true);
			else if (Input.isKeyDown(Input.NUMBER_5)) Controller.level.commander.builder.newBuilding(5, Controller.level.commander.faction, false, true);
			else if (Input.isKeyDown(Input.NUMBER_6)) Controller.level.commander.builder.newBuilding(6, Controller.level.commander.faction, false, true);
			
			if (incomeTimer <= 0) {
				incomeTimer = 30;
				
				incomeSecond--;
				
				if (incomeSecond < 0) {
					
					Controller.level.incomeTick();
					incomeSecond = 10;
				}
			} else incomeTimer--;
			
			//Update HP bar
			var commanderBase:Base = Controller.level.getBase(Controller.level.commander.faction);
			if(commanderBase){
				baseHP.currentHp = commanderBase.HP;
				baseHP.update();
				baseHP.alpha = 1;
			}
			
			render();
		}
		
		private function render():void {
			incomeTxt.text = String("Next Income: " + int(incomeSecond));
			mineralsTxt.text = String("Minerals: " + int(Controller.level.commander.minerals)+" (+"+int(incomeValue)+")");
			itemDescTxt.text = String(itemDescription);
			instructionsTxt.text = String(instructions);
		}
		
		private function mDown(e:MouseEvent):void {
			var btn:Object = e.currentTarget;
			
			if(btn.name == "btn1") Controller.level.commander.builder.newBuilding(1, Controller.level.commander.faction, false, true);
			else if(btn.name == "btn2") Controller.level.commander.builder.newBuilding(2, Controller.level.commander.faction, false, true);
			else if(btn.name == "btn3") Controller.level.commander.builder.newBuilding(3, Controller.level.commander.faction, false, true);
			else if(btn.name == "btn4") Controller.level.commander.builder.newBuilding(4, Controller.level.commander.faction, false, true);
			else if(btn.name == "btn5") Controller.level.commander.builder.newBuilding(5, Controller.level.commander.faction, false, true);
			else if(btn.name == "btn6") Controller.level.commander.builder.newBuilding(6, Controller.level.commander.faction, false, true);
			
			GameController.playSound("clickSfx");
		}
		
		private function mOver(e:MouseEvent):void {
			var btn:Object = e.currentTarget;
			
			if (btn.name == "btn1") itemDescription = "Build: Wall\nCost: 10";
			else if (btn.name == "btn2") itemDescription = "Build: Mine\nCost: 25";
			else if (btn.name == "btn3") itemDescription = "Build: Barracks\nCost: 30";
			else if (btn.name == "btn4") itemDescription = "Build: Factory\nCost: 50";
			else if (btn.name == "btn5") itemDescription = "Build: Machinegun\nCost: 30";
			else if (btn.name == "btn6") itemDescription = "Build: Cannon\nCost: 40";
			
			TweenLite.to(e.currentTarget, 0.2, { scaleX:1.2, scaleY:1.2, ease:Cubic.easeOut } ); 
		}
		private function mOut(e:MouseEvent):void { 
			itemDescription = "";
			TweenLite.to(e.currentTarget, 0.2, { scaleX:1, scaleY:1, ease:Cubic.easeOut } ); 
		}
		
	}

}