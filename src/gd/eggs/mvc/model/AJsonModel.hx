package gd.eggs.mvc.model;

import gd.eggs.utils.IAbstractClass;
import haxe.ds.StringMap;
import haxe.Json;
import haxe.rtti.Meta;

/**
 * @author Dukobpa3
 */
class AJsonModel implements IModel implements IAbstractClass {
	
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	public var _id_(default, null):String;
	
	public var isInited(default, null):Bool;
	
	var _meta(default, null):Dynamic;
	
	//=========================================================================
	//	CONSTRUCTOR
	//=========================================================================
	
	private function new() { 
		_meta = Meta.getFields(Type.getClass(this));
	}
	
	//=========================================================================
	//	PUBLIC
	//=========================================================================
	/* INTERFACE gd.eggs.mvc.model.IModel */
	
	public function init() {};
	public function destroy() {};
	
	// TODO говнокодище...
	public function fillData(data:Dynamic, ?id:String) 
	{
		
		// установить уид
		if (id != null) this._id_ = id;
		
		// Распарсить объект если тут строка
		var object;
		if (Std.is(data, String)) {
			object = Json.parse(data);
		} else {
			object = data;
		}
		
		// начинаем проход по полям объекта
		for (key in Reflect.fields(object)) 
		{
			// Если у нас нет такого поля
			if (!Reflect.hasField(this, key)) continue;
			
			// Сохраняем ссылку на поле в переменную
			var fieldRef = Reflect.field(this, key); 
			
			// Сохраняем данные поля в переменную
			var fieldData = Reflect.field(object, key); 
			
			// Метаданные поля
			var fieldMeta = Reflect.field(_meta, key);
			var fieldTypesArr:Array<Dynamic> = null;
			var fieldType = null;
			
			if (fieldMeta != null) 
			{
				fieldTypesArr = Reflect.field(fieldMeta, "collectionType");
			} 
			if (fieldTypesArr != null && fieldTypesArr.length > 0) 
			{
				fieldType = Type.resolveClass(fieldTypesArr[0]);
			}
			
			// Если поле - это одчерняя модель
			if (Std.is(fieldRef, AJsonModel)) 
			{ 
				var fr:AJsonModel = cast fieldRef;
				fr.fillData(fieldData);
				//Reflect.callMethod(fieldRef, Reflect.field(fieldRef, "fillData"), [fieldData]);
			} 
			else if (Std.is(fieldRef, StringMap)) // Если это словарь
			{ 
				var map:StringMap<Dynamic> = cast fieldRef;
				fillMap(map, fieldData, fieldType);
			} 
			else if (Std.is(fieldRef, Array)) 
			{
				var array:Array<Dynamic> = cast fieldRef;
				fillArray(array, fieldData, fieldType);
			} 
			else // Иначе тупо устанавливаем
			{ 
				Reflect.setField(this, key, fieldData);
			}
		}
	}
	
	function fillMap(map:StringMap<Dynamic>, data:Dynamic, childType) 
	{
		var collectionItem = null;
		
		// Проходим по всем детям мапы
		for (key in Reflect.fields(data)) 
		{ 
			if (childType != null) collectionItem = Type.createInstance(childType, []);
			
			// если тип - наследник жсон-модели то пройтись по детям
			if (collectionItem != null && Std.is(collectionItem, AJsonModel)) 
			{ 
				Reflect.callMethod(collectionItem, Reflect.field(collectionItem, "fillData"), [Reflect.field(data, key), key]);
			} 
			else // Иначе - заполняем по дефолту
			{ 
				collectionItem = Reflect.field(data, key);
			}
			
			trace(key, collectionItem);
			map.set(key, collectionItem);
			collectionItem = null;
		}
	}
	
	function fillArray(array:Array<Dynamic>, data:Dynamic, childType) 
	{
		var collectionItem = null;
		var intKey;
		
		// Проходим по всем детям массива
		for (key in Reflect.fields(data)) 
		{ 
			if (childType != null) collectionItem = Type.createInstance(childType, []);
			
			// если тип - наследник жсон-модели то пройтись по детям
			if (collectionItem != null && Std.is(collectionItem, AJsonModel)) 
			{
				Reflect.callMethod(collectionItem, Reflect.field(collectionItem, "fillData"), [Reflect.field(data, key), key]);
			} 
			else // Иначе - заполняем по дефолту
			{ 
				collectionItem = Reflect.field(data, key);
			}
			
			trace(key, collectionItem);
			intKey = Std.parseInt(key);
			array[intKey] = collectionItem;
			collectionItem = null;
		}
	}
	
}