package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.events.BaseEvent;
	import BaseAssets.tutorial.CaixaTexto;
	import com.adobe.protocols.dict.DictionaryServer;
	import com.adobe.serialization.json.JSON;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Linear;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import fl.video.FLVPlayback;
	import fl.video.MetadataEvent;
	import fl.video.VideoEvent;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	import memorphic.xpath.XPathQuery;
	import pipwerks.SCORM;
	import seletor.Conteudo;
	import seletor.DestinoItem;
	import seletor.DestinoOpcoes;
	import seletor.ListaOpcoes;
	import seletor.Opcao;
	
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private var player:FLVPlayback;
		private var loader:Loader = new Loader();
		
		private var respostas:Object;
		private var camadasTexto:Vector.<MovieClip> = new Vector.<MovieClip>();
		private var currentTela:MovieClip;
		private var nCamadas:int = 14;
		private var telaAtual:int;
		private var vetorDestinos:Vector.<DestinoOpcoes> = new Vector.<DestinoOpcoes>();
		private var c:Conteudo;
		private var dictTelas:Dictionary;
		private var xmlLoaded:Boolean = false;
		private var videoReady:Boolean = false;
		private var sprTutorial:Sprite = new Sprite();
		private var listaFasesMeiose:ListaOpcoes;
		private var listaDetalhesMeiose:ListaOpcoes;
		private var listaDnaMeiose:ListaOpcoes;

		private var listaFasesMitose:ListaOpcoes;
		private var listaDetalhesMitose:ListaOpcoes;
		private var listaDnaMitose:ListaOpcoes;
		
		private var telaParaSelecionar:int = -1;
		
		override protected function init():void 
		{
			criaConexoes();
			c = new Conteudo("divcel.xml", criarTelas);
			criaRespostas();
			//stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			fase.text = "Meiose";
			
			player.source = "http://midia.atp.usp.br/atividades-interativas/AI-0160/video/mitoseemeiose.flv";
			
			//player.source = "http://repz.kinghost.net/testes/mitoseemeiose2.flv";
			player.playWhenEnoughDownloaded();
			player.addEventListener(MetadataEvent.CUE_POINT, cuePointListener);
			player.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, onPlay);
			player.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, criaCuePointMarkers);
			player.addEventListener(VideoEvent.SCRUB_START, onScrub);
			player.addEventListener(VideoEvent.SCRUB_FINISH, onScrubFinish);
			//player.addEventListener(VideoEvent.BUFFERING_STATE_ENTERED, testeCue);
			
			//Actuate.timer(1).onComplete(criaCuePointMarkers);
			if (ExternalInterface.available) {
				initLMSConnection();
			}
			orientacoesScreen.btTutorial.addEventListener(MouseEvent.CLICK, onBtTutorialClick);
			
			for each (var bt:Sprite in botoes.buttons) {
				bt.addEventListener(MouseEvent.CLICK, function() {
					player.pause();
				})				
			}
				
			orientacoesScreen.btIniciar.addEventListener(MouseEvent.CLICK, onBtIniciarClick);
			orientacoesScreen.openScreen();
			//iniciaTutorial();
		}
		
		private function onBtIniciarClick(e:MouseEvent):void 
		{
			player.play();
			orientacoesScreen.closeScreen(null);
		}
		
		
		
		private function onBtTutorialClick(e:MouseEvent):void 
		{
			carregarTutorial()
		}
		
		private function carregarTutorial():void 
		{
			var tut:TutorialPlayer = new TutorialPlayer();
			sprTutorial.graphics.clear();
			sprTutorial.graphics.beginFill(0, 0.8);
			sprTutorial.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			
			sprTutorial.addChild(tut.player)
			tut.player.scaleX = 1.5;
			tut.player.scaleY = 1.5;
			tut.player.x = sprTutorial.width / 2 - tut.player.width / 2;
			tut.player.y = sprTutorial.height / 2 - tut.player.height / 2;
			
			sprTutorial.addEventListener(MouseEvent.CLICK, onSprTutorialClick);
			//sprTutorial.player.seek(0);
			//sprTutorial.player.play();
			sprTutorial.visible = true;
		}
		
		private function onSprTutorialClick(e:MouseEvent):void 
		{			
			sprTutorial.visible = false;
			sprTutorial.removeChild(sprTutorial.getChildByName("player"));
		}
		
		private function mudaMarcadorCuePoint(e:Event):void 
		{
			if(currentTela != null){
				if (DestinoOpcoes(currentTela.m1.getChildByName("d1")).avaliar() == 100 &&
					DestinoOpcoes(currentTela.m2.getChildByName("d2")).avaliar() == 100 &&
					DestinoOpcoes(currentTela.m3.getChildByName("d3")).avaliar() == 100) 
				{
					cuePoints[telaAtual - 1].gotoAndStop(2);
					Actuate.effects(cuePoints[telaAtual - 1], 1).filter(0, { alpha: 1 } ).onComplete(backToNormal, telaAtual);
				}else {
					cuePoints[telaAtual - 1].gotoAndStop(1);
				}
				saveStatus();
			}
		}
		
		private function recoverCuePointsFrame():void
		{
			var tela:MovieClip;
			for (var i:int = 1; i <= nCamadas; i++) 
			{
				tela = dictTelas[i];
				if (DestinoOpcoes(tela.m1.getChildByName("d1")).avaliar() == 100 &&
					DestinoOpcoes(tela.m2.getChildByName("d2")).avaliar() == 100 &&
					DestinoOpcoes(tela.m3.getChildByName("d3")).avaliar() == 100) 
				{
					cuePoints[i - 1].gotoAndStop(2);
				}else {
					cuePoints[i - 1].gotoAndStop(1);
				}
			}
		}
		
		private function backToNormal(tela:int):void 
		{
			Actuate.effects(cuePoints[telaAtual - 1], 1).filter(0, { alpha: 0 } );
		}
		
		private function onScrubFinish(e:VideoEvent):void 
		{
			verificaFase();
		}
		
		private function onScrub(e:VideoEvent):void 
		{
			if (currentTela != null) removeTela();
			mudaTela();
		}
		
		private function mudaTela():void 
		{
			if (telaParaSelecionar > -1) {
				if (currentTela != null) removeTela();
				if(cuePointsStop.selected){
					player.pause();				
					selecionaTela(telaParaSelecionar);
				}
				telaParaSelecionar = -1;
			} 
			
		}
		
		private function onPlay(e:VideoEvent):void 
		{
			removeTela();
			verificaFase();
		}
		
		public function criarTelas():void {
			listaFasesMeiose = new ListaOpcoes(c);
			listaDetalhesMeiose = new ListaOpcoes(c);
			listaDnaMeiose = new ListaOpcoes(c);			

			listaFasesMitose = new ListaOpcoes(c);
			listaDetalhesMitose= new ListaOpcoes(c);
			listaDnaMitose = new ListaOpcoes(c);			

			
			listaFasesMeiose.definirConteudo("data/etapa[@id='meiose']/fase", "nome");
			listaDetalhesMeiose.definirConteudo("data/etapa[@id='meiose']/fase/label", "");
			listaDnaMeiose.definirConteudo("data/etapa[@id='meiose']/fase/dna", "");

			listaFasesMitose.definirConteudo("data/etapa[@id='mitose']/fase", "nome");
			listaDetalhesMitose.definirConteudo("data/etapa[@id='mitose']/fase/label", "");
			listaDnaMitose.definirConteudo("data/etapa[@id='mitose']/fase/dna", "");			
			

			dictTelas = new Dictionary();
			var txformatTitulo:TextFormat = new TextFormat("arial", 15, 0x400000, true); // foprmato dos titulos
			var txformatLabels:TextFormat = new TextFormat("arial", 11, 0x400000, true); // foprmato dos titulos
			var txformatDNA:TextFormat = new TextFormat("arial", 19, 0x400000, true); // foprmato dos dna
			
			for (var i:int = 1; i <= nCamadas; i++) {
				var classe:Class = Class(getDefinitionByName("CamadaTexto" + String(i)));
				var tela:MovieClip = new classe();
				tela.x = rect.width / 2;
				tela.y = rect.height / 2;
				layerAtividade.addChild(tela);				
				tela.visible = false;
				
				dictTelas[i] = tela;
				
				var d1:DestinoOpcoes = criarDestinoOpcoes((i <= 9 ?listaFasesMeiose: listaFasesMitose), tela.m1, txformatTitulo)
				d1.name = "d1";
				d1.definirEscopoValido("data/etapa/fase[@etapa='" + i.toString() + "']", "nome");
				d1.addEventListener("valorAlterado", mudaMarcadorCuePoint);
				var d2:DestinoOpcoes = criarDestinoOpcoes((i <= 9 ?listaDetalhesMeiose: listaDetalhesMitose), tela.m2, txformatLabels, ListaOpcoes.POS_ESQUERDA)
				d2.name = "d2";
				d2.definirEscopoValido("data/etapa/fase[@etapa='" + i.toString() + "']/label", "");			
				d2.addEventListener("valorAlterado", mudaMarcadorCuePoint);
				var d3:DestinoOpcoes = criarDestinoOpcoes((i <= 9 ?listaDnaMeiose: listaDnaMitose), tela.m3, txformatDNA)
				d3.name = "d3";
				d3.definirEscopoValido("data/etapa/fase[@etapa='" + i.toString() + "']/dna", "");				
				d3.addEventListener("valorAlterado", mudaMarcadorCuePoint);
				vetorDestinos.push(d1, d2, d3);
			}	
			
			listaFasesMeiose.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaFasesMeiose)			
			listaDetalhesMeiose.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaDetalhesMeiose)			
			listaDnaMeiose.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaDnaMeiose)		

			
			listaFasesMitose.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaFasesMitose)			
			listaDetalhesMitose.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaDetalhesMitose)			
			listaDnaMitose.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaDnaMitose)	
			
			addChild(sprTutorial);
			
			stage.addEventListener(MouseEvent.CLICK, removerListas);
			
			xmlLoaded = true;
			recoverAfterReady();
		}
		

		
		private function removerListas(e:MouseEvent):void 
		{
			if (e.target is DestinoOpcoes) return;
			if (e.target is DestinoItem) return;
			if (e.target is Opcao) return;
			if (e.target is BtFechar) return;
			
			//trace(e.target, e.target.name);
			for each (var d:DestinoOpcoes in vetorDestinos) d.removeFoco();
			if (ListaOpcoes.listaOpcaoAtiva != null) {
				ListaOpcoes.listaOpcaoAtiva.hide();
			}
		}
		
		public function criarDestinoOpcoes(listabase:ListaOpcoes, marcador:MovieClip, txformat:TextFormat=null, posicaodalista:int=ListaOpcoes.POS_DIREITA):DestinoOpcoes {
			var d:DestinoOpcoes = new DestinoOpcoes(listabase);
			d.txformat = txformat;
			//d.posicaoLista = ??
			d.x = -d.largura / 2;
			d.y = -d.height / 2;
			d.posicao = posicaodalista;
			marcador.addChild(d);
			return d;
			
		}
		
		private function criaConexoes():void 
		{
			player = _player;
			layerAtividade.addChild(player);
			//player.playheadUpdateInterval = 20;
			//trace(player.playheadUpdateInterval);
		}
		
		private function criaRespostas():void 
		{
			respostas = new Object();
			
			for (var i:int = 1; i <= nCamadas; i++) 
			{
				respostas[String(i)] = new Object();
				respostas[String(i)].caixasTexto = [];
				respostas[String(i)].textos = [];
			}
		}
		
		private function criaCuePointMarkers(e:VideoEvent):void 
		{
			player.removeEventListener(VideoEvent.PLAYING_STATE_ENTERED, criaCuePointMarkers);
			
			var obj:Object;
			var time:Number;
			var totalTime:Number = player.totalTime;
			var posX:Number;
			
			for (var i:int = 1; i <= nCamadas; i++) 
			{
				obj = player.findCuePoint( { name:String(i) } );
				time = obj.time;
				
				posX = player.x + player.seekBar.x + (time / totalTime * player.seekBar.width);
				
				var cuePoint:CuePointMarker = new CuePointMarker();
				cuePoint.filters = [new GlowFilter(0x00FF00, 0, 10, 10, 3, 3)];
				cuePoint.x = posX;
				cuePoint.y = posYMark;
				cuePoint.addEventListener(MouseEvent.CLICK, cuePointClick);
				cuePoint.buttonMode = true;
				cuePoints.push(cuePoint);
				layerAtividade.addChild(cuePoint);
			}
			
			player.addASCuePoint(mitoseTime, "mudaFase");
			
			videoReady = true;
			recoverAfterReady();
			player.pause();
		}
		
		private function recoverAfterReady():void
		{
			if(xmlLoaded && videoReady){
				if (mementoSerialized != null) {
					if (mementoSerialized != "" && mementoSerialized != "null") {
						recoverStatus();
					}
				}
			}
		}
		
		private function removeTela():void
		{
			if (currentTela != null) {
				
				//mudaMarcadorCuePoint(null);
				
				currentTela.visible = false;
				currentTela = null;
			}
		}
		
		private function cuePointClick(e:MouseEvent):void 
		{
			//removeTela();
			
			var cP:CuePointMarker = CuePointMarker(e.target);
			var t:int = cuePoints.indexOf(cP) + 1;
			var obj:Object = player.findCuePoint( { name:String(t) } );
			telaParaSelecionar = t;
			if (cuePointsStop.selected) {
				player.pause();
				player.playheadTime = obj.time;
				//player.seek(obj.time);
			}else{
				player.seek(obj.time);
			}
			
			
			mudaTela();//player.playheadTime
			verificaFase();
			
		}
		
		private var mitoseTime:Number = 145;
		private function verificaFase():void
		{
			if (player.playheadTime > mitoseTime) {
				fase.text = "Mitose";
			}else {
				fase.text = "Meiose";
			}
		}
		
		private var posYMark:Number = 524;
		private var cuePoints:Array = [];
		
		/**
		 * Função que recebe os eventos de cue points
		 * @param	e
		 */
		private function cuePointListener(e:MetadataEvent):void 
		{
			if (e.info.name == "mudaFase") {
				fase.text = "Mitose";
			}else{
				if (cuePointsStop.selected == false) return;
				
				player.pause();
				//player.seek(e.info.time - 0.5);
				telaAtual = int(e.info.name);
				
				selecionaTela(telaAtual);
			}
		}
		
		private function selecionaTela(telaAtual:int):void 
		{
			removeTela();
			this.telaAtual = telaAtual;
			currentTela = dictTelas[telaAtual];
			currentTela.visible = true;
		}
		
		private function respostaCerta():Boolean 
		{
			return true;
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			for each (var item:DestinoOpcoes in vetorDestinos) 
			{
				item.reset();
			}
			score = 0;
		}
		
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array;
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			blockAI();
			
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto();
				layerTuto.addChild(balao);
				balao.visible = false;
				
				tutoSequence = ["Veja aqui as orientações.",
								"Ao iniciar o video ...", 
								"serão apresentadas marcas sobre a barra de tempo do video.",
								"Cada marca representa uma parado no video.",
								"Em cada parada aparecerão 3 caixas de texto...",
								"que deverão ser preenchidas de acordo com a lista de preenchimento de cada campo.",
								"A lista de preenchimento aparece ao clicar sobre o campo.",
								"Vecê terá NADA para isso."];
				
				pointsTuto = 	[new Point(560, 555),
								new Point(315 , 250),
								new Point(325 , 210)];
								
				tutoBaloonPos = [[CaixaTexto.BOTTON, CaixaTexto.LAST],
								["", ""],
								["", ""]];
			}
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			balao.addEventListener(BaseEvent.CLOSE_BALAO, iniciaAi);
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
				balao.visible = false;
				iniciaAi(null);
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
		
		public function calculaScore():int {
			var total:Number = 0;
			for each (var item:DestinoOpcoes in vetorDestinos) {
				total += item.avaliar()				
			}
			total /= vetorDestinos.length;
			return Math.round(total);
		}
		
		private function iniciaAi(e:BaseEvent):void 
		{
			balao.removeEventListener(BaseEvent.CLOSE_BALAO, iniciaAi);
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			unblockAI();
		}
		
		
		/*------------------------------------------------------------------------------------------------*/
		//SCORM:
		
		private const PING_INTERVAL:Number = 5 * 60 * 1000; // 5 minutos
		private var completed:Boolean;
		private var scorm:SCORM;
		private var scormExercise:int;
		private var connected:Boolean;
		private var score:int = 0;
		private var pingTimer:Timer;
		private var mementoSerialized:String = "";

		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			//pingTimer = new Timer(PING_INTERVAL);
			//pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
			connected = scorm.connect();
			
			if (connected) {
				
				if (scorm.get("cmi.mode" != "normal")) return;
				
				scorm.set("cmi.exit", "suspend");
				// Verifica se a AI já foi concluída.
				var status:String = scorm.get("cmi.completion_status");	
				mementoSerialized = scorm.get("cmi.suspend_data");
				var stringScore:String = scorm.get("cmi.score.raw");
				
				switch(status)
				{
					// Primeiro acesso à AI
					case "not attempted":
					case "unknown":
					default:
						completed = false;
						break;
					
					// Continuando a AI...
					case "incomplete":
						completed = false;
						break;
					
					// A AI já foi completada.
					case "completed":
						completed = true;
						//setMessage("ATENÇÃO: esta Atividade Interativa já foi completada. Você pode refazê-la quantas vezes quiser, mas não valerá nota.");
						break;
				}
				
				//unmarshalObjects(mementoSerialized);
				scormExercise = 1;
				score = Number(stringScore.replace(",", "."));
				
				var success:Boolean = scorm.set("cmi.score.min", "0");
				if (success) success = scorm.set("cmi.score.max", "100");
				
				if (success)
				{
					scorm.save();
					//pingTimer.start();
				}
				else
				{
					//trace("Falha ao enviar dados para o LMS.");
					connected = false;
				}
			}
			else
			{
				trace("Esta Atividade Interativa não está conectada a um LMS: seu aproveitamento nela NÃO será salvo.");
				mementoSerialized = ExternalInterface.call("getLocalStorageString");
			}
			
			//reset();
		}
		
		/**
		 * @private
		 * Salva cmi.score.raw, cmi.location e cmi.completion_status no LMS
		 */ 
		private function commit()
		{
			if (connected)
			{
				if (scorm.get("cmi.mode" != "normal")) return;
				
				// Salva no LMS a nota do aluno.
				var success:Boolean = scorm.set("cmi.score.raw", score.toString());

				// Notifica o LMS que esta atividade foi concluída.
				success = scorm.set("cmi.completion_status", (completed ? "completed" : "incomplete"));

				// Salva no LMS o exercício que deve ser exibido quando a AI for acessada novamente.
				success = scorm.set("cmi.location", scormExercise.toString());
				
				// Salva no LMS a string que representa a situação atual da AI para ser recuperada posteriormente.
				//mementoSerialized = marshalObjects();
				success = scorm.set("cmi.suspend_data", mementoSerialized.toString());
				
				if (score > 99) success = scorm.set("cmi.success_status", "passed");
				else success = scorm.set("cmi.success_status", "failed");

				if(completed){
			  		scorm.set("cmi.exit", "normal");
				} else {
			  		scorm.set("cmi.exit", "suspend");
				}

				if (success)
				{
					scorm.save();
				}
				else
				{
					pingTimer.stop();
					//setMessage("Falha na conexão com o LMS.");
					connected = false;
				}
			}else { //LocalStorage
				ExternalInterface.call("save2LS", mementoSerialized);
			}
		}
		
		/**
		 * @private
		 * Mantém a conexão com LMS ativa, atualizando a variável cmi.session_time
		 */
		private function pingLMS (event:TimerEvent)
		{
			//scorm.get("cmi.completion_status");
			commit();
		}
		
		private function saveStatus(e:Event = null):void
		{
			if (ExternalInterface.available) {
				saveStatusForRecovery();
				if (connected) {
					if (scorm.get("cmi.mode" != "normal")) return;
					scorm.set("cmi.suspend_data", mementoSerialized);
					commit();
				}else {//LocalStorage
					ExternalInterface.call("save2LS", mementoSerialized);
				}
			}
		}
		
		private function saveStatusForRecovery():void 
		{
			score = calculaScore();
			
			var destinos:Object  = { };
			destinos.qtde = vetorDestinos.length;
			var i:int = 0;
			var comp:Boolean = true;
			for each (var item:DestinoOpcoes in vetorDestinos) 
			{
				destinos[i.toString()] = item.saveData();
				if (item.opcoes.length == 0) comp = false;
				i++;
			}
			
			if (!completed) {
				completed = comp;
			}
			
			var obj:Object = { };
			obj.destinos = destinos;
			var s:String = JSON.encode(obj);
			
			mementoSerialized = s;
		}
		
		private function recoverStatus():void
		{
			var obj:Object = JSON.decode(mementoSerialized);
			var destinos:Object = obj.destinos;
			var qtde:int = destinos.qtde;
			
			for (var i:int = 0; i < qtde; i++) {
				var dest:Object = destinos[i.toString()];
				vetorDestinos[i].loadData(dest);
			}
			score = calculaScore();
			
			recoverCuePointsFrame();
		}
		
	}

}