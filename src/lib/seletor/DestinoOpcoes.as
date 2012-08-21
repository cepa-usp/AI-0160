package  seletor
{
	import com.eclecticdesignstudio.motion.actuators.SimpleActuator;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import memorphic.xpath.XPathQuery;
	/**
	 * ...
	 * @author Arthur
	 */
	public class DestinoOpcoes extends Sprite
	{
		private static var idcount:int = 0;
		private var _minAltura:int = 20;		
		private var _id:int;
		private var _largura:int = 200;
		private var _foco:Boolean = false;
		private var _listaOpcoes:ListaOpcoes;
		private var _txformat:TextFormat = null;
		private var qtMaxOpcoes:int = 0;
		private var dicValidos:Dictionary = new Dictionary();
		private var _posicao:int = ListaOpcoes.POS_DIREITA
		private var _opcoes:Vector.<DestinoItem> = new Vector.<DestinoItem>();
		
		public function DestinoOpcoes(listaOpcoes:ListaOpcoes) 
		{
			this.listaOpcoes = listaOpcoes;
			this.id = DestinoOpcoes.getNewId();
			listaOpcoes.addEventListener(ListaOpcoesEvent.OPCAO_SELECIONADA, onOpcaoSelecionada);
			addEventListener(MouseEvent.CLICK, onClick);
			draw();
		}
		
		public static function getNewId():int {
			idcount++;
			return idcount;
		}
		
		
		public function definirEscopoValido(xpath:String, attr:String = ""):void {
			var query:XPathQuery = new XPathQuery(xpath);
			var result:XMLList = query.exec(listaOpcoes.conteudo.conteudo)
			qtMaxOpcoes = 0;
			dicValidos = new Dictionary();
			for each (var r:XML in result) {
				if (attr == "") {
					adicionarValido(r[0]);
				} else {
					adicionarValido(r.attribute(attr))
				}
				
			}			
		}
		
		private function adicionarValido(text:String):void 
		{
			dicValidos[text] = false;
			qtMaxOpcoes++;
		}
		
		public function avaliar():int {
			var qtCorretas:int = 0; 
			for each (var o:Opcao in opcoes) {
				if (dicValidos[o.texto] == true) {
					qtCorretas++;
				} 
			}
			return qtCorretas;
		}
		
		private function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(0xFFFF00, 0.6);
			
			if (foco) {
				this.graphics.lineStyle(2, 0x800000, 0.9);	
			} else {
				this.graphics.lineStyle(2, 0xFF8000, 0.6);					
			}
			this.graphics.drawRoundRect(0, 0, largura, Math.max(minAltura, this.height), 10, 10);
			
		}
		
		public function loadData(o:Object):void {
			this.id = o.id;
			this.opcoes  = new Vector.<DestinoItem>();
			for (var i:int = 0; i < o.qtOpcoes; i++) {
				var opd:Object = o.opcoes[i.toString()];
				adicionarOpcao(opd.texto);
			}
		}
		
		public function saveData():Object {
			var destino:Object = new Object();
			destino.id = this.id;
			destino.qtOpcoes = opcoes.length;
			var op:Object = new Object();
			var q:int = 0;
			for each (var o:DestinoItem in this.opcoes) {
				op[q.toString()] = o.opcao.getSerialData();
			}
			destino.opcoes = op;
			return destino;
		}

		
		public function removeItem(item:DestinoItem):void {
			opcoes.splice(opcoes.indexOf(item), 1);
			item.opcao.selecionado = false;
			item.opcao.qtdeUsada--;
			refreshItems();
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
				opcao.qtdeUsada--;
				return;
			}
			var op:DestinoItem = new DestinoItem(opcao, this);
			if (txformat != null) op.setTextFormat(txformat);
			op.largura = largura;
			opcoes.push(op);
			refreshItems();
			
			
		}
		
		public function refreshItems():void {
			for (var i:int = numChildren - 1; i >= 0; i--) removeChildAt(i);
			var pos:int = 0;			
			for each (var op:DestinoItem in opcoes) {				
				addChild(op);
				op.y = pos;
				pos += op.altura;				
			}
			draw();
		}		
		public function onClick(e:MouseEvent):void {
			//if (this.foco) return;
			this.setFoco();
			if (ListaOpcoes.listaOpcaoAtiva == listaOpcoes) return;
			listaOpcoes.show(posicao);
			
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
		
		public function get txformat():TextFormat 
		{
			return _txformat;
		}
		
		public function set txformat(value:TextFormat):void 
		{
			_txformat = value;
			for each(var o:DestinoItem in opcoes) {
				o.setTextFormat(value);
			}
		}
		
		public function get id():int 
		{
			return _id;
		}
		
		public function set id(value:int):void 
		{
			_id = value;
		}
		
		public function get posicao():int 
		{
			return _posicao;
		}
		
		public function set posicao(value:int):void 
		{
			_posicao = value;
		}
		

		public function setFoco():void 
		{
			if (this.parent != null) {
				for (var i:int = 0; i < stage.numChildren; i++) {
					if(stage.getChildAt(i) is DisplayObjectContainer) removeListas(DisplayObjectContainer(stage.getChildAt(i)))
				}
				
			}
			_foco = true;
			draw()
		}
		
		public function removeListas(p:DisplayObjectContainer) {
				
				for (var i:int = 0; i < p.numChildren; i++) {
					if (p.getChildAt(i) is DestinoOpcoes) {
						DestinoOpcoes(p.getChildAt(i)).removeFoco();
					} else if (p.getChildAt(i) is DisplayObjectContainer) {
						removeListas(DisplayObjectContainer(p.getChildAt(i)));
					}
				}
		}
		
		public function removeFoco():void {
			_foco = false;
			draw()
		}
	}

}