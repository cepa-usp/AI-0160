package  
{
	import com.eclecticdesignstudio.motion.Actuate;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
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
		private var _selecionado:Boolean = false;
		private var _lyrbg:Sprite = new Sprite();
		
		
		public function Opcao(listaOpcoes:ListaOpcoes, texto:String) 
		{
			filters = [new BlurFilter(0, 0), new GlowFilter(0xFFFF00, 0.0, 3, 3, 2, 1, true)];
			this.listaOpcoes = listaOpcoes;
			this.texto = texto;
			
			tx.selectable = false;
			tx.width = listaOpcoes.largura - 2 * margem;
			tx.text = texto;
			addChild(lyrbg);
			addChild(tx);
			
			tx.x = margem;
			tx.y = margem;
			tx.height = tx.textHeight + 8;
			drawbg();
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.CLICK, onClick);
			
		}
		
		private function onClick(e:MouseEvent):void 
		{
				if (selecionado == true) return;
				selecionado = true;
				var ev = new ListaOpcoesEvent(ListaOpcoesEvent.OPCAO_SELECIONADA, this);
				listaOpcoes.dispatchEvent(ev);
		}
		
		private function onMouseOver(e:MouseEvent):void 
		{
			Actuate.effects(this, 1).filter(1, { alpha: 0.7 })
		}

		private function onMouseOut(e:MouseEvent):void 
		{
			Actuate.effects(this, 1).filter(1, { alpha: 0 })
		}

		
		public function drawbg():void {
			lyrbg.graphics.clear();
			lyrbg.graphics.beginFill(0x000040, 0.7);
			lyrbg.graphics.lineStyle(1, 0xFF0000, 0.9);
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
		
	}

}