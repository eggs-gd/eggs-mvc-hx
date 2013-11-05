package gd.eggs.mvc.model;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import gd.eggs.mvc.model.AJsonModel;

class NekoArrayTest 
{
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	#if (neko || cpp)
	@Test
	public function testExample():Void
	{
		var arr:Array<Int> = [];
		
		arr[1] = 2;
		arr[0] = 1;
		
		Assert.areEqual(arr.length, 2);
	}
	#end
}