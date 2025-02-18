﻿Функция ИтогиИгры() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДевБаттл_Результаты.Игрок КАК Игрок,
		|	СУММА(ВЫБОР
		|			КОГДА ДевБаттл_Результаты.Выполнено
		|				ТОГДА 1
		|			ИНАЧЕ 0
		|		КОНЕЦ) КАК Баллы
		|ИЗ
		|	РегистрСведений.ДевБаттл_Результаты КАК ДевБаттл_Результаты
		|
		|СГРУППИРОВАТЬ ПО
		|	ДевБаттл_Результаты.Игрок
		|
		|УПОРЯДОЧИТЬ ПО
		|	Баллы УБЫВ";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		Баллы = Новый Массив;
		Баллы.Добавить(0);
		Баллы.Добавить(0);
		Результат = НовыйРезультатИгры(Баллы, "Ведущий");
		
	Иначе                                                    
		
		ТаблицаРезультаты = РезультатЗапроса.Выгрузить();
		
		Если ТаблицаРезультаты[0].Баллы = ТаблицаРезультаты[1].Баллы Тогда
			
			Победитель = "Ничья";
			
		Иначе
			
			Победитель = ТаблицаРезультаты[0].Игрок;
			
		КонецЕсли;
		
		
		Результат = НовыйРезультатИгры(ТаблицаРезультаты.ВыгрузитьКолонку("Баллы")
										, Победитель);
		
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция НовыйРезультатИгры(Баллы, Победитель)
	
	Результат = Новый Структура;
	Счет = "";                  
	Разделитель = "";
	Для Каждого Балл Из Баллы Цикл

		Счет = Счет + Разделитель + Строка(Балл);
		Разделитель = " : ";
		
	КонецЦикла;
		
	Результат.Вставить("Счет", Счет);
	Результат.Вставить("Победитель", Победитель);
	
	Возврат Результат;
	
КонецФункции

Функция ЗадачаИгрока() Экспорт
	
	// Получить задачу раунда
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДевБаттл_СписокЗаданий.Задача КАК Задача,
		|	ЕСТЬNULL(ДевБаттл_Результаты.ПотраченоВремени, ДевБаттл_СписокЗаданий.ВремяНаЗадачу) КАК ВремяНаЗадачу,
		|	ДевБаттл_СписокЗаданий.Отсрочка КАК Отсрочка
		|ИЗ
		|	РегистрСведений.ДевБаттл_СписокЗаданий КАК ДевБаттл_СписокЗаданий
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДевБаттл_Результаты КАК ДевБаттл_Результаты
		|		ПО ДевБаттл_СписокЗаданий.Игрок <> ДевБаттл_Результаты.Игрок
		|			И ДевБаттл_СписокЗаданий.НомерРаунда = ДевБаттл_Результаты.НомерРаунда
		|			И (ДевБаттл_Результаты.Выполнено)
		|ГДЕ
		|	ДевБаттл_СписокЗаданий.Игрок = &Игрок
		|	И ДевБаттл_СписокЗаданий.НомерРаунда = &НомерРаунда";
	
	Запрос.УстановитьПараметр("Игрок",			ПараметрыСеанса.ИмяПользователя);
	Запрос.УстановитьПараметр("НомерРаунда",	Константы.ДевБаттл_Раунд.Получить());	
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		
		ВызватьИсключение "Не удалось получить задачу раунда";
		
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	
	Результат = НовыйЗадачиИгрока(Выборка.Задача, Выборка.ВремяНаЗадачу, Выборка.Отсрочка);
	
	Возврат Результат;
	
КонецФункции

Функция НовыйЗадачиИгрока(Задача, ВремяНаЗадачу, Отсрочка)
	
	Возврат Новый Структура("Задача, ВремяНаЗадачу, Отсрочка"
								, Задача
								, ВремяНаЗадачу
								, Отсрочка);
	
КонецФункции

Процедура ИспытаниеОкончено(Выполнено, ПотраченоВремени = 0) Экспорт
	
	ИмяИгрока = ПараметрыСеанса.ИмяПользователя;
	
	ДевБаттл_ОбщегоНазначенияВызовСервера.ЗафиксироватьРезультатИспытания(ИмяИгрока
																		, Выполнено
																		, ПотраченоВремени);
	
КонецПроцедуры
																	
Функция ТекущееСостояние() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДевБаттл_ТекущееСостояниеИгрока.Состояние КАК Состояние
		|ИЗ
		|	РегистрСведений.ДевБаттл_ТекущееСостояниеИгрока КАК ДевБаттл_ТекущееСостояниеИгрока
		|ГДЕ
		|	ДевБаттл_ТекущееСостояниеИгрока.Игрок = &Игрок";
	
	Запрос.УстановитьПараметр("Игрок", ПараметрыСеанса.ИмяПользователя);
	
	РезультатЗапроса = Запрос.Выполнить();                                                    
	
	Если РезультатЗапроса.Пустой() Тогда
		
		Состояние = Перечисления.ДевБаттл_СостояниеИгрока.НачалоИгры;
		
	Иначе
		
	    ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	    ВыборкаДетальныеЗаписи.Следующий();
		Состояние = ВыборкаДетальныеЗаписи.Состояние;
		
	КонецЕсли;
	
	Возврат Состояние;
	
КонецФункции

Функция ЕстьИгрокиЗавершившиеРаунд() Экспорт
	
	НомерРаунда = Константы.ДевБаттл_Раунд.Получить();
	Игрок = ПараметрыСеанса.ИмяПользователя;
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДевБаттл_Результаты.Игрок КАК Игрок,
		|	ДевБаттл_Результаты.НомерРаунда КАК НомерРаунда,
		|	ДевБаттл_Результаты.Выполнено КАК Выполнено
		|ИЗ
		|	РегистрСведений.ДевБаттл_Результаты КАК ДевБаттл_Результаты
		|ГДЕ
		|	ДевБаттл_Результаты.НомерРаунда = &НомерРаунда
		|	И ДевБаттл_Результаты.Выполнено
		|	И ДевБаттл_Результаты.Игрок <> &Игрок";
	
	Запрос.УстановитьПараметр("НомерРаунда", НомерРаунда);
	Запрос.УстановитьПараметр("Игрок", Игрок);
	
	РезультатЗапроса = Запрос.Выполнить();                                                    
	
	Возврат Не РезультатЗапроса.Пустой();
	
КонецФункции