package com.taxiProjectClasses{
	
	public class Voiture {
		/*var X:Number = -1;
		var Y:Number = -1;
		var O:Boolean = false;*/
		
		public var id:int = -1;
		public var etat:Etat = null;
		public var lastUpdate:int = -1;
		
		//Utile pour le deplacement en mode points. Evite de parcourir tout le tableau, on reprend juste au dernier indice utilisé
		public var lastIndice:int = 0;
		
		public var tabDeplacements:Array = new Array();
		
		public function Voiture(id:Number) {
			this.id = id;
		}
		
		//Marche car le tableau est trié en fct du temps
		public function getPosition(temps:int):Etat{
			var i:int = lastIndice;
			for(; i < tabDeplacements.length; i++){
				if(tabDeplacements[i].timeS >= temps)
					break;
			}
			
			var res:Etat = null;
			
			if(i == tabDeplacements.length){
				//La voiture n'a plus aucun deplacement. On ne l'affiche plus
			} else if(i == 0) {
				//Alors la voiture a pas encore commencé a bouger, on l'affiche pas.
			} else if(tabDeplacements[i].timeS == temps){
				res = tabDeplacements[i].etat;
			} else {
				var decalage:Number = (temps-tabDeplacements[i-1].timeS)/(tabDeplacements[i].timeS-tabDeplacements[i-1].timeS);
				var xP:Number = ((tabDeplacements[i].etat.X - tabDeplacements[i-1].etat.X) * decalage) + tabDeplacements[i-1].etat.X;
				var yP:Number = ((tabDeplacements[i].etat.Y - tabDeplacements[i-1].etat.Y) * decalage) + tabDeplacements[i-1].etat.Y;
				res = new Etat(xP, yP, tabDeplacements[i-1].etat.O);
			}
			
			lastIndice = i;
			
			return res;			
		}
	}
}