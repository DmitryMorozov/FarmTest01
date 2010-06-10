//
// Каждый файл загружается при необходимости и только один раз,
// но код загрузки файлов получился не прозрачный, из-за того что не разобрался 
// как узнать не грузится ли в данный момент этот же файл. Потому сначала 
// составляется список только нужных файлов(выбираются не повторяющиеся из данной XML
// и сравниваются с загруженными из предыдущей), загружаются, и когда загрузятся все(проверяется счетчиком) 
// полученные битмапы клонируются и добавляются как дочерние в ячейки.
//
package farm{
	import flash.display.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import farm.Field;

	public class Ground extends Sprite {		//Лучше бы назвал Field, но в XML Field - ячейка

		var stagesToLoad:Array=new Array();		// Номера стадий, для которых нужно загрузить изображения.
		var stagesToLoadOld:Array=new Array();	// Для сравнения загруженного с новым XML. 
		var stagesBitmaps:Array=new Array();	// Битмапы стадий роста, Индекс - номер стадии.
		var stages:Number,stagesLoaded:Number;	// Сколько надо загрузить, загружено изображений
		var fields:Array=new Array();			// Поля, нужные растения добавляются дочерним битмапом
		var groundXML:XML=new XML();
		var groundXMLReq:URLRequest=new URLRequest("samples/sample1.xml");
		var groundLoader:URLLoader=new URLLoader();

		public function Ground() {
			addEventListener(MouseEvent.MOUSE_DOWN,onDown);
			addEventListener(MouseEvent.MOUSE_UP,onUp);
			addEventListener(MouseEvent.MOUSE_MOVE,onMove);
		}

		public function init():void { 			// вызывается после загрузки бэкграунда, чтобы потом местами не менять
			groundLoader.addEventListener(Event.COMPLETE,xmlLoaded);
			groundLoader.load(groundXMLReq);
			y=-400;
			x=-350;
		}

		public function reloadXML(url:String):void {	// Загрузить другой пример
			while (numChildren-1) {						// Удаляем детей, кроме фона(индекс всегда 0)
				removeChildAt(1);
			}
			for (var i=0; i<stagesToLoad.length; i++) {	// соберём номера загруженных стадий в массив stagesToLoadOld
				if(stagesToLoad[i]) stagesToLoadOld[i]=stagesToLoad[i];	
				stagesToLoad[i]=false;	
			}
			var newXMLReq:URLRequest=new URLRequest(url);
			groundLoader.addEventListener(Event.COMPLETE,xmlLoaded);
			groundLoader.load(newXMLReq);
		}

		private function xmlLoaded(event:Event):void {
			stages=0;
			stagesLoaded=0;
			groundXML=XML(groundLoader.data);
			var XMLItems=groundXML.descendants("field");	// Возьмем дочерние объекты
			
			for (var i=0; i<XMLItems.length(); i++) {		
				var tempStage:uint;
				tempStage=XMLItems[i].crop.@stage;
				fields[i]=new Field();
				fields[i].init(XMLItems[i].@id,XMLItems[i].@x, XMLItems[i].@y, tempStage);	// Инициализируем атрибутами из XML
				addChild(fields[i]);
				//Дальше проверка нужно ли файл грузить и был ли он в предыдущий раз:
				if (tempStage!=0 && stagesToLoad[tempStage]!=true && stagesToLoadOld[tempStage]!=true) { //Если есть у поля кроп и такого ещё не было и не было в предыдущем XML
					stages++;						// Грузить на один больше
					stagesToLoad[tempStage]=true;	// Пометим номер стадии кропа для загрузки
				}
			}
			if (stages!=0) {						// Если надо догружать
				for (i=0; i<stagesToLoad.length; i++) {
					if (stagesToLoad[i]) {			// Выберем, которые нужно загрузить
						var tempURL:String="img/stages/stage_"+i+".png";
						var tempLoader:Loader=new Loader();
						var tempURLReq:URLRequest=new URLRequest(tempURL);
						tempLoader.name="stage_"+i;	// Имя, чтобы потом узнать какой загрузился
						tempLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,stageLoaded);
						tempLoader.load(tempURLReq);
					}
				}
			}
			else copyBitmaps();						// Если все битмапы уже есть, добавим в поля
			groundLoader.removeEventListener(Event.COMPLETE,xmlLoaded);
		}

		private function stageLoaded(event:Event):void {
			var stageLoader:Loader=Loader(event.target.loader);
			var temp=stageLoader.name.charAt(stageLoader.name.indexOf("_")+1);	//Из имени возьмем номер стадии роста, по-другому не придумал
			stagesBitmaps[temp]=Bitmap(stageLoader.content);					// Добавим битмап с индексом = стадии
			stagesLoaded++;
			trace("stage_"+temp+" loaded");

			if (stagesLoaded==stages) {				// нужные картинки загрузили.
				copyBitmaps();			
			}
		}

		private function copyBitmaps():void {
			for (var i=0; i<fields.length; i++) {
				if (fields[i].fStage!=0) {
					var image:Bitmap=new Bitmap(stagesBitmaps[fields[i].fStage].bitmapData.clone());
					fields[i].addChild(image);		// клонирем битмапы, добавляем в поля. А битмапы в массиве остаються на хранение для следующих XML
				}
			}
		}
		
		private function onDown(event:Event):void {	//Таскаем поле
			startDrag();
		}
		
		private function onMove(event:Event):void {
			if(x<-540) x = -540;
			if(x>0) x = 0;
			if(y<-540) y = -540;
			if(y>-30) y = -30;
		}
		
		private function onUp(event:Event):void {
			stopDrag();
		}
	}
}