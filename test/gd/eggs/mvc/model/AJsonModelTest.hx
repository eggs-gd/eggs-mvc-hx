package gd.eggs.mvc.model;

import gd.eggs.mvc.model.AJsonModel;
import haxe.Json;
import massive.munit.Assert;

/**
 * ...
 * @author Dukobpa3
 */

class TestChildModel extends AJsonModel {
	public var array:Array<Int>;
	public var str:String;
	public var bool:Bool;
	
	public function new() {
		super();
		init();
	}
	
	override public function init() {
		array = [];
		str = '';
		bool = false;
		isInited = true;
	}
	
	override public function destroy() {
		isInited = false;
	}
}
 
class TestParentModel extends AJsonModel {
	public var array:Array<Int>;
	public var str:String;
	public var some:Float;
	public var bool:Bool;
	public var child:TestChildModel;
	
	public function new () {
		super();
		init();
	}
	
	override public function init() {
		child = new TestChildModel();
		array = [];
		str = '';
		some = 0.0;
		bool = false;
		isInited = true;
	}
	
	override public function destroy() {
		isInited = false;
	}
}


 
class AJsonModelTest 
{
	
	@Test
	public function jsonObjectParseTest():Void 
	{
		var data:String='{"array":[0,1], "str":"test"}';
		var res:{array:Array<Int>,str:String} = haxe.Json.parse(data);
		
		Assert.areEqual(res.array.length, 2);
		Assert.areEqual(res.array[0], 0);
		//Assert.areEqual(res.str, "test");
	}
	
	@Test
	public function fillNoChildClearTest() {
		var data = { array:[1, 2], str:"test", bool:true };
		var model = new TestChildModel();
		
		model.fillData(data);
		Assert.areEqual(model.array.length, 2);
		Assert.areEqual(model.array[0], 1);
		Assert.areEqual(model.str, "test");
		Assert.areEqual(model.bool, true);
	}
	
	@Test
	public function fillNoChildOverkeysTest() {
		var data = { array:[1, 2], str:"test", some:10.2 };
		var model = new TestChildModel();
		
		model.fillData(data);
		
		Assert.areEqual(model.array.length, 2);
		Assert.areEqual(model.array[1], 2);
		Assert.areEqual(model.str, "test");
	}
	
	@Test
	public function fillParentChildOverkeysTest() {
		var data = { 
			array:[1, 2], 
			str:"test",
			bool:true,
			some:10.2, 
			child: {
				array:[3, 4], 
				str:"testChild",
				bool:false
			}
		};
		
		var model = new TestParentModel();
		
		model.fillData(data);
		
		Assert.areEqual(model.array.length, 2);
		Assert.areEqual(model.array[1], 2);
		Assert.areEqual(model.str, "test");
		Assert.areEqual(model.bool, true);
		
		Assert.isTrue(Std.is(model.child, TestChildModel));
		
		Assert.areEqual("testChild", model.child.str);
		Assert.areEqual(false, model.child.bool);
	}
	
	@Test
	public function fillParentChildOverkeysFromStringTest() {
		var data = '{ "array":[1, 2], "str":"test", "some":10.2, "child": { "array":[3, 4], "str":"testChild"}}';
		
		var model = new TestParentModel();
		
		model.fillData(data);
		Assert.areEqual(model.array.length, 2);
		Assert.areEqual(model.array[1], 2);
		Assert.areEqual(model.some, 10.2);
		
		Assert.isTrue(Std.is(model.child, TestChildModel));
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
	
}