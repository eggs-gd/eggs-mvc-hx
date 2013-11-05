package gd.eggs.mvc.model;

import gd.eggs.utils.IAbstractClass;
import gd.eggs.utils.Validate;
import haxe.ds.StringMap;
import haxe.Json;
import haxe.rtti.Meta;
using gd.eggs.utils.StringUtils;
using Lambda;

/**
 * @author Dukobpa3
 */
class AJsonModel implements IModel implements IAbstractClass {
	
	//=========================================================================
	//	PARAMETERS
	//=========================================================================
	
	public var isInited(default, null):Bool;
	
	var _meta(default, null):Dynamic;
	
	//=========================================================================
	//	CONSTRUCTOR
	//=========================================================================
	
	private function new() _meta = Meta.getFields(Type.getClass(this));
	
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
	public function deserialize(data:Dynamic, ?id:String) {
		var object:Dynamic;
		if (Std.is(data, String)) {
			object = Json.parse(data);
		} else {
			object = data;
		}
		
		var instanceFields = Type.getInstanceFields(Type.getClass(this));
		for (key in Reflect.fields(object)) {
			if (!instanceFields.has(key)) {
				continue;
			}
			
			var fieldRef = Reflect.field(this, key);
			var fieldData = Reflect.field(object, key);
			var fieldType = getCollectionType(key);
			
			if (Std.is(fieldRef, AJsonModel)) {
				var typedRef:AJsonModel = cast(fieldRef, AJsonModel);
				typedRef.deserialize(fieldData, key);
				
			} else if (Std.is(fieldRef, StringMap)) {
				var map:StringMap<Dynamic> = cast fieldRef;
				fillMap(map, fieldData, fieldType);
				
			} else if (Std.is(fieldRef, Array)) {
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
	function fillMap(map:StringMap<Dynamic>, data:Dynamic, childType:Class<Dynamic>) {
		for (key in Reflect.fields(data)) {
			var item = null;
			if (Validate.isNotNull(childType)) {
				item = Type.createInstance(childType, []);
			}
			
			if (Validate.isNotNull(item) && Std.is(item, AJsonModel)) { 
				var typedRef = cast(item, AJsonModel);
				typedRef.deserialize(Reflect.field(data, key), key);
			} else {
				item = Reflect.field(data, key);
			}
			
			map.set(key, item);
		}
	}
	
	/**
	 * Обработка заполнения массива
	 * @param	array 		ссылка на массив (this.<reference>)
	 * @param	data 		данные которыми нужно заполнить мапу
	 * @param	childType 	тип к которому нужно кастовать айтемы
	 */
	function fillArray(array:Array<Dynamic>, data:Dynamic, childType:Class<Dynamic>) {
		
		var typedRef:AJsonModel = null;
		var item = null;
		
		// Проходим по всем детям массива
		if (Std.is(data, Array)) { // Нужно для неко плюсов и жавы так как ключи интовые
			
			var arr:Array<Dynamic> = cast data;
			for (i in 0...arr.length) {
				
				var childData = arr[i];
				
				if (Validate.isNotNull(childType)) {
					item = Type.createInstance(childType, []);
				}
				
				// если тип - наследник жсон-модели то пройтись по детям
				if (Validate.isNotNull(item) && Std.is(item, AJsonModel)) {
					var typedRef = cast(item, AJsonModel);
					typedRef.deserialize(childData, Std.string(i));
					
				} else { // Иначе - заполняем по дефолту
					item = childData;
				}
				
				array[i] = item;
				item = null;
			}
		} else { // Проход рефлектов конает для флеша и прочей динамики
			
			for (key in Reflect.fields(data)) { 
				
				if (Validate.isNotNull(childType)) {
					item = Type.createInstance(childType, []);
				}
				
				// если тип - наследник жсон-модели то заполнить
				if (Validate.isNotNull(item) && Std.is(item, AJsonModel)) {
					typedRef = cast(item, AJsonModel);
					typedRef.deserialize(Reflect.field(data, key), key);
					
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
	function getCollectionType(key:String):Dynamic {
		var fieldMeta = Reflect.field(_meta, key);
		var fieldTypesArr:Array<Dynamic> = null;
		
		if (Validate.isNotNull(fieldMeta)) {
			fieldTypesArr = Reflect.field(fieldMeta, "collectionType");
		} 
		
		if (Validate.isNotNull(fieldTypesArr) && fieldTypesArr.length > 0) {
			return Type.resolveClass(fieldTypesArr[0]);
		}
		
		return null;
	}
	
}