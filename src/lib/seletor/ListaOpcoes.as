package  seletor
{
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import memorphic.xpath.XPathQuery;
	
	/**
	 * ...
	 * @author Arthur
	 */
	
	public class ListaOpcoes extends Sprite 
	{		
		private var _conteudo:Conteudo = null;
		private var _posicao:int = POS_ESQUERDA;
		private var _largura:int = 200;
		private var _altura:int = 600;
		private var mascara:Sprite = new Sprite();
		private var _opcoes:Vector.<Opcao> = new Vector.<Opcao>();
		private var layerOpcoes:Sprite = new Sprite();
		private var layerBorder:Sprite = new Sprite();
		private var dicOpcoes:Dictionary = new Dictionary();
		private var exibindo:Boolean = false;
		private var destino:Sprite;
		
		public static const POS_ESQUERDA:int = 0;
		public static const POS_DIREITA:int = 1;
		public static var listaOpcaoAtiva:ListaOpcoes = null;
		public static var listaOpcaoProxima:ListaOpcoes = null;
		public static var posProx:int = 1;
		
		
		public function fazMascara():void {
			mascara.graphics.beginFill(0x00FF00);
			mascara.graphics.drawRect(0, 0, largura, altura);
			mascara.x = 0;
			mascara.y = 0;
			layerOpcoes.mask = mascara;
		}
		
		public function ListaOpcoes(conteudoXML:Conteudo) 
		{
			this.conteudo = conteudoXML;
			fazMascara();
			addChild(layerOpcoes);
			addChild(layerBorder);
			addChild(mascara);
			layerBorder.graphics.drawRect(0, 0, largura, 1)
			this.addEventListener(Event.ADDED, onAdded);			
		}
		
		public function definirConteudo(xpathquery:String, attr:String=null):void {
			dicOpcoes = new Dictionary();
			var query:XPathQuery = new XPathQuery(xpathquery);
			var result:XMLList = query.exec(conteudo.conteudo)
			for each (var r:XML in result) {
				if (attr == "") {
					adicionarOpcao(r[0]);
				} else {
					adicionarOpcao(r.attribute(attr))
				}
				
			}
			//trace(result)
			
		}
		
		private function onAdded(e:Event):void 
		{
			
			this.x = 0 - this.largura;
			return;
			if (e.target == this) {
				switch(posicao) {
					case POS_DIREITA:
						this.x = this.stage.stageWidth - this.largura;
						this.y = 0;
						break;
					case POS_ESQUERDA:
						this.x = 0;
						this.y = 0;
						break;
						
				}
				
			}
			
		}
		
	
		public function adicionarOpcao(tx:String):Opcao {
			if (dicOpcoes[tx] != null) {
				Opcao(dicOpcoes[tx]).qtde++;
				return Opcao(dicOpcoes[tx]);
			}			
			var o:Opcao = new Opcao(this, tx);
			o.qtde = 1;
			o.qtdeUsada = 0;
			var pos:int = 0;
			dicOpcoes[tx] = o;
			for each (var opt:Opcao in opcoes) pos += opt.height;
			opcoes.push(o);
			layerOpcoes.addChild(o);
			o.x = 0;
			o.y = pos;
			
			return o;
		}
		
		public function get posicao():int 
		{
			return _posicao;
		}
		
		public function set posicao(value:int):void 
		{
			_posicao = value;
		}
		
		public function get largura():int 
		{
			return _largura;
		}
		
		public function set largura(value:int):void 
		{
			_largura = value;
		}
		
		public function get opcoes():Vector.<Opcao> 
		{
			return _opcoes;
		}
		
		public function set opcoes(value:Vector.<Opcao>):void 
		{
			_opcoes = value;
		}
		
		public function get altura():int 
		{
			return _altura;
		}
		
		public function set altura(value:int):void 
		{
			_altura = value;
		}
		
		public function get conteudo():Conteudo 
		{
			return _conteudo;
		}
		
		public function set conteudo(value:Conteudo):void 
		{
			_conteudo = value;
		}
		

		
		public function show(pos:int = ListaOpcoes.POS_DIREITA):void {
			
				//if (listaOpcaoAtiva == this) return;	
				_posicao = pos;
				if (ListaOpcoes.listaOpcaoAtiva!=null) {
					ListaOpcoes.listaOpcaoProxima = this;
					ListaOpcoes.posProx = pos;
					ListaOpcoes.listaOpcaoAtiva.hide();
					return;
					
				}
				this.y = 100;
				if (pos == POS_DIREITA) {
					this.x = stage.stageWidth + 10;					
				} else {
					this.x = 0 - this.largura - 10;
				}
				var xx:int = (pos == POS_DIREITA?this.stage.stageWidth - this.largura - 10:10);
				Actuate.tween(this, 0.5, { x:xx } ).onComplete(setThisActive);
		}
		
		private function setThisActive():void 
		{
			ListaOpcoes.listaOpcaoAtiva = this;
		}
		
		public function hide():void {
				var xx:int = (posicao == POS_DIREITA?stage.stageWidth + 10:-this.largura - 10);		
				Actuate.tween(this, 0.5, { x:xx } ).onComplete(afterHideThis);
		}
		
		public function localizarOpcao(texto:String):Opcao 
		{
			for each(var o:Opcao in opcoes) {
				if (o.texto == texto) return o;
			}
			return null;
		}
		
		private function afterHideThis():void 
		{
			if (ListaOpcoes.listaOpcaoAtiva == this) ListaOpcoes.listaOpcaoAtiva = null;
			if (ListaOpcoes.listaOpcaoProxima != null) {
				var l:ListaOpcoes = ListaOpcoes.listaOpcaoProxima;
				ListaOpcoes.listaOpcaoProxima = null;
				l.show(ListaOpcoes.posProx);			
			}
		}
		


		
	}

}