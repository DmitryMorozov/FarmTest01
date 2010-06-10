package {
	import flash.display.*;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import farm.Ground;

	public class main extends Sprite {
		var ground:Ground=new Ground();		// Всё поле с растениями
		var groundLdr:Loader=new Loader();
		var groundURLReq:URLRequest=new URLRequest("img/back.png");
		
		var buttonLoader:Loader=new Loader();	// Кнопка "следующий пример"
		var buttonURLReq:URLRequest=new URLRequest("img/change.png");
		var button:Sprite = new Sprite();
		var sampleIndex:Number;				//Номер примера

		public function main() {
			addChild(ground);
			groundLdr.load(groundURLReq);	//Загрузку вынул из класса, чтобы по окончании добавит кнопку сверху
			groundLdr.contentLoaderInfo.addEventListener(Event.COMPLETE,imgLoaded);
			sampleIndex=2;
		}
		
		function imgLoaded(event:Event):void {
			groundLdr.contentLoaderInfo.removeEventListener(Event.COMPLETE,imgLoaded);
			ground.addChild(groundLdr.content);
			ground.init();
			buttonLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,buttonLoaded);
			buttonLoader.load(buttonURLReq);
		}
		
		function buttonLoaded(event:Event):void {
			addChild(button);
			button.addChild(buttonLoader.content);
			button.x=10;
			button.y=560;
			button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonDown);
			button.addEventListener(MouseEvent.MOUSE_UP, onButtonUp);
		}
		function onButtonDown(event:Event):void {
			button.y+=2;
		}
		function onButtonUp(event:Event):void {
			sampleIndex++;
			ground.reloadXML("samples/sample"+ sampleIndex +".xml");
			if(sampleIndex==4) sampleIndex=0;
			button.y-=2;
		}
	}
}