package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.events.BaseEvent;
	import BaseAssets.tutorial.CaixaTexto;
	import com.adobe.protocols.dict.DictionaryServer;
	import com.adobe.serialization.json.JSON;
	import cepa.utils.ToolTip;
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
		
		override protected function init():void 
		{
			criaConexoes();
			c = new Conteudo("divcel.xml", criarTelas);
			criaRespostas();
			//stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			//player.source = "http://cepa.if.usp.br/ivan/teste_streaming/Teste.flv";
			player.source = "http://repz.kinghost.net/testes/mitoseemeiose2.flv";
			player.playWhenEnoughDownloaded();
			player.addEventListener(MetadataEvent.CUE_POINT, cuePointListener);
			player.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, onPlay);
			player.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, criaCuePointMarkers);
			player.addEventListener(VideoEvent.SCRUB_START, onScrub);
			//player.addEventListener(VideoEvent.BUFFERING_STATE_ENTERED, testeCue);
			
			//Actuate.timer(1).onComplete(criaCuePointMarkers);
		}
		
		private function onScrub(e:VideoEvent):void 
		{
			trace("onScrub");
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
		}
		
		public function criarTelas():void {
			listaFases = new ListaOpcoes(c);
			listaDetalhes = new ListaOpcoes(c);
			listaDna = new ListaOpcoes(c);			

			
			listaFases.definirConteudo("data/etapa[@id='meiose']/fase", "nome");
			listaDetalhes.definirConteudo("data/etapa[@id='meiose']/fase/label", "");
			listaDna.definirConteudo("data/etapa[@id='meiose']/fase/dna", "");

			dictTelas = new Dictionary();
			var txformatTitulo:TextFormat = new TextFormat("arial", 15, 0x400000, true); // foprmato dos titulos
			var txformatDNA:TextFormat = new TextFormat("arial", 19, 0x400000, true); // foprmato dos dna
			
			for (var i:int = 1; i <= nCamadas; i++) {
				var classe:Class = Class(getDefinitionByName("CamadaTexto" + String(i)));
				var tela:MovieClip = new classe();
				tela.x = rect.width / 2;
				tela.y = rect.height / 2;
				layerAtividade.addChild(tela);				
				tela.visible = false;
				
				dictTelas[i] = tela;

				var d1:DestinoOpcoes = criarDestinoOpcoes(listaFases, tela.m1, txformatTitulo)
				d1.definirEscopoValido("data/etapa/fase[@etapa='" + i.toString() + "']", "nome");
				var d2:DestinoOpcoes = criarDestinoOpcoes(listaDetalhes, tela.m2, null, ListaOpcoes.POS_ESQUERDA)
				d2.definirEscopoValido("data/etapa/fase[@etapa='" + i.toString() + "']/label", "");			
				var d3:DestinoOpcoes = criarDestinoOpcoes(listaDna, tela.m3, txformatDNA)
				d3.definirEscopoValido("data/etapa/fase[@etapa='" + i.toString() + "']/dna", "");				
				vetorDestinos.push(d1, d2, d3);
			}	
			
			listaFases.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaFases)
			listaDetalhes.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaDetalhes)			
			listaDna.posicao = ListaOpcoes.POS_DIREITA;
			layerAtividade.addChild(listaDna)		
			stage.addEventListener(MouseEvent.CLICK, removerListas);
			
		}
		
		private function removerListas(e:MouseEvent):void 
		{
			if (e.target is DestinoOpcoes) return;
			if (e.target is Opcao) return;
			
			trace(e.target, e.target.name);
			for each (var d:DestinoOpcoes in vetorDestinos) d.removeFoco();
			if (ListaOpcoes.listaOpcaoAtiva != null) {
				ListaOpcoes.listaOpcaoAtiva.hide();
			}
		}
		
		public function criarDestinoOpcoes(listabase:ListaOpcoes, marcador:MovieClip, txformat:TextFormat=null, posicaodalista:int=ListaOpcoes.POS_DIREITA):DestinoOpcoes {
			var d:DestinoOpcoes = new DestinoOpcoes(listabase);
			d.txformat = txformat;
			//d.posicaoLista = ??
			d.x = -d.width / 2;
			d.y = -d.height / 2;
			d.posicao = posicaodalista;
			marcador.addChild(d);
			return d;
			
		}
		
		private function criaConexoes():void 
		{
			player = _player;
			layerAtividade.addChild(player);
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
				cuePoint.x = posX;
				cuePoint.y = posYMark;
				cuePoint.addEventListener(MouseEvent.CLICK, cuePointClick);
				cuePoint.buttonMode = true;
				cuePoints.push(cuePoint);
				layerAtividade.addChild(cuePoint);
			}
		}
		
		private function removeTela():void
		{
			if (currentTela != null) {
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
				player.seek(obj.time);
			}else{
				player.seek(obj.time);
			}
			
			
			mudaTela();//player.playheadTime
			

		}
		
		private var posYMark:Number = 516;
		private var cuePoints:Array = [];
		
		/**
		 * Função que recebe os eventos de cue points
		 * @param	e
		 */
		private function cuePointListener(e:MetadataEvent):void 
		{
			if (cuePointsStop.selected == false) return;
			
			player.pause();
			//player.seek(e.info.time);
			telaAtual = int(e.info.name);
			
			selecionaTela(telaAtual);
		}
		
		private function selecionaTela(telaAtual:int):void 
		{
			removeTela();
			
			currentTela = dictTelas[telaAtual];
			currentTela.visible = true;
		}
		
		private function respostaCerta():Boolean 
		{
			return true;
		}
		
		override public function reset(e:MouseEvent = null):void
		{
			
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
								"Arraste as \"Causas\" e \"Consequências\" para os locais corretos.", 
								"Vecê terá NADA para isso."];
				
				pointsTuto = 	[new Point(590, 405),
								new Point(315 , 250),
								new Point(325 , 210)];
								
				tutoBaloonPos = [[CaixaTexto.RIGHT, CaixaTexto.FIRST],
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
		private var listaFases:ListaOpcoes;
		private var listaDetalhes:ListaOpcoes;
		private var listaDna:ListaOpcoes;
		private var telaParaSelecionar:int = -1;
		
		/**
		 * @private
		 * Inicia a conexão com o LMS.
		 */
		private function initLMSConnection () : void
		{
			completed = false;
			connected = false;
			scorm = new SCORM();
			
			pingTimer = new Timer(PING_INTERVAL);
			pingTimer.addEventListener(TimerEvent.TIMER, pingLMS);
			
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
					pingTimer.start();
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
				if (connected) {
					
					if (scorm.get("cmi.mode" != "normal")) return;
					
					//saveStatusForRecovery();
					scorm.set("cmi.suspend_data", mementoSerialized);
					commit();
				}else {//LocalStorage
					//saveStatusForRecovery();
					ExternalInterface.call("save2LS", mementoSerialized);
				}
			}
		}
		
	}

}