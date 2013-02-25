
package com.taxiProjectClasses{
	
	public class Etat {
		public var X:Number = -1;
		public var Y:Number = -1;
		public var O:Boolean = false; //Occupé

		public function Etat(xPos:Number, yPos:Number, o:Boolean) {
			this.X = xPos;
			this.Y = yPos;
			this.O = o;
		}
	}
}