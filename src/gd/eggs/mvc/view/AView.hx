package gd.eggs.mvc.view;

import gd.eggs.display.DisplayObject;
import gd.eggs.utils.DestroyUtils;
import gd.eggs.utils.IAbstractClass;
import gd.eggs.utils.Validate;
import msignal.Signal;

/**
 * @author Dukobpa3
 */
class AView extends Sprite implements IView implements IAbstractClass {
	
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	public var isInited(default, null):Bool;
	
	//=========================================================================
	//	CONSTRUCTOR
	//=========================================================================
	
	private function new() {
		super();
		init();
	}
	
	//=========================================================================
	//	PUBLIC
	//=========================================================================
	
	public function init();
	public function destroy();
	
	public function show() visible = true;
	public function hide() visible = false;
	
	public function invalidate();
}