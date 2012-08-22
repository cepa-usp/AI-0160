package  seletor
{
	import com.adobe.serialization.json.JSON;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.actuators.SimpleActuator;
	import com.eclecticdesignstudio.motion.easing.Linear;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.Font;
	import flash.text.TextField;
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
		private var _valoratual:int = 0;
		private var dicValidos:Dictionary = new Dictionary();
		private var layerResultado:Sprite = new Sprite();		
		private var _posicao:int = ListaOpcoes.POS_DIREITA
		private var _opcoes:Vector.<DestinoItem> = new Vector.<DestinoItem>();
		private var txformatNumeros:TextFormat = new TextFormat("arial", 12, 0xFFFFFF, true); // foprmato dos dna
		
		public function DestinoOpcoes(listaOpcoes:ListaOpcoes) 
		{
			this.listaOpcoes = listaOpcoes;
			layerResultado.name = "res"
			this.id = DestinoOpcoes.getNewId();
			listaOpcoes.addEventListener(ListaOpcoesEvent.OPCAO_SELECIONADA, onOpcaoSelecionada);
			addEventListener(MouseEvent.CLICK, onClick);
			drawResultado();
			draw();
			
		}
		
		public static function getNewId():int {
			idcount++;
			return idcount;
		}
		
		public function reset():void{
			for (var i:int = opcoes.length - 1; i >= 0; i-- ) 
			{
				var item:DestinoItem  = opcoes[i];
				removeItem(item);
			}
		}

		
		public function drawResultado() {
				layerResultado  = new Sprite();
				this.addChild(layerResultado);
				var tx:TextField = new TextField();
				tx.name = "tx"
				tx.mouseEnabled = false;
				tx.selectable = false;
				tx.width = 80;
				tx.defaultTextFormat = txformatNumeros;
				tx.height = 20;
				tx.filters = [new DropShadowFilter(2)]
				layerResultado.mouseEnabled = false;
				tx.multiline = false;
				layerResultado.addChild(tx);
				layerResultado.x = largura;
				layerResultado.y = -20;
				updateValor();
		}
		
		public function updateValor():void {
			Actuate.tween(this, 1, { valoratual:avaliar() } ).ease(Linear.easeNone).onUpdate(mudaTexto).onComplete(completeUpdate);
			//dispatchEvent(new Event("valorAlterado"));
		}
		
		private function completeUpdate():void 
		{
			dispatchEvent(new Event("valorAlterado"));
		}
		
		public function mudaTexto():void {
			TextField(layerResultado.getChildByName("tx")).text = valoratual.toString() + "%";
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
			for each (var o:DestinoItem in opcoes) {
				if (dicValidos[o.opcao.texto] == true) {
					qtCorretas++;
				} 
			}
			return Math.round((qtCorretas/qtMaxOpcoes) * 100);
		}
		
		private function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(0xFFFF00, 0.6);
			
			if (_foco) {
				this.graphics.lineStyle(2, 0x800000, 0.9);	
			} else {
				this.graphics.lineStyle(2, 0xFF8000, 0.6);					
			}
			this.graphics.drawRoundRect(0, 0, largura, Math.max(minAltura, calculaAltura()), 10, 10);
			//drawResultado();
		}
		
		public function calculaAltura():Number {
			
			
			var qtPreenchidos:int = opcoes.length;
			var qtFaltam:int = qtMaxOpcoes - qtPreenchidos;
			var tamanho:int = 0;
			for each (var item:DestinoItem in opcoes) 
			{
				tamanho += item.altura;
			}
			tamanho += (qtFaltam * minAltura)
			return tamanho;
		}
		
		public function loadData(o:Object):void {
			this.id = o.id;
			this.opcoes  = new Vector.<DestinoItem>();
			for (var i:int = 0; i < o.qtOpcoes; i++) {
				var opd:Object = o.opcoes[i.toString()];
				var opcao:Opcao = this.listaOpcoes.getOpcaoByName(opd.texto);
				adicionarOpcao(opcao);
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
				q++;
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
			if (dicValidos[opcao.texto] != null) {
				dicValidos[opcao.texto] = true;
				
			}
			if (txformat != null) op.setTextFormat(txformat);
			op.largura = largura;
			opcoes.push(op);
			refreshItems();
			
			
		}
		
		public function refreshItems():void {
			for (var i:int = numChildren - 1; i >= 0; i--) {
				if (this.getChildAt(i) != layerResultado) {
					removeChildAt(i);
				}
				
			}
			var pos:int = 0;			
			for each (var op:DestinoItem in opcoes) {				
				addChild(op);
				op.y = pos;
				pos += op.altura;				
			}			
			draw();
			updateValor();
		}		
		public function onClick(e:MouseEvent):void {
			//if (this.foco) return;
			trace("e.target = ", e.target)
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
		
		public function get valoratual():int 
		{
			return _valoratual;
		}
		
		public function set valoratual(value:int):void 
		{
			_valoratual = value;
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
						
						if(DestinoOpcoes(p.getChildAt(i)).foco) DestinoOpcoes(p.getChildAt(i)).removeFoco();
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