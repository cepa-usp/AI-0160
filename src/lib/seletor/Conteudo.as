package  seletor
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author Arthur
	 */
	public class Conteudo 
	{
		
		private var onLoaded:Function;
		private var _conteudo:XML;
		
		public function Conteudo(file:String, onLoaded:Function) 
		{
			this.onLoaded = onLoaded;
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, callOnLoaded);
			xmlLoader.load(new URLRequest(file));
		}
		
		private function callOnLoaded(e:Event):void 
		{
			this.conteudo = new XML(e.target.data);
			if (onLoaded != null) onLoaded.call();
		}
		
		public function get conteudo():XML 
		{
			return _conteudo;
		}
		
		public function set conteudo(value:XML):void 
		{
			_conteudo = value;
		}
		
		
		
	}

}