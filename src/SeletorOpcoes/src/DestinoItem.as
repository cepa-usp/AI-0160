package  
{
	import flash.desktop.ClipboardTransferMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Arthur
	 */
	public class DestinoItem extends Sprite 
	{
		private var _opcao:Opcao;		
		private var tx:TextField = new TextField();
		private var margem:int = 5;
		private var _altura:int = 15;
		private var _largura:int = 50;
		
		private var btFechar:BtFechar = new BtFechar();
		private var container:DestinoOpcoes;
		
		public function DestinoItem(opcao:Opcao, container:DestinoOpcoes) 
		{
			this.container = container;
			
			this.opcao = opcao;
			this.addChild(tx);
			fazBtFechar()
			tx.text = opcao.texto;
			tx.x = margem;			
			tx.selectable = false;			
			tx.width = largura - margem;
			tx.wordWrap = true;
			tx.multiline = true;
			if (container.txformat != null) {
				tx.defaultTextFormat = container.txformat;
			}
			//tx.border = true;
			btFechar.addEventListener(MouseEvent.CLICK, onMouseClick);
			
		}
		
		private function onMouseClick(e:MouseEvent):void 
		{
			container.removeItem(this)
			
		}
		
		private function fazBtFechar():void 
		{
			btFechar.gotoAndStop(1);
			btFechar.y = 10;
			btFechar.buttonMode = true;
			btFechar.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				btFechar.gotoAndStop(2);
			});
			btFechar.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				btFechar.gotoAndStop(1);
			});		
			addChild(btFechar);
		}
		
		public function get opcao():Opcao 
		{
			return _opcao;
		}
		
		public function set opcao(value:Opcao):void 
		{
			_opcao = value;
		}
		
		public function get largura():int 
		{
			return _largura;
		}
		
		public function set largura(value:int):void 
		{
			_largura = value;
			tx.width = largura - margem;			
			altura = tx.textHeight + 10;
			tx.height = altura;
			btFechar.x = largura - 10;
		}
		
		public function get altura():int 
		{
			return _altura;
		}
		
		public function set altura(value:int):void 
		{
			_altura = value;
		}
		
	}

}