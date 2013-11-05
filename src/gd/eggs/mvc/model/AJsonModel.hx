package gd.eggs.mvc.model;

import gd.eggs.utils.IAbstractClass;
import gd.eggs.utils.Validate;
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
	
	public function init();
	public function destroy();
	
	/**
	 * Рекурсивно заполняет модель данными жсон либо Object|Dynamic
	 * @param	data 	строка либо Dynamic
	 * @param	?id 	можно добавить ид. Так же автоматически ставится на айтемы коллекций
	 */
	public function fillData(data:Dynamic, ?id:String) {
		
		var object;
		var fieldRef; 	// Ссылку на поле (this[fieldName])
		var fieldData; 	// Данные поля (data[fieldName])
		var fieldType; 	// Метаданные поля (typeof(fieldName))
		var typedRef:AJsonModel;
		
		// установить уид
		if (id != null) this._id_ = id;
		
		// Распарсить объект если тут строка
		
		if (Std.is(data, String)) {
			object = Json.parse(data);
		} else {
			object = data;
		}
		
		// начинаем проход по полям объекта
		for (key in Reflect.fields(object)) 
		{
			if (!Reflect.hasField(this, key)) continue; // Если у нас нет такого поля, до свидания
			
			fieldRef = Reflect.field(this, key);
			fieldData = Reflect.field(object, key);
			fieldType = getCollectionType(key);
			
			if (Std.is(fieldRef, AJsonModel)) {  // Если поле это дочерняя модель
				typedRef = cast fieldRef;
				typedRef.fillData(fieldData, key);
				
			} else if (Std.is(fieldRef, StringMap)) { // Если это словарь - отдельная обработка
				var map:StringMap<Dynamic> = cast fieldRef;
				fillMap(map, fieldData, fieldType);
				
			} else if (Std.is(fieldRef, Array)) { // Если это массив - снова по-другому
				var array:Array<Dynamic> = cast fieldRef;
				fillArray(array, fieldData, fieldType);
				
			} else { // Иначе тупо устанавливаем
				Reflect.setField(this, key, fieldData);
			}
		}
	}
	
	/**
	 * Обработка заполнения мапы
	 * @param	map 		ссылка на мапу (this.<reference>)
	 * @param	data 		данные которыми нужно заполнить мапу
	 * @param	childType 	тип к которому нужно кастовать айтемы
	 */
	function fillMap(map:StringMap<Dynamic>, data:Dynamic, childType) {
		
		var typedRef:AJsonModel = null;
		var item = null;
		
		// Проходим по всем детям полученного обжекта
		for (key in Reflect.fields(data)) 
		{ 
			if (childType != null) item = Type.createInstance(childType, []);
			
			// если тип - наследник жсон-модели то заполнить дочерней структурой
			if (item != null && Std.is(item, AJsonModel)) { 
				typedRef = cast item;
				typedRef.fillData(Reflect.field(data, key), key);
			
			} else { // Иначе - просто приравниваем
				item = Reflect.field(data, key);
			}
			
			map.set(key, item);
			item = null; // на всякий случай обнулимся
		}
	}
	
	/**
	 * Обработка заполнения массива
	 * @param	array 		ссылка на массив (this.<reference>)
	 * @param	data 		данные которыми нужно заполнить мапу
	 * @param	childType 	тип к которому нужно кастовать айтемы
	 */
	function fillArray(array:Array<Dynamic>, data:Dynamic, childType) {
		
		var typedRef:AJsonModel = null;
		var item = null;
		var intKey:Int;
		
		// Проходим по всем детям массива
		if (Std.is(data, Array)) { // Нужно для неко плюсов и жавы так как ключи интовые
			
			var arr:Array<Dynamic> = cast data;
			for ( i in 0...arr.length ) {
				
				var childData = arr[i];
				
				if (childType != null) item = Type.createInstance(childType, []);
				
				// если тип - наследник жсон-модели то пройтись по детям
				if (item != null && Std.is(item, AJsonModel)) {
					typedRef = cast item;
					typedRef.fillData(childData, Std.string(i));
					
				} else { // Иначе - заполняем по дефолту
					item = childData;
				}
				
				array[i] = item;
				item = null;
			}
		} else { // Проход рефлектов конает для флеша и прочей динамики
			
			for (key in Reflect.fields(data)) { 
				
				if (childType != null) item = Type.createInstance(childType, []);
				
				// если тип - наследник жсон-модели то заполнить
				if (item != null && Std.is(item, AJsonModel)) {
					typedRef = cast item;
					typedRef.fillData(Reflect.field(data, key), key);
					
				} else { // Иначе - просто приравнять
					item = Reflect.field(data, key);
				}
				
				array[Std.parseInt(key)] = item;
				item = null;
			}
		}
	}
	
	/**
	 * Выдает класс айтема коллекции по ключу. Тип надо было указать в аннотации.
	 * @param	key
	 * @return
	 */
	function getCollectionType(key:String):Dynamic
	{
		var fieldMeta = Reflect.field(_meta, key);
		var fieldTypesArr:Array<Dynamic> = null;
		
		if (fieldMeta != null) {
			fieldTypesArr = Reflect.field(fieldMeta, "collectionType");
		} 
		
		if (fieldTypesArr != null && fieldTypesArr.length > 0) {
			return Type.resolveClass(fieldTypesArr[0]);
		}
		
		return null;
	}
	
}