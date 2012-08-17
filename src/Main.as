package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.events.BaseEvent;
	import BaseAssets.tutorial.CaixaTexto;
	import com.adobe.serialization.json.JSON;
	import cepa.utils.ToolTip;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Linear;
	import fl.transitions.easing.None;
	import fl.transitions.Tween;
	import fl.video.FLVPlayback;
	import fl.video.MetadataEvent;
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
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	import pipwerks.SCORM;
	
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
		private var nCamadas:int = 11;
		private var telaAtual:int;
		
		override protected function init():void 
		{
			criaConexoes();
			criaRespostas();
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			block.visible = false;
			continua.visible = false;
			continua.addEventListener(MouseEvent.CLICK, playAgain);
			
			player.source = "http://cepa.if.usp.br/ivan/teste_streaming/Teste.flv";
			player.playWhenEnoughDownloaded();
			player.addEventListener(MetadataEvent.CUE_POINT, cuePointListener);
			
			stage.addEventListener(MouseEvent.CLICK, clickTrace);
		}
		
		private function clickTrace(e:MouseEvent):void 
		{
			
		}
		
		private function criaConexoes():void 
		{
			player = _player;
			layerAtividade.addChild(player);
			layerAtividade.addChild(block);
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
		
		private function keyUpHandler(e:KeyboardEvent):void 
		{
			if (e.target.name == "texto") {
				var posTela:int = int(e.target.parent.name.replace("m", ""));
				
				var caixas:Array = respostas[telaAtual].caixasTexto;
				var textos:Array = respostas[telaAtual].textos;
				var index:int = caixas.indexOf(e.target.parent.name);
				if (index == -1) {
					caixas.push(e.target.parent.name);
					textos.push(e.target.text);
				}else {
					textos[index] = e.target.text;
				}
			}
		}
		
		private var posYMark:Number = 525;
		private var cuePoints:Array = [];
		private function cuePointListener(e:MetadataEvent):void 
		{
			player.pause();
			continua.visible = true;
			block.visible = true;
			
			var posX:Number = player.x + player.seekBar.x + (player.playheadPercentage / 100 * player.seekBar.width);
			var hasPosition:Boolean = false;
			
			lookPos: for each (var item:DisplayObject in cuePoints) 
			{
				if (Math.abs(item.x - posX) < 2) {
					hasPosition = true; 
					break lookPos;
				}
			}
			
			if (!hasPosition) {
				trace("entrou");
				var cuePoint:CuePointMarker = new CuePointMarker();
				cuePoint.x = posX;
				cuePoint.y = posYMark;
				cuePoints.push(cuePoint);
				layerAtividade.addChild(cuePoint);
			}
			
			telaAtual = int(e.info.parameters.teste);
			//var nCue:int = int(e.info.name);
			
			var classe:Class = Class(getDefinitionByName("CamadaTexto" + String(telaAtual)));
			currentTela = new classe();
			currentTela.x = rect.width / 2;
			currentTela.y = rect.height / 2;
			layerAtividade.addChild(currentTela);
			recuepraTela(currentTela);
			
			//Actuate.timer(2).onComplete(playAgain);
		}
		
		private function recuepraTela(tela:MovieClip):void 
		{
			if (respostas[telaAtual].caixasTexto.length > 0) {
				var caixas:Array = respostas[telaAtual].caixasTexto;
				var textos:Array = respostas[telaAtual].textos;
				
				for (var i:int = 0; i < caixas.length; i++) 
				{
					currentTela[caixas[i]].texto.text = textos[i];
				}
			}
			
		}
		
		private function playAgain(e:MouseEvent):void 
		{
			//player.playVideo();
			continua.visible = false;
			block.visible = false;
			layerAtividade.removeChild(currentTela);
			currentTela = null;
			player.play();
		}

		function onPlayerError(event:Event):void {
			// Event.data contains the event parameter, which is the error code
			trace("player error:", Object(event).data);
		}

		function onPlayerStateChange(event:Event):void {
			// Event.data contains the event parameter, which is the new player state
			trace("player state:", Object(event).data);
		}

		function onVideoPlaybackQualityChange(event:Event):void {
			// Event.data contains the event parameter, which is the new video quality
			trace("video quality:", Object(event).data);
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