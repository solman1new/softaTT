#Область ОбработкаВходящегоЗапроса
Функция ОбработкаЗапроса(ЗапросСоотвествие) Экспорт 
	
	// выдача дерева
	Если ТипЗнч(ЗапросСоотвествие.Получить("ID")) = Тип("Массив") Тогда 
		Возврат Новый Структура("Divisions", ПолучитьМассивДерева(ЗапросСоотвествие));  		
	КонецЕсли;
	
	// Создание
	Если Не ЗначениеЗаполнено(ЗапросСоотвествие.Получить("ID")) Тогда	
		Возврат СоздатьОргструктуру(ЗапросСоотвествие);
	КонецЕсли; 
	
	// удаление
	Если НачалоДня(ПрочитатьДатуJSON(ЗапросСоотвествие.Получить("Status"), ФорматДатыJSON.ISO)) = НачалоДня(ТекущаяДата()) Тогда
		Возврат УдалитьЭлемент(ЗапросСоотвествие);
	КонецЕсли;
	
	// измение
	//Возврат ИзменениеЭлементаДерева(ЗапросСоотвествие);
	Возврат ИзменитьЭлементДерева(ЗапросСоотвествие);
КонецФункции
#КонецОбласти


#Область ПроцедурыДляРаботыСоСправочникаОргструктуры 
Функция ИзменитьЭлементДерева(ПараметрыСоответствие)
	ParentID = ПараметрыСоответствие.Получить("Parent ID");
	ID = ПараметрыСоответствие.Получить("ID");
	Наименование = ПараметрыСоответствие.Получить("Name"); 
	КодПодразделения = ПараметрыСоответствие.Получить("Department code");
	
	Если Не ЭлементСуществует(ID) Тогда
		Возврат Новый Структура("ID, Message, Status", ID, СтрШаблон("Элемента с кодом %1 не существует", ID), "Error");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ParentID) Тогда
		Если НЕ ЭлементСуществует(ParentID) Тогда
			Возврат Новый Структура("ID, Message, Status", ID, СтрШаблон("Элемента с кодом %1 не существует", ParentID), "Error");	
		КонецЕсли;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Оргструктура.Код КАК Код,
	               |	Оргструктура.Наименование КАК Наименование,
	               |	Оргструктура.КодПоздразделения КАК КодПоздразделения
	               |ИЗ
	               |	Справочник.Оргструктура КАК Оргструктура
	               |ГДЕ
	               |	Оргструктура.Код <> &Код
	               |	И 
				   |	(Оргструктура.Наименование = &Наименование
	               |	ИЛИ Оргструктура.КодПоздразделения ПОДОБНО &КодПоздразделения)";
	
	Запрос.УстановитьПараметр("Код", ID);
	Запрос.УстановитьПараметр("Наименование", Наименование);
	Запрос.УстановитьПараметр("КодПоздразделения", КодПодразделения);
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Если РезультатЗапроса.Следующий() Тогда
		Если РезультатЗапроса.Наименование = Наименование Тогда
			Возврат Новый Структура("ID, Message, Status", ID, СтрШаблон("Элемент с наименованием %1 уже имеет %2", Наименование,РезультатЗапроса.Код), "Error");
		КонецЕсли;
		
		Если РезультатЗапроса.КодПоздразделения = КодПодразделения Тогда
			Возврат Новый Структура("ID, Message, Status", ID, СтрШаблон("Элемент с таким кодо подразделения %1 уже имеет %2", КодПодразделения,РезультатЗапроса.Код), "Error");
		КонецЕсли;
	КонецЕсли;
	
	
	НовыйПутьВложенности = "";
	ПутьВложенностиМассив = Новый Массив;
	ПутьВложенностиМассив.Добавить(ПолучитьДеревоВложенийВСтроке(ParentID, Истина));
	
	Если ЗначениеЗаполнено(ПутьВложенностиМассив[0]) Тогда
		ПутьВложенностиМассив.Добавить(ParentID);
		ПутьВложенности = СокрЛП(СтрСоединить(ПутьВложенностиМассив, " <- "));
	Иначе
		НовыйПутьВложенности = СокрЛП(Строка(НовыйПутьВложенности + ParentID));
	КонецЕсли; 
	
	ЭлементДереваОбъект = Справочники.Оргструктура.НайтиПоКоду(ID).ПолучитьОбъект();
	ЭлементДереваОбъект.Наименование = Наименование;
	ЭлементДереваОбъект.КодПоздразделения = КодПодразделения;
	
	СтарыйПутьВложения = ЭлементДереваОбъект.ПутьВложенности;
	
	ЭлементДереваОбъект.ПутьВложенности = НовыйПутьВложенности;
	
	СтарыйParentID = ЭлементДереваОбъект.ParentID;
	
	ЭлементДереваОбъект.ParentID = ParentID;
	
	Попытка
		ЭлементДереваОбъект.Записать();
	Исключение   
		Возврат Новый Структура("ID, Message, Status", ID, СтрШаблон("Не удалось создать новый объект. Причина: %1", ОписаниеОшибки()), "Error");
	КонецПопытки;
	
	ПослеИзменитьПоложенияВДереве(ID, СтарыйParentID, СтарыйПутьВложения);  
	
	Возврат Новый Структура("ID, Message, Status", ID, "Измененно", "Success");	
