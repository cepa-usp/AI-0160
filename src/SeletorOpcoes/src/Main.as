package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Arthur
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			var lista:ListaOpcoes = new ListaOpcoes();
			var d1:DestinoOpcoes = new DestinoOpcoes(lista);
			d1.x = 100;
			d1.y = 200;
			addChild(d1);
			
			for (var i:int = 0; i < 10; i++) {
				lista.adicionarOpcao("teste oba oba")
				lista.adicionarOpcao("bla ble bli")
				lista.adicionarOpcao("toque toque")
				lista.adicionarOpcao("nheco nheco e também tic tic")				
			}
			lista.posicao = ListaOpcoes.POS_DIREITA;
			addChild(lista)

		}
		
	}
	
}