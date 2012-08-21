package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Arthur
	 */
	public class Main extends Sprite 
	{
		private var c:Conteudo;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			c = new Conteudo("divcel.xml", onXMLLoaded);
			
			

		}
		
		public function onXMLLoaded():void {
			var lista:ListaOpcoes = new ListaOpcoes(c);
			var lista2:ListaOpcoes = new ListaOpcoes(c);
			
			var d1:DestinoOpcoes = new DestinoOpcoes(lista);
			d1.txformat = new TextFormat("arial", 15, 0x400000, true);
			var d2:DestinoOpcoes = new DestinoOpcoes(lista2);
			
			d1.x = 100;
			d1.y = 200;
			addChild(d1);
			d2.x = 250
			d2.y = 300
			addChild(d2)
			
			lista.definirConteudo("data/etapa[@id='meiose']/fase", "nome");
			lista2.definirConteudo("data/etapa[@id='meiose']/fase/label", "");
			
			d1.definirEscopoValido("data/etapa[@id='meiose']/fase[@nome='Intérfase']", "nome");
			d2.definirEscopoValido("data/etapa[@id='meiose']/fase[@nome='Metáfase I']/label", "");

			lista.posicao = ListaOpcoes.POS_ESQUERDA;
			addChild(lista2)			

			
			lista2.posicao = ListaOpcoes.POS_ESQUERDA;
			addChild(lista)
		}
		
	}
	
}