КонецФункции

Функция СоздатьОргструктуру(ПараметрыСоответствие) 	
	ParentID = ПараметрыСоответствие.Получить("Parent ID");
	GUID = Строка(Новый УникальныйИдентификатор);
	Наименование = ПараметрыСоответствие.Получить("Name"); 
	КодПодразделения = ПараметрыСоответствие.Получить("Department code");
	Статус = ПрочитатьДатуJSON(ПараметрыСоответствие.Получить("Status"), ФорматДатыJSON.ISO);
	
	Если НаименованиеЗанято(Наименование) Тогда
		Возврат Новый Структура("ID, Message, Status", "", "Наименование занято", "Error");
	КонецЕсли; 
	
	Если КодПодразделенияЗанят(КодПодразделения) Тогда
		Возврат Новый Структура("ID, Message, Status", "", "Код подразделения занят", "Error");
	КонецЕсли;  

	Если Не ЭлементСуществует(ParentID) И ЗначениеЗаполнено(ParentID) Тогда
		Возврат Новый Структура("ID, Message, Status", "", СтрШаблон("Элемента с кодом %1 не существует", ParentID), "Error");
	КонецЕсли;
		
	НоваяВетка = Справочники.Оргструктура.СоздатьЭлемент();	
	
	ПутьВложенности = "";
	ПутьВложенностиМассив = Новый Массив;
	ПутьВложенностиМассив.Добавить(ПолучитьДеревоВложенийВСтроке(ParentID, Истина));
	
	Если ЗначениеЗаполнено(ПутьВложенностиМассив[0]) Тогда
		ПутьВложенностиМассив.Добавить(ParentID);
		ПутьВложенности = СтрСоединить(ПутьВложенностиМассив, " <- ");
	Иначе
		ПутьВложенности = ПутьВложенности + ParentID;
	КонецЕсли;
	
	
	
	НоваяВетка.Код = GUID;
	НоваяВетка.Наименование = Наименование;
	НоваяВетка.ParentID = ParentID;
	НоваяВетка.КодПоздразделения = КодПодразделения; 
	НоваяВетка.ПутьВложенности = ПутьВложенности;
			
	Попытка
		НоваяВетка.Записать();
	Исключение   
		Возврат Новый Структура("ID, Message, Status", "", СтрШаблон("Не удалось создать новый объект. Причина: %1", ОписаниеОшибки()), "Error");
	КонецПопытки;
	
	Возврат Новый Структура("ID, Message, Status", GUID, "Создано", "Success");
КонецФункции

Функция ПолучитьДеревоВложенийВСтроке(IDЭлментаСтартовый, Направление)
	СписокID = Новый Массив;  
	
	Для Каждого Элемент Из ПолучитьСписокСтруктурЭлементовВложения(IDЭлментаСтартовый, Направление, Новый Массив) Цикл
		СписокID.Добавить(Элемент.ParentID);
	КонецЦикла;
	
	
	ОбратныйСписокID = Новый Массив;
	
	Индекс = СписокID.ВГраница();
	Пока Индекс >= 0 Цикл 
		Если ЗначениеЗаполнено(СписокID[Индекс]) Тогда 
			Индекс = Индекс - 1;
			Продолжить;
		КонецЕсли;
		
		ОбратныйСписокID.Добавить(СписокID[Индекс]);
		Индекс = Индекс - 1;
	КонецЦикла;
	
	СимволРазделения = ?(Направление, " <- ", " -> "); 
	Возврат СокрЛП(СтрСоединить(ОбратныйСписокID, СимволРазделения));
КонецФункции 

Функция ПолучитьСписокСтруктурЭлементовВложения(IDЭлментаСтартовый, Направление, Список)
	Запрос = Новый Запрос;
	
	//Вверх
	Если Направление Тогда
		Запрос.Текст = "ВЫБРАТЬ
		               |	Оргструктура.Код КАК Код,
		               |	Оргструктура.Наименование КАК Наименование,
		               |	Оргструктура.КодПоздразделения КАК КодПоздразделения,
		               |	Оргструктура.Статус КАК Статус,
		               |	Оргструктура.ПутьВложенности КАК ПутьВложенности,
		               |	Оргструктура.ParentID КАК ParentID
	    	           |ИЗ
	    	           |	Справочник.Оргструктура КАК Оргструктура
	    	           |ГДЕ
	    	           |	Оргструктура.Код = &Код";
	КонецЕсли;
	
	//Вниз    
	Если Не Направление Тогда
		Запрос.Текст = "ВЫБРАТЬ
		               |	Оргструктура.Код КАК Код,
		               |	Оргструктура.Наименование КАК Наименование,
		               |	Оргструктура.КодПоздразделения КАК КодПоздразделения,
		               |	Оргструктура.Статус КАК Статус,
		               |	Оргструктура.ПутьВложенности КАК ПутьВложенности,
		               |	Оргструктура.ParentID КАК ParentID
		               |ИЗ
		               |	Справочник.Оргструктура КАК Оргструктура
		               |ГДЕ
		               |	Оргструктура.ParentID = &Код";
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Код", IDЭлментаСтартовый);
	
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	Пока РезультатЗапроса.Следующий() Цикл		
		Элемент = Новый Структура;
		Элемент.Вставить("Код", РезультатЗапроса.Код);
		Элемент.Вставить("Наименование", РезультатЗапроса.Наименование);
		Элемент.Вставить("КодПоздразделения", РезультатЗапроса.КодПоздразделения);
		Элемент.Вставить("Статус", РезультатЗапроса.Статус);
		Элемент.Вставить("ParentID", РезультатЗапроса.ParentID);
		Элемент.Вставить("ПутьВложенности", РезультатЗапроса.ПутьВложенности); 
		
		Список.Добавить(Элемент);  
		
		ПолучитьСписокСтруктурЭлементовВложения(?(Направление, РезультатЗапроса.ParentID, РезультатЗапроса.Код), Направление, Список);		
	КонецЦикла;
	
	Возврат Список;
КонецФункции

