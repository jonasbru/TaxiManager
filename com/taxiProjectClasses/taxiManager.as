package com.taxiProjectClasses{

	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import fl.motion.Source;
	import flash.display.Loader;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.Shape;
	import flash.display.MovieClip;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.*;

	public class taxiManager extends Sprite {

		var tabV:Array = new Array();
		var tabVoitures:Array = new Array();

		//Variables utiles pour la bidouille lors du chargement, pour countourner les 15".
		var count:Number=0;
		var timerLoading:Timer=new Timer(15000,0);
		var tab1:Array;

		var scene:Shape = new Shape();
		//trace(scene.parent);
		var myMC:MovieClip = new MovieClip();

		var timerSynchro:Timer;

		var loader:URLLoader = new URLLoader ();

		var adresse:URLRequest=new URLRequest("H:/UTBM/IN42/TaxiManager/img/paris2.jpg");
		var chargeur:Loader = new Loader();

		public function taxiManager() {
			trace("ohe je passe par la");
			init();
		}

		private function init() {
			timerLoading.addEventListener(TimerEvent.TIMER, chargerVoitures );
			//timerLoading.start();


			//trace(scene.parent);
			var myMC:MovieClip = new MovieClip();
			myMC.addChild(scene);


			scene.alpha=0.5;


			chargeur.contentLoaderInfo.addEventListener(Event.COMPLETE, imgComplete);
			chargeur.load(adresse);
			myMC.addChildAt(chargeur, 0);
			
			//trace(SPScene.numChildren);
			SPScene.source=myMC;

			//SPScene.horizontalScrollPosition=200;

			/*trace(scene.parent +"+"+ SPScene.numChildren);
			for (var iii:Number = 0; iii < SPScene.numChildren; iii++) {
			trace(SPScene.getChildAt(iii).toString());
			}*/


			timerSynchro=new Timer(1,86400);
			timerSynchro.addEventListener(TimerEvent.TIMER, deplacerVehicules);
			//timerSynchro.start();


			loader.dataFormat=URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, finChargement);
			loader.addEventListener(IOErrorEvent.IO_ERROR, indiquerErreur);
			loader.addEventListener(ProgressEvent.PROGRESS, avancement);

			zomm_sl.addEventListener(Event.CHANGE, onZoom);

			//chargerRandVehicules(30000);
			//chargerVehicules("data/gps_trace_091005.pos");
			//chargerVehicules("data/test100000.pos");
			chargerVehicules("data/test10000.pos");
		}



		//##################Fonctions##################
		function finChargement(event:Event):void {
			var donnees:String=loader.data;

			tab1=donnees.split("\n");

			for (var k:int = 0; k < tab1.length-1; k++) {
				tab1[k]=tab1[k].split(" ");
				tab1[k][1]=tab1[k][1].split(":");
			}

			timerLoading.start();
		}

		function imgComplete(evt:Event) {
			chargeur.width=evt.currentTarget.width;
			chargeur.height=evt.currentTarget.height;

			//myMC.x = (SPScene.width - evt.currentTarget.width) / 2 ;
			//myMC.y = (SPScene.height - evt.currentTarget.height) / 2 ;

			trace(SPScene.numChildren);
			for(var i:int = 0 ; i < SPScene.numChildren; i++)
				trace(SPScene.getChildAt(i) + " - " + i);
			//SPScene.update();
		}

		function chargerVoitures(event:TimerEvent) {
			textBox.text = Math.floor((count+1)*100 / tab1.length) + "% " + count;
			var debut:Number=getTimer();

			var heuresEnS:int;
			var minEnS:int;
			var sec:int;

			var i:int=count;

			for (i; i < tab1.length-1 && getTimer() - debut < 14000; i++) {
				heuresEnS=tab1[i][1][0]*60*60;
				minEnS=tab1[i][1][1]*60;
				sec=tab1[i][1][2];

				var seconde:int=heuresEnS+minEnS+sec;
				tabV[seconde] = new Array();

				var b:Boolean=true;
				if (tab1[i][5].charAt(0)=='A') {
					b=false;
				}

				var e:Etat = new Etat(Math.floor((tab1[i][3] - 586699)/16.25244140625), Math.floor((tab1[i][4]-2411196)/16.25244140625), b);

				var v:Voiture=chercheVoiture(tab1[i][2]);

				if (v==null) {
					v=new Voiture(tab1[i][2]);
					tabVoitures.push(v);
				}

				v.tabDeplacements.push(new EtatT(e, seconde));

				tabV[seconde].push(new Instant(e, v));

				heuresEnS=minEnS=sec=0;
			}

			count=i;
			if (count>=tab1.length-1) {
				timerLoading.stop();
				timerSynchro.start();
				SPScene.update();
			}
		}

		function chercheVoiture(id:int):Voiture {
			var v:Voiture=null;

			var bStop:Boolean=false;
			for (var j:int = 0; j < tabVoitures.length && bStop == false; j++) {
				if (id==tabVoitures[j].id) {
					v=tabVoitures[j];
					bStop=true;
				}
			}

			return v;
		}

		function avancement(event:Event) {
			textBox.text = Math.floor((event.target.bytesLoaded*100)/event.target.bytesTotal) + "%";
		}

		function indiquerErreur( event:Event ) {
			trace(event);
		}

		function chargerVehicules(nomDuDossier:String) {
			loader.load(new URLRequest(nomDuDossier));
		}

		function onZoom(evt:Event):void {
			if (SPScene.content) {
				SPScene.content.scaleX = SPScene.content.scaleY = (11 - zomm_sl.value)/10;
				SPScene.update();
			}
		}


		function chargerRandVehicules(nbDeplacements:int) {
			for (var i:int = 0; i < nbDeplacements; i++) {
				tabV[i] = new Array();

				for (var j:int = 0; j < Math.ceil(Math.random()*20); j++) {
					var b:Boolean=false;
					if (Math.random()>0.4) {
						b=true;
					}

					var e:Etat=new Etat(Math.ceil(Math.random()*400),Math.ceil(Math.random()*400),b);
					var v:Voiture;

					var r:Number=Math.random();
					if (r>0.3&&tabVoitures.length>20) {
						v = tabVoitures[Math.ceil(Math.random()*(tabVoitures.length-1))];
					} else {
						v=new Voiture(i*j);
						tabVoitures.push(v);
					}

					v.tabDeplacements.push(new EtatT(e, i));
					tabV[i].push(new Instant(e, v));
				}
			}
		}

		function deplacerVehicules(event:TimerEvent) {
			if (tabV[timerSynchro.currentCount]!=null) {
				for (var i:int = 0; i < tabV[timerSynchro.currentCount].length; i++) {
					if (tabV[timerSynchro.currentCount][i].voiture.etat!=null&&timerSynchro.currentCount-tabV[timerSynchro.currentCount][i].voiture.lastUpdate<900) {
						if (tabV[timerSynchro.currentCount][i].voiture.etat.O==true) {
							scene.graphics.lineStyle(1, 0x990000, 1);
						} else {
							scene.graphics.lineStyle(1, 0x009900, 1);

						}
						scene.graphics.moveTo(tabV[timerSynchro.currentCount][i].voiture.etat.X, tabV[timerSynchro.currentCount][i].voiture.etat.Y);
						scene.graphics.lineTo(tabV[timerSynchro.currentCount][i].etat.X, tabV[timerSynchro.currentCount][i].etat.Y);

						//trace(scene.parent +"+"+ SPScene.numChildren+"+"+scene.x + "-"+scene.y+"+"+"+"+scene.width + "-"+scene.height);
						/*for (var iii:Number = 0; iii < SPScene.numChildren; iii++) {
						trace(SPScene.getChildAt(iii).toString());
						}*/
						//trace(SPScene.horizontalScrollPosition );
						/*scene.x = scene.width /2;
						scene.y = scene.height /2;*/

						/*SPScene.refreshPane();*/
						//SPScene.update();
						//trace(tabV[timerSynchro.currentCount][i].voiture.id+":"+tabV[timerSynchro.currentCount][i].voiture.etat.X +"-"+tabV[timerSynchro.currentCount][i].etat.X);
					}

					tabV[timerSynchro.currentCount][i].voiture.etat=tabV[timerSynchro.currentCount][i].etat;
					tabV[timerSynchro.currentCount][i].voiture.lastUpdate=timerSynchro.currentCount;
				}
				//trace(tabVoitures.length + ":" + tabV.length+":"+tabV[timerSynchro.currentCount].length);
			}

			textBox.text="heure:"+Math.floor(timerSynchro.currentCount/60/60)+":"+Math.floor(timerSynchro.currentCount/60%60)+":"+timerSynchro.currentCount%60%60;
		}
	}
}