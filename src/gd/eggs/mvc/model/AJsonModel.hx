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
		if (Std.is(data, String)) 
		{
			object = Json.parse(data);
		} 
		else 
		{
			object = data;
		}
		
		// начинаем проход по полям объекта
		for (field in Reflect.fields(object)) 
		{
			// Если у нас нет такого поля
			if (!Reflect.hasField(this, field)) continue;
			
			// Сохраняем ссылку на поле в переменную
			var fieldRef = Reflect.field(this, field); 
			
			// Сохраняем данные поля в переменную
			var fieldData = Reflect.field(object, field); 
			
			// Метаданные поля
			var fieldTypesArr:Array<Dynamic> = null;
			var fieldType = null;
			var collectionItem = null;
			var fieldMeta = Reflect.field(_meta, field);
			
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
				Reflect.callMethod(fieldRef, Reflect.field(fieldRef, "fillData"), [fieldData]);
			} 
			else if (Std.is(fieldRef, StringMap)) // Если это словарь
			{ 
				var map:StringMap<Dynamic> = cast fieldRef;
				
				// Проходим по всем детям мапы
				for (field2 in Reflect.fields(fieldData)) 
				{ 
					if (fieldType != null) collectionItem = Type.createInstance(fieldType, []);
					
					// если тип - наследник жсон-модели то пройтись по детям
					if (collectionItem != null && Std.is(collectionItem, AJsonModel)) 
					{ 
						Reflect.callMethod(collectionItem, Reflect.field(collectionItem, "fillData"), [Reflect.field(fieldData, field2), field2]);
						map.set(field2, collectionItem);
						collectionItem = null;
					} 
					else // Иначе - заполняем по дефолту
					{ 
						map.set(field2, Reflect.field(fieldData, field2));
					}
				}
			} 
			else if (Std.is(fieldRef, Array)) 
			{
				var array:Array<Dynamic> = cast fieldRef;
				
				// Проходим по всем детям массива
				for (field2 in Reflect.fields(fieldData)) 
				{ 
					if (fieldType != null) collectionItem = Type.createInstance(fieldType, []);
					
					// если тип - наследник жсон-модели то пройтись по детям
					if (collectionItem != null && Std.is(collectionItem, AJsonModel)) 
					{
						Reflect.callMethod(collectionItem, Reflect.field(collectionItem, "fillData"), [Reflect.field(fieldData, field2), field2]);
						array.insert(cast field2, collectionItem);
						collectionItem = null;
					} 
					else // Иначе - заполняем по дефолту
					{ 
						array.insert(cast field2, Reflect.field(fieldData, field2));
					}
				}
			} 
			else // Иначе тупо устанавливаем
			{ 
				Reflect.setField(this, field, fieldData);
			}
		}
	}
	
}