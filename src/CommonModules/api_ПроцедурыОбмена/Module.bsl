Функция УпаковатьВJSON(СообщениеСоотвествие) Экспорт
	СообщениеВJSON = Новый ЗаписьJSON;
	СообщениеВJSON.УстановитьСтроку();
	ЗаписатьJSON(СообщениеВJSON, СообщениеСоотвествие);
	Возврат СообщениеВJSON.Закрыть();
КонецФункции    

Функция РаспаковатьИзJSON(JSON) Экспорт 
	Чтение = Новый ЧтениеJSON;    
	
	Чтение.УстановитьСтроку(JSON);
	
	Ответ = "";
	Попытка
		Ответ = ПрочитатьJSON(Чтение, Истина);
	Исключение
		Возврат Ответ;
	КонецПопытки;
	
	Возврат Ответ
КонецФункции  