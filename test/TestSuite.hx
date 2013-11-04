import massive.munit.TestSuite;

import ExampleTest;
import test.gd.eggs.mvc.model.AJsonModelAdvancedTest;
import test.gd.eggs.mvc.model.AJsonModelTest;

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
		add(test.gd.eggs.mvc.model.AJsonModelAdvancedTest);
		add(test.gd.eggs.mvc.model.AJsonModelTest);
	}
}