Функция ПолучитьМассивДерева(ЗапросСоотвествие)
	СписокЭлементов = Новый Массив;
	СписокЭлментовID = Новый Массив;
	
	СписокЭлементовИзЗапроса = ЗапросСоотвествие.Получить("ID");
	РодительИзЗапроса = ЗапросСоотвествие.Получить("Parent ID");
	СтатусИзЗапроса = ЗапросСоотвествие.Получить("Status");
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = 	"ВЫБРАТЬ
	               	|	Оргструктура.Код КАК Код,
	               	|	Оргструктура.Наименование КАК Наименование,
	               	|	Оргструктура.КодПоздразделения КАК КодПоздразделения,
	               	|	Оргструктура.Статус КАК Статус,
	               	|	Оргструктура.ПутьВложенности КАК ПутьВложенности,
	               	|	Оргструктура.ParentID КАК ParentID
	               	|ИЗ
	               	|	Справочник.Оргструктура КАК Оргструктура
	               	|ГДЕ
	               	|	Оргструктура.ParentID = &ParentID"; 
	
	Запрос.УстановитьПараметр("ParentID", РодительИзЗапроса);
	Если ЗначениеЗаполнено(СписокЭлементовИзЗапроса) Тогда
		Запрос.Текст = 	"ВЫБРАТЬ
		               	|	Оргструктура.Код КАК Код,
		               	|	Оргструктура.Наименование КАК Наименование,
		               	|	Оргструктура.КодПоздразделения КАК КодПоздразделения,
		               	|	Оргструктура.Статус КАК Статус,
		               	|	Оргструктура.ПутьВложенности КАК ПутьВложенности,
		               	|	Оргструктура.ParentID КАК ParentID
		               	|ИЗ
		               	|	Справочник.Оргструктура КАК Оргструктура
		               	|ГДЕ
		               	|	Оргструктура.Код В(&Код)
		               	|	И Оргструктура.ParentID = &ParentID";
		
		Запрос.УстановитьПараметр("Код", СписокЭлементовИзЗапроса); 
	КонецЕсли;
		
	РезультатЗапроса = Запрос.Выполнить().Выбрать(); 
		
	Пока РезультатЗапроса.Следующий() Цикл  
		
		Элемент = Новый Структура;
		Элемент.Вставить("ID", РезультатЗапроса.Код);
		Элемент.Вставить("Name", РезультатЗапроса.Наименование);
		Элемент.Вставить("Department", РезультатЗапроса.КодПоздразделения);
		Элемент.Вставить("Status", ?(ЗначениеЗаполнено(РезультатЗапроса.Статус), ЗаписатьДатуJSON(РезультатЗапроса.Статус,ФорматДатыJSON.ISO), ""));
		Элемент.Вставить("Parents", РезультатЗапроса.ПутьВложенности);
		
		Если СписокЭлментовID.Найти(РезультатЗапроса.Код) <> Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		СписокЭлементов.Добавить(Элемент);
		СписокЭлментовID.Добавить(РезультатЗапроса.Код);
		
		// если true, то выводим все элементы, которые находятся между ними
		Если СтатусИзЗапроса И (ЗначениеЗаполнено(РодительИзЗапроса) ИЛИ ЗначениеЗаполнено(СписокЭлементовИзЗапроса)) Тогда
			
			Ветки = Новый Массив; 
			
			Ветки = ПолучитьСписокСтруктурЭлементовВложения(РезультатЗапроса.ParentID, Истина, Новый Массив);
			
			Для Каждого Ветка Из Ветки Цикл
				Если СписокЭлментовID.Найти(Ветка.Код) <> Неопределено Тогда
					Продолжить;
				КонецЕсли;
				
				ЭлементДоч = Новый Структура;
				ЭлементДоч.Вставить("ID", Ветка.Код);
				ЭлементДоч.Вставить("Name", Ветка.Наименование);
				ЭлементДоч.Вставить("Department", Ветка.КодПоздразделения);
				ЭлементДоч.Вставить("Status", ?(ЗначениеЗаполнено(Ветка.Статус), ЗаписатьДатуJSON(Ветка.Статус,ФорматДатыJSON.ISO), ""));
				ЭлементДоч.Вставить("Parents", Ветка.ПутьВложенности);
				
				СписокЭлементов.Добавить(ЭлементДоч);
				СписокЭлментовID.Добавить(Ветка.Код);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;  
	
	Возврат СписокЭлементов;	
КонецФункции

Функция ЭлементСуществует(ID)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Оргструктура.Код КАК Код
	               |ИЗ
	               |	Справочник.Оргструктура КАК Оргструктура
	               |ГДЕ
	               |	Оргструктура.Код = &ID";
	
	Запрос.УстановитьПараметр("ID", ID);	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Возврат ?(РезультатЗапроса.Количество() > 0, Истина, Ложь);
КонецФункции

Функция КодПодразделенияЗанят(КодПодразделения)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Оргструктура.КодПоздразделения КАК КодПоздразделения
	               |ИЗ
	               |	Справочник.Оргструктура КАК Оргструктура
	               |ГДЕ
	               |	Оргструктура.КодПоздразделения ПОДОБНО &КодПоздразделения";
	
	Запрос.УстановитьПараметр("КодПоздразделения", КодПодразделения);	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Возврат ?(РезультатЗапроса.Количество() > 0, Истина, Ложь);
