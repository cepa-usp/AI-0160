package  
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Arthur
	 */
	public class DestinoOpcoes extends Sprite
	{
		private var _minAltura:int = 20;
		private var _largura:int = 200;
		private var _foco:Boolean = false;
		private var _listaOpcoes:ListaOpcoes;
		private var qtMaxOpcoes:int = 3;
		private var _opcoes:Vector.<DestinoItem> = new Vector.<DestinoItem>();
		public function DestinoOpcoes(listaOpcoes:ListaOpcoes) 
		{
			this.listaOpcoes = listaOpcoes;
			listaOpcoes.addEventListener(ListaOpcoesEvent.OPCAO_SELECIONADA, onOpcaoSelecionada);
			addEventListener(MouseEvent.CLICK, onClick);
			draw();
		}
		
		private function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(0xFFFF00, 0.6);
			this.graphics.drawRect(0, 0, largura, Math.max(minAltura, this.height));
		}
		
		private function onOpcaoSelecionada(e:ListaOpcoesEvent):void 
		{
			if (!this.foco) return;
			adicionarOpcao(e.opcao);
		}
		
		private function adicionarOpcao(opcao:Opcao):void 
		{
			if (qtMaxOpcoes <= opcoes.length) {
				opcao.selecionado = false;
				return;
			}
			var op:DestinoItem = new DestinoItem(opcao);
			var pos:int = 0;
			for each (var i:DestinoItem in opcoes) pos += 30;			
			opcoes.push(op);
			addChild(op);
			op.y = pos;
			draw();
		}
		
		public function onClick(e:MouseEvent):void {
			if (this.foco) return;
			this.setFoco();
			listaOpcoes.show();
			
		}
		
		public function get foco():Boolean 
		{
			return _foco;
		}
		
		public function get minAltura():int 
		{
			return _minAltura;
		}
		
		public function set minAltura(value:int):void 
		{
			_minAltura = value;
		}
		
		public function get largura():int 
		{
			return _largura;
		}
		
		public function set largura(value:int):void 
		{
			_largura = value;
		}
		
		public function get listaOpcoes():ListaOpcoes 
		{
			return _listaOpcoes;
		}
		
		public function set listaOpcoes(value:ListaOpcoes):void 
		{
			_listaOpcoes = value;
		}
		
		public function get opcoes():Vector.<DestinoItem> 
		{
			return _opcoes;
		}
		
		public function set opcoes(value:Vector.<DestinoItem>):void 
		{
			_opcoes = value;
		}
		

		public function setFoco():void 
		{
			_foco = true;
		}
		
	}

}