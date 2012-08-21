package  seletor
{
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Arthur
	 */
	public class Opcao extends Sprite 
	{
		private var listaOpcoes:ListaOpcoes;		
		private var _tx:TextField = new TextField();
		private var margem:int = 5;
		private var _texto:String;
		private var _qtde:int = 0;
		private var _qtdeUsada:int = 0;
		private var _selecionado:Boolean = false;
		private var _lyrbg:Sprite = new Sprite();
		private var numero:Sprite = new Sprite();

		
		
		public function getSerialData():Object {
			var o:Object = new Object();
			o.texto = texto;
			o.qtde = qtde;
			o.qtdeUsada = qtdeUsada;
			o.selecionado = selecionado;
			return o;
		}
		
		public function fazNumero():void {
			var t:TextField = new TextField();
			var tf:TextFormat = new TextFormat("arial", 10, 0xFFFFFF, true);
			t.defaultTextFormat = tf;
			t.selectable = false;
			t.width = 15;
			t.height = 15;
			t.multiline = false;
			t.wordWrap = false;
			t.text = qtde.toString();
			t.name = "numerotx"
			numero.addChild(t);
			numero.name = "numero"
			numero.graphics.beginFill(0x804040, 0.9);
			numero.graphics.drawCircle(5, 9, 8);
			numero.x = this.width - 15;
			addChild(numero)
			numero.alpha = 0.01;
		}
		
		
		public function setData(o:Object):void {
			this.texto = o.texto;
			this.qtde = o.qtde;
			this.qtdeUsada = o.qtdeUsada;
			this.selecionado = o.selecionado;
			drawbg();
		}
		
		public function Opcao(listaOpcoes:ListaOpcoes, texto:String) 
		{
			filters = [new BlurFilter(0, 0), new GlowFilter(0xFFFF00, 0.0, 3, 3, 2, 1, true)];
			this.listaOpcoes = listaOpcoes;
			this.texto = texto;
			this.mouseChildren = false;
			tx.selectable = false;
			tx.width = listaOpcoes.largura - 2 * margem;
			tx.multiline = true;
			tx.wordWrap = true;
			//tx.border = true;
			//tx.borderColor = 0x00FF00;
			tx.x = margem;
			tx.text = texto;
			addChild(lyrbg);
			addChild(tx);
			fazNumero();
			setTextBreak(tx);
			tx.height = tx.textHeight + 8;
			
			drawbg();
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onClick);
			
		}
		
		public function updateNumero():void {
			var nn:int = qtde - qtdeUsada;
			TextField(Sprite(this.getChildByName("numero")).getChildByName("numerotx")).text = nn.toString();
		}
		
		private function setTextBreak(txf:TextField):void {
			
		};
		
		private function onClick(e:MouseEvent):void 
		{
				if (selecionado == true) return;
				qtdeUsada++;
				if(qtdeUsada==qtde) selecionado = true;
				var ev:ListaOpcoesEvent = new ListaOpcoesEvent(ListaOpcoesEvent.OPCAO_SELECIONADA, this);
				listaOpcoes.dispatchEvent(ev);
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			Actuate.effects(this, 1).filter(1, { alpha: 0.7 } )
			Actuate.tween(numero, 0.4, { alpha:1 } );
		}

		private function onMouseOut(e:MouseEvent):void 
		{
			Actuate.effects(this, 1).filter(1, { alpha: 0 } )
			Actuate.tween(numero, 1, { alpha:0.01 } );
		}

		
		public function drawbg():void {
			lyrbg.graphics.clear();
			lyrbg.graphics.beginFill(0xEDE687, 0.8);
			//lyrbg.graphics.lineStyle(1, 0xFF0000, 0.9);
			lyrbg.graphics.drawRect(0, 0, listaOpcoes.largura, tx.textHeight + 2 * margem);
			
		}
		
		public function get selecionado():Boolean 
		{
			return _selecionado;
		}
		
		public function set selecionado(value:Boolean):void 
		{
			_selecionado = value;
			if (value) {
				Actuate.effects(this, 0.4).filter(0, { blurX: 6, blurY:6 } );
			} else {
				Actuate.effects(this, 0.4).filter(0, { blurX: 0, blurY:0 } );
			}
		}
		
		public function get texto():String 
		{
			return _texto;
		}
		
		public function set texto(value:String):void 
		{
			_texto = value;
			tx.text = _texto;
			drawbg();
		}
		
		public function get lyrbg():Sprite 
		{
			return _lyrbg;
		}
		
		public function set lyrbg(value:Sprite):void 
		{
			_lyrbg = value;
		}
		
		public function get tx():TextField 
		{
			return _tx;
		}
		
		public function set tx(value:TextField):void 
		{
			_tx = value;
		}
		
		public function get qtde():int 
		{
			return _qtde;
		}
		
		public function set qtde(value:int):void 
		{
			_qtde = value;
			updateNumero();
		}
		
		public function get qtdeUsada():int 
		{
			return _qtdeUsada;
		}
		
		public function set qtdeUsada(value:int):void 
		{
			var qold:int = qtdeUsada;
			_qtdeUsada = value;
			updateNumero();
			if (qold > value) {
				numero.alpha = 1;
				Actuate.tween(numero, 1, { alpha:1 } ).onComplete(function():void {
					Actuate.tween(numero, 1, { alpha:0.01 } );
				});
			}
		}

		
	}

}