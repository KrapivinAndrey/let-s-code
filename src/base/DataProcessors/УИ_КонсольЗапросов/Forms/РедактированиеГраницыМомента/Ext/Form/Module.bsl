﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	КопироватьДанныеФормы(Параметры.Объект, Объект);
	
	Значение = Параметры.Значение;
	Если Значение.Тип = "Граница" Тогда
		
		Элементы.ГруппаГраница.Видимость = Истина;
		Элементы.ГруппаМоментВремени.Видимость = Ложь;
		Заголовок = "Граница времени";
		
		ЗначениеГраницы = Значение.Значение;
		ВидГраницы = Значение.ВидГраницы;
		
	ИначеЕсли Значение.Тип = "МоментВремени" Тогда
		
		Элементы.ГруппаГраница.Видимость = Ложь;
		Элементы.ГруппаМоментВремени.Видимость = Истина;
		Заголовок = "Момент времени";
		
		ДатаМомента = Значение.Дата;
		СсылкаМомента = Значение.Ссылка;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
//Дублирование кода, конечно, но избежим обращение на сервер. В модуле объекта есть Контейнер_ПолучитьПредставление.
Функция ПолучитьПредставлениеГраницы()
	Возврат Строка(Значение.Значение) + " " + Значение.ВидГраницы;
КонецФункции
	
&НаКлиенте
//Дублирование кода, конечно, но избежим обращение на сервер. В модуле объекта есть Контейнер_ПолучитьПредставление.
Функция ПолучитьПредставлениеМомента()
	Возврат Строка(Значение.Дата) + ";" + Значение.Ссылка;
КонецФункции

&НаКлиенте
Процедура КомандаОК(Команда)
	
	Если Значение.Тип = "Граница" Тогда
		
		Значение.Значение = ЗначениеГраницы;
		Значение.ВидГраницы = ВидГраницы;
		Значение.Представление = ПолучитьПредставлениеГраницы();
		
	ИначеЕсли Значение.Тип = "МоментВремени" Тогда
		
		Значение.Дата = ДатаМомента;
		Значение.Ссылка = СсылкаМомента;
		Значение.Представление = ПолучитьПредставлениеМомента();
		
	КонецЕсли;
	
	ВозвращаемоеЗначение = Новый Структура("Значение", Значение);
	Закрыть(ВозвращаемоеЗначение);
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьДатуСсылки(Ссылка)
	Перем ТаблицаБазы;
	
	Если Документы.ТипВсеСсылки().СодержитТип(ТипЗнч(Ссылка)) Тогда
		//@skip-warning
		ТаблицаБазы = "Документ." + Ссылка.Метаданные().Имя;
	ИначеЕсли Задачи.ТипВсеСсылки().СодержитТип(ТипЗнч(Ссылка)) Тогда
		//@skip-warning
		ТаблицаБазы = "Задача." + Ссылка.Метаданные().Имя;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ТаблицаБазы) Тогда
		Запрос = Новый Запрос("ВЫБРАТЬ Дата ИЗ " + ТаблицаБазы + " ГДЕ Ссылка = &Ссылка");
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			Возврат Выборка.Дата;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

&НаКлиенте
Процедура СсылкаМоментаПриИзменении(Элемент)
	ДатаСсылки = ПолучитьДатуСсылки(СсылкаМомента);
	Если ЗначениеЗаполнено(ДатаСсылки) Тогда
		ДатаМомента = ДатаСсылки;
	КонецЕсли;
КонецПроцедуры
