package  seletor
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Arthur
	 */
	public class ListaOpcoesEvent extends Event 
	{
		static public const OPCAO_SELECIONADA:String = "opcaoSelecionada";
		private var _opcao:Opcao;
		
		public function ListaOpcoesEvent(type:String, opcao:Opcao, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.opcao = opcao;
			
		} 
		
		public override function clone():Event 
		{ 
			return new ListaOpcoesEvent(type, _opcao, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ListaOpcoesEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
		public function get opcao():Opcao 
		{
			return _opcao;
		}
		
		public function set opcao(value:Opcao):void 
		{
			_opcao = value;
		}
		
	}
	
}