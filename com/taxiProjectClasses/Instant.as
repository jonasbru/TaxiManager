package com.taxiProjectClasses {
	
	public class Instant {
		public var etat:Etat = null;
		public var voiture:Voiture = null;

		public function Instant(e:Etat, v:Voiture) {
			this.etat = e;
			this.voiture = v;
		}

	}
	
}