КонецФункции

Функция НаименованиеЗанято(Наименование)
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Оргструктура.Наименование КАК Наименование
	               |ИЗ
	               |	Справочник.Оргструктура КАК Оргструктура
	               |ГДЕ
	               |	Оргструктура.Наименование = &Наименование";
	
	Запрос.УстановитьПараметр("Наименование", Наименование);	
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Возврат ?(РезультатЗапроса.Количество() > 0, Истина, Ложь);
КонецФункции

Функция УдалитьЭлемент(ПараметрыСоответствие)
	ParentID = ПараметрыСоответствие.Получить("Parent ID");
	ID = ПараметрыСоответствие.Получить("ID");
	Наименование = ПараметрыСоответствие.Получить("Name"); 
	КодПодразделения = ПараметрыСоответствие.Получить("Department code");
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Оргструктура.ПутьВложенности КАК ПутьВложенности,
	               |	Оргструктура.Статус КАК Статус,
	               |	Оргструктура.Код КАК Код
	               |ИЗ
	               |	Справочник.Оргструктура КАК Оргструктура
	               |ГДЕ
	               |	Оргструктура.Код = &Код";
	Запрос.УстановитьПараметр("Код", ID);
	
	ПутьВложенности = "";
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	
	Если РезультатЗапроса.Количество() > 0 Тогда
		Если ЗначениеЗаполнено(РезультатЗапроса[0].Статус) Тогда
			Возврат Новый Структура("ID, Message, Status", ID, СтрШаблон("Элемента с кодом %1 ранее был удален", ID), "Error");
		КонецЕсли;
	Иначе
		Возврат Новый Структура("ID, Message, Status", ID, СтрШаблон("Элемента с кодом %1 не существует", ID), "Error");
	КонецЕсли;  
	
	ПослеИзменитьПоложенияВДереве(ID, ParentID, ПутьВложенности);
	
	ЭлементОбъект = Справочники.Оргструктура.НайтиПоКоду(ID).ПолучитьОбъект();
	ЭлементОбъект.ПутьВложенности = "";
	ЭлементОбъект.ParentID = "";
	ЭлементОбъект.Статус = ТекущаяДата();
	
	Попытка
		ЭлементОбъект.Записать();
	Исключение   
		Возврат Новый Структура("ID, Message, Status", ID, СтрШаблон("Не удалось создать удалить объект. Причина: %1", ОписаниеОшибки()), "Error");
	КонецПопытки;
	
	Возврат Новый Структура("ID, Message, Status", ID, "Удалено", "Success");
	
КонецФункции 

Процедура ПослеИзменитьПоложенияВДереве(ID, ParentID, ПутьВложенности) 
	//СписокДоч = ПолучитьСписокСтруктурЭлементовВложения(ID, Ложь, Новый Массив);
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	Оргструктура.Код КАК Код,
	                      |	Оргструктура.ParentID КАК ParentID
	                      |ИЗ
	                      |	Справочник.Оргструктура КАК Оргструктура
	                      |ГДЕ
	                      |	Оргструктура.ParentID = &ID");
	Запрос.УстановитьПараметр("ID", ID);
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	
	
	Пока РезультатЗапроса.Следующий() Цикл
		Элемент = Справочники.Оргструктура.НайтиПоКоду(РезультатЗапроса.Код).ПолучитьОбъект();
		Элемент.ParentID = ParentID;
		Элемент.ПутьВложенности = ПутьВложенности;	
		Элемент.Записать(); 
		СкорректироватьПутьДочернихВеток(РезультатЗапроса.Код);
	КонецЦикла;	
КонецПроцедуры

Процедура СкорректироватьПутьДочернихВеток(ID)
	СписокДоч = ПолучитьСписокСтруктурЭлементовВложения(ID, Истина, Новый Массив);
	
	Для Каждого Доч Из СписокДоч Цикл
		Элемент = Справочники.Оргструктура.НайтиПоКоду(Доч.Код).ПолучитьОбъект();
		Элемент.ПутьВложенности = ПолучитьДеревоВложенийВСтроке(Доч.Код, Истина);
		Элемент.Записать();
	КонецЦикла;
	
КонецПроцедуры    
#КонецОбласти