import massive.munit.TestSuite;

import ExampleTest;
import gd.eggs.mvc.model.AJsonModelAdvancedTest;
import gd.eggs.mvc.model.AJsonModelTest;
import gd.eggs.mvc.model.NekoArrayTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(ExampleTest);
		add(gd.eggs.mvc.model.AJsonModelAdvancedTest);
		add(gd.eggs.mvc.model.AJsonModelTest);
		add(gd.eggs.mvc.model.NekoArrayTest);
	}
}
