package farm{
	import flash.display.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;

	public class Field extends Sprite {
		var fId:Number,ix:Number,iy:Number,fStage:Number;	//Поля из XML. 
		public function Field() {
		}
		public function init(fId1:Number, ix1:Number, iy1:Number, fStage1:Number):void {
			fId=fId1;
			fStage=fStage1;
			ix=ix1-1;
			iy=iy1-1;
			x=610+ix*83.5-iy*83.5;	// Померил в фотошопе, вроде так
			y=415+ix*42.1+iy*42.1;
		}
	}
}