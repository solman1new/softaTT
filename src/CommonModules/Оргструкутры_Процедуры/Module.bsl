#Область ОбработкаВходящегоЗапроса
Функция ОбработкаЗапроса(ЗапросСоотвествие) Экспорт 
	
	// я тут 
	  
	// выдача дерева
	Если ТипЗнч(ЗапросСоотвествие.Получить("ID")) = Тип("Массив") Тогда 
		ОтветСтруктура = Новый Структура; 
		
		Если ЗначениеЗаполнено(ЗапросСоотвествие.Получить("ID")) Тогда
			ОтветСтруктура.Вставить("Divisions", ПолучитьСписокОргструктурыИзСписка(ЗапросСоотвествие.Получить("ID")));
		ИначеЕсли ЗначениеЗаполнено(ЗапросСоотвествие.Получить("Parent ID")) Тогда
			ОтветСтруктура.Вставить("Divisions", ПолучитьСписокОргструктурыПоРодителю(ЗапросСоотвествие.Получить("Parent ID")));
		Иначе
			ОтветСтруктура.Вставить("Divisions", ПолучитьСписокОргструктурыПоРодителю());
		КонецЕсли;
		
		Возврат ОтветСтруктура; 
		
	КонецЕсли;
	
	// Создание
	Если Не ЗначениеЗаполнено(ЗапросСоотвествие.Получить("ID")) Тогда	
		Возврат СоздатьОргструктуру(ЗапросСоотвествие);
	КонецЕсли; 
	
	// удаление
	Если НачалоДня(ПрочитатьДатуJSON(ЗапросСоотвествие.Получить("Status"), ФорматДатыJSON.ISO)) = НачалоДня(ТекущаяДата()) Тогда
		Возврат УдалитьОргструктуру(ЗапросСоотвествие.Получить("ID"));
	КонецЕсли;
	
	// измение
	Возврат ИзменениеЭлементаДерева(ЗапросСоотвествие);
КонецФункции
#КонецОбласти

#Область ПроцедурыДляРаботыСоСправочникаОргструктуры 
#Область ПолучениеДанныхПоДереву
Функция ПолучитьСписокОргструктурыИзСписка(СписокID)
	ПодразделениеМассив = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Оргструктура.Код КАК Код,
		|	Оргструктура.Наименование КАК Наименование,
		|	Оргструктура.КодПоздразделения КАК КодПоздразделения,
		|	Оргструктура.Статус КАК Статус,
		|	Оргструктура.ПутьВложенности КАК ПутьВложенности
		|ИЗ
		|	Справочник.Оргструктура КАК Оргструктура
		|ГДЕ
		|	Оргструктура.Код В (&Код)";
	
	Запрос.УстановитьПараметр("Код", СписокID);

	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ОргструктурСтруктура = Новый Структура;
		
		ОргструктурСтруктура.Вставить("ID", ВыборкаДетальныеЗаписи.Код);
		ОргструктурСтруктура.Вставить("Name", ВыборкаДетальныеЗаписи.Наименование);
		ОргструктурСтруктура.Вставить("Department", ВыборкаДетальныеЗаписи.КодПоздразделения);
		ОргструктурСтруктура.Вставить("Status", ВыборкаДетальныеЗаписи.Статус);
		ОргструктурСтруктура.Вставить("Parents", ВыборкаДетальныеЗаписи.ПутьВложенности);
		
		ПодразделениеМассив.Добавить(ОргструктурСтруктура);
	КонецЦикла;
	
	Возврат ПодразделениеМассив;
КонецФункции

Функция ПолучитьСписокОргструктурыПоРодителю(ID = "")
	ПодразделениеМассив = Новый Массив;
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	Оргструктура.Код КАК Код,
	                      |	Оргструктура.Наименование КАК Наименование,
	                      |	Оргструктура.КодПоздразделения КАК КодПоздразделения,
	                      |	Оргструктура.Статус КАК Статус,
	                      |	Оргструктура.ПутьВложенности КАК ПутьВложенности
	                      |ИЗ
	                      |	Справочник.Оргструктура КАК Оргструктура
						  |ГДЕ
						  |	ПутьВложенности ПОДОБНО &ID");
	Запрос.УстановитьПараметр("ID", "%"+ID+"%");
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл
		ОргструктурСтруктура = Новый Структура;
		
		ОргструктурСтруктура.Вставить("ID", РезультатЗапроса.Код);
		ОргструктурСтруктура.Вставить("Name", РезультатЗапроса.Наименование);
		ОргструктурСтруктура.Вставить("Department", РезультатЗапроса.КодПоздразделения);
		ОргструктурСтруктура.Вставить("Status", РезультатЗапроса.Статус);
		ОргструктурСтруктура.Вставить("Parents", РезультатЗапроса.ПутьВложенности);
		
		ПодразделениеМассив.Добавить(ОргструктурСтруктура);
	КонецЦикла;
	
	Возврат ПодразделениеМассив;
КонецФункции

Функция ПроверитьСуществованиеЭлементаПоID(ID) 	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	Оргструктура.Код КАК Код
	                      |ИЗ
	                      |	Справочник.Оргструктура КАК Оргструктура
	                      |ГДЕ
	                      |	Оргструктура.Код = &Код");
	Запрос.УстановитьПараметр("Код", ID);
	
	ВыборкаОргструктуры = Запрос.Выполнить().Выгрузить();
	
	Возврат ?(ВыборкаОргструктуры.Количество() > 0, Истина, Ложь);
	
КонецФункции

Функция СформироватьПутьВложенияОргструктры(ID)
	СписокID = Новый Массив;  
	
	Для Каждого Элемент Из ПолучитьДеревоВложений(ID, Новый Массив) Цикл
		СписокID.Добавить(Элемент);
	КонецЦикла;
	
	
	ОбратныйСписокID = Новый Массив;
	
	Индекс = СписокID.ВГраница();
	Пока Индекс >= 0 Цикл                                       
		ОбратныйСписокID.Добавить(СписокID[Индекс]);
		Индекс = Индекс - 1;
	КонецЦикла;
	
	Возврат СтрСоединить(ОбратныйСписокID, " <- ");
КонецФункции

Функция ПолучитьДеревоВложений(ID, Знач СписокID)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Оргструктура.ParentID КАК ParentID
	               |ИЗ
	               |	Справочник.Оргструктура КАК Оргструктура
	               |ГДЕ
	               |	Оргструктура.Код = &Код";
	Запрос.УстановитьПараметр("Код", ID);
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Если РезультатЗапроса.Количество() > 0 И ЗначениеЗаполнено(РезультатЗапроса[0].ParentID) Тогда
		СписокID.Добавить(РезультатЗапроса[0].ParentID);
		ПолучитьДеревоВложений(РезультатЗапроса[0].ParentID, СписокID);
	КонецЕсли;
	
	Возврат СписокID;
КонецФункции 

Функция ПолучитьIDПоНаименованию(Наименование)
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	Оргструктура.Код КАК Код
	                      |ИЗ
	                      |	Справочник.Оргструктура КАК Оргструктура
	                      |ГДЕ
	                      |	Оргструктура.Наименование = &Наименование");
	Запрос.УстановитьПараметр("Наименование", Наименование);
	
	ВыборкаОргструктуры = Запрос.Выполнить().Выгрузить();
	
	Возврат ?(ВыборкаОргструктуры.Количество() > 0, ВыборкаОргструктуры[0].Код, "");
КонецФункции

Функция ПолучитьСписокДочерниеВетки(ID)
	СписокДочернихВетокСсылки = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Оргструктура.Код КАК Код
	               |ИЗ
	               |	Справочник.Оргструктура КАК Оргструктура
	               |ГДЕ
	               |	Оргструктура.ParentID = &ParentID";
	
	Запрос.УстановитьПараметр("ParentID", ID);
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл
		СписокДочернихВетокСсылки.Добавить(РезультатЗапроса.Код);
	КонецЦикла;
	
	Возврат СписокДочернихВетокСсылки;
КонецФункции
#КонецОбласти


#Область ИзменнеиеДерева 
Функция ИзменениеЭлементаДерева(ДанныеДляИзменеияСоответствие)
	ОтветСтруктура = Новый Структура;
	
	ЭлементДереваОбъект = Справочники.Оргструктура.НайтиПоКоду(ДанныеДляИзменеияСоответствие.Получить("ID")).ПолучитьОбъект();
	
	#Область ПроверкаЭлемента
	// есть ли такой?
	Если Не ЗначениеЗаполнено(ПроверитьСуществованиеЭлементаПоID(ДанныеДляИзменеияСоответствие.Получить("ID"))) Тогда
		ОтветСтруктура.Вставить("ID", ДанныеДляИзменеияСоответствие.Получить("ID"));
		ОтветСтруктура.Вставить("Message", "Такого элемента не существует");
		ОтветСтруктура.Вставить("Status", "Error");  
		
		Возврат ОтветСтруктура
	КонецЕсли;
	
	// занято имя? 
	НайденнныйОбъектПоНаименованию = ПолучитьIDПоНаименованию(ДанныеДляИзменеияСоответствие.Получить("Name"));
	Если ЗначениеЗаполнено(НайденнныйОбъектПоНаименованию) и НайденнныйОбъектПоНаименованию <> ДанныеДляИзменеияСоответствие.Получить("ID") Тогда
		ОтветСтруктура.Вставить("ID", ДанныеДляИзменеияСоответствие.Получить("ID"));
		ОтветСтруктура.Вставить("Message", "Изменить не получится, т.к. наименование уже имеется");
		ОтветСтруктура.Вставить("Status", "Error");
		Возврат ОтветСтруктура;
	КонецЕсли;
		
	Если ЭлементДереваОбъект.ParentID <> ДанныеДляИзменеияСоответствие.Получить("Parent ID") Тогда
		Если ЗначениеЗаполнено(ДанныеДляИзменеияСоответствие.Получить("Parent ID")) Тогда
			Если Не ПроверитьСуществованиеЭлементаПоID(ДанныеДляИзменеияСоответствие.Получить("Parent ID")) Тогда
				ОтветСтруктура.Вставить("ID", ДанныеДляИзменеияСоответствие.Получить("ID"));
				ОтветСтруктура.Вставить("Message", СтрШаблон("Объекта с кодом %1 не существует", ДанныеДляИзменеияСоответствие.Получить("Parent ID")));
				ОтветСтруктура.Вставить("Status", "Error");  
		
				Возврат ОтветСтруктура	
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	Оргструктура.КодПоздразделения КАК КодПоздразделения
	                      |ИЗ
	                      |	Справочник.Оргструктура КАК Оргструктура
	                      |ГДЕ
	                      |	Оргструктура.Код <> &Код
	                      |	И Оргструктура.КодПоздразделения ПОДОБНО &КодПоздразделения");
	Запрос.УстановитьПараметр("Код", ДанныеДляИзменеияСоответствие.Получить("ID"));
	Запрос.УстановитьПараметр("КодПоздразделения", ДанныеДляИзменеияСоответствие.Получить("Department code"));
	
	РезуальтатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Если РезуальтатЗапроса.Количество() > 0 Тогда
		ОтветСтруктура.Вставить("ID", ДанныеДляИзменеияСоответствие.Получить("ID"));
		ОтветСтруктура.Вставить("Message", "Такой код подразделеняи уже существует");
		ОтветСтруктура.Вставить("Status", "Error");  
		
		Возврат ОтветСтруктура;
	КонецЕсли;  
	#КонецОбласти
	
	#Область КорректировкаЭлемента
	ОтвязкаЭлементаИзДерева(ДанныеДляИзменеияСоответствие.Получить("ID"));
	
	ДеревоВложений = СформироватьПутьВложенияОргструктры(ДанныеДляИзменеияСоответствие.Получить("Parent ID"));
	
	ЭлементДереваОбъект.КодПоздразделения = ДанныеДляИзменеияСоответствие.Получить("Department code");
	ЭлементДереваОбъект.Наименование = ДанныеДляИзменеияСоответствие.Получить("Name");
	ЭлементДереваОбъект.ParentID = ДанныеДляИзменеияСоответствие.Получить("Parent ID");
	ЭлементДереваОбъект.Статус = ЗаписатьДатуJSON(ТекущаяДата(), ФорматДатыJSON.ISO);
	
	Если ЗначениеЗаполнено(ДеревоВложений) Тогда 
		ДеревоВложенийМассив = Новый Массив;
		ДеревоВложенийМассив.Добавить(ДеревоВложений);
		ДеревоВложенийМассив.Добавить(ДанныеДляИзменеияСоответствие.Получить("Parent ID")); 
		ДеревоВложений = СтрСоединить(ДеревоВложенийМассив, "<-");
	Иначе
		ДеревоВложений = ДанныеДляИзменеияСоответствие.Получить("Parent ID"); 
	КонецЕсли;
	
	ЭлементДереваОбъект.ПутьВложенности = ДеревоВложений;
	
	Попытка
		ЭлементДереваОбъект.Записать();
	Исключение   
		ОтветСтруктура.Вставить("ID", ДанныеДляИзменеияСоответствие.Получить("ID"));
		ОтветСтруктура.Вставить("Message", "Не удалось изменить объект. Причичина: " + ОписаниеОшибки());
		ОтветСтруктура.Вставить("Status", "Error");
		Возврат ОтветСтруктура;
	КонецПопытки;
	
		ОтветСтруктура.Вставить("ID", ДанныеДляИзменеияСоответствие.Получить("ID"));
		ОтветСтруктура.Вставить("Message", "Имзененно");
		ОтветСтруктура.Вставить("Status", "Access");
		
		Возврат ОтветСтруктура
	#КонецОбласти
	
КонецФункции

Функция СоздатьОргструктуру(ДанныеОргсруктурыСоотвествие)
	КодСуществующегоОбъекта = ПолучитьIDПоНаименованию(ДанныеОргсруктурыСоотвествие.Получить("Name"));
	Если ЗначениеЗаполнено(КодСуществующегоОбъекта) Тогда
		Возврат Новый Структура("ID, Message, Status", КодСуществующегоОбъекта, "Такой объект уже имеется", "Error");
	КонецЕсли; 
	
	НоваяОргуструктура = Справочники.Оргструктура.СоздатьЭлемент();
	
	GUID = Строка(Новый УникальныйИдентификатор); 
	
	ДеревоВложений = СформироватьПутьВложенияОргструктры(ДанныеОргсруктурыСоотвествие.Получить("Parent ID"));
	
	
	Если ЗначениеЗаполнено(ДеревоВложений) Тогда 
		ДеревоВложенийМассив = Новый Массив;
		ДеревоВложенийМассив.Добавить(ДеревоВложений);
		ДеревоВложенийМассив.Добавить(ДанныеОргсруктурыСоотвествие.Получить("Parent ID")); 
		ДеревоВложений = СтрСоединить(ДеревоВложенийМассив, "<-");
	Иначе
		ДеревоВложений = ДанныеОргсруктурыСоотвествие.Получить("Parent ID"); 
	КонецЕсли;
	
	
	
	НоваяОргуструктура.Код = GUID;
	НоваяОргуструктура.Наименование = ДанныеОргсруктурыСоотвествие.Получить("Name");
	НоваяОргуструктура.ParentID = ДанныеОргсруктурыСоотвествие.Получить("Parent ID");		
	НоваяОргуструктура.КодПоздразделения = ДанныеОргсруктурыСоотвествие.Получить("Department code");
	НоваяОргуструктура.ПутьВложенности = ДеревоВложений;           
	НоваяОргуструктура.Статус = ПрочитатьДатуJSON(ДанныеОргсруктурыСоотвествие.Получить("Status"), ФорматДатыJSON.ISO);  		                                                                                                                                        
	
	Попытка
		НоваяОргуструктура.Записать();
	Исключение   
		ОтветСтруктра = Новый Структура("ID, Message, Status", GUID, СтрШаблон("Не удалось создать новый объект. Причина: %1", ОписаниеОшибки()), "Error");
		
	КонецПопытки;
	
	Возврат Новый Структура("ID, Message, Status", GUID, "Создано", "Success");
КонецФункции 

Функция УдалитьОргструктуру(ID)
	Ответ = Новый Структура;
	
	Если Не ПроверитьСуществованиеЭлементаПоID(ID) Тогда
		Ответ.Вставить("ID", ID);
		Ответ.Вставить("Message", "Такого элемента не существует");
		Ответ.Вставить("Status", "Error");
		
		Возврат Ответ;
	КонецЕсли;
	
	ОтвязкаЭлементаИзДерева(ID);     
	
	Попытка
		ТекущийЭлемент = Справочники.Оргструктура.НайтиПоКоду(ID).ПолучитьОбъект();
		ТекущийЭлемент.Удалить();
	Исключение
		Ответ.Вставить("ID", ID);
		Ответ.Вставить("Message", СтрШаблон("Не удалось удалить объект. Причина: %1", ОписаниеОшибки()));
		Ответ.Вставить("Status", "Error"); 
		
		Возврат Ответ 
	КонецПопытки;
	
	Ответ.Вставить("ID", ID);
	Ответ.Вставить("Message", "Объект удален");
	Ответ.Вставить("Status", "Access");
	
	Возврат Ответ;
	
	
КонецФункции

Процедура ОтвязкаЭлементаИзДерева(ID) 
	РодительскаяВетка = ПолучитьДеревоВложений(ID, Новый Массив);
	СписокДочернихВеток = ПолучитьСписокДочерниеВетки(ID);
	
	Для Каждого ДочерняяВетка Из СписокДочернихВеток Цикл
		ВеткаОбъект = Справочники.Оргструктура.НайтиПоКоду(ДочерняяВетка).ПолучитьОбъект();	
		ВеткаОбъект.ParentID = ?(РодительскаяВетка.Количество() > 0, РодительскаяВетка[0], "");  
		ВеткаОбъект.ПутьВложенности = СформироватьПутьВложенияОргструктры(ID);
		ВеткаОбъект.Записать();	                                
		
		СкорректироватьПутьУПодчиненныхЭлементов(ДочерняяВетка);
	КонецЦикла;
КонецПроцедуры

Процедура СкорректироватьПутьУПодчиненныхЭлементов(ID)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Оргструктура.Код КАК Код
	               |ИЗ
	               |	Справочник.Оргструктура КАК Оргструктура
	               |ГДЕ
	               |	Оргструктура.ParentID = &ParentID";
	Запрос.УстановитьПараметр("ParentID", ID);

	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл
		ЭлементОбъект = Справочники.Оргструктура.НайтиПоКоду(РезультатЗапроса.Код).ПолучитьОбъект();
		ЭлементОбъект.ПутьВложенности = СформироватьПутьВложенияОргструктры(РезультатЗапроса.Код);
		ЭлементОбъект.Записать();
		СкорректироватьПутьУПодчиненныхЭлементов(РезультатЗапроса.Код);
	КонецЦикла;
	
КонецПроцедуры
#КонецОбласти
#КонецОбласти