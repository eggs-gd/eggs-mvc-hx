package gd.eggs.mvc.view;

import gd.eggs.utils.IInitialize;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

/**
 * @author Dukobpa3
 */
interface IView extends IInitialize {
	
	//=========================================================================
	//	METHODS
	//=========================================================================
	
	function show():Void;
	function hide():Void;
	function invalidate():Void;
}