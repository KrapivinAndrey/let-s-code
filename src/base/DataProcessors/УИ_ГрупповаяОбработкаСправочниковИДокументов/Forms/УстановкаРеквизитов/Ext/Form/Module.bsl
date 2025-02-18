﻿//Признак использования настроек
&НаКлиенте
Перем мИспользоватьНастройки Экспорт;

//Типы объектов, для которых может использоваться обработка.
//По умолчанию для всех.
&НаКлиенте
Перем мТипыОбрабатываемыхОбъектов Экспорт;

&НаКлиенте
Перем мНастройка;

&НаСервере
Перем ТЗНО;

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Выполняет обработку объектов.
//
// Параметры:
//  Объект                 - обрабатываемый объект.
//  ПорядковыйНомерОбъекта - порядковый номер обрабатываемого объекта.
//
&НаСервере
Процедура ОбработатьОбъект(Ссылка, ПорядковыйНомерОбъекта, ПараметрыЗаписиОбъектов)
	//СтрокаТЧ=
	//
	Объект = Ссылка.ПолучитьОбъект();
	Если ОбрабатыватьТабличныеЧасти Тогда
		СтрокаТЧ=Объект[НайденныеОбъекты[ПорядковыйНомерОбъекта].Т_ТЧ][НайденныеОбъекты[ПорядковыйНомерОбъекта].Т_НомерСтроки
			- 1];
	КонецЕсли;

	Для Каждого Реквизит Из Реквизиты Цикл
		Если Реквизит.Выбрать Тогда
			Если Реквизит.РеквизитТЧ Тогда
				СтрокаТЧ[Реквизит.Реквизит] = Реквизит.Значение;
			Иначе
				Объект[Реквизит.Реквизит] = Реквизит.Значение;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;

//		Объект.Записать();
	Если УИ_ОбщегоНазначения.ЗаписатьОбъектВБазу(Объект, ПараметрыЗаписиОбъектов) Тогда
		УИ_ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрШаблон("Объект %1 УСПЕХ!!!", Объект));
	КонецЕсли;

КонецПроцедуры // ОбработатьОбъект()


// Выполняет обработку объектов.
//
// Параметры:
//  Нет.
//
&НаКлиенте
Функция ВыполнитьОбработку(ПараметрыЗаписиОбъектов) Экспорт

	Индикатор = ПолучитьИндикаторПроцесса(НайденныеОбъекты.Количество());
	Для Индекс = 0 По НайденныеОбъекты.Количество() - 1 Цикл
		ОбработатьИндикатор(Индикатор, Индекс + 1);

		СтрокаНайденныхОбъектов=НайденныеОбъекты.Получить(Индекс);

		Если СтрокаНайденныхОбъектов.Выбрать Тогда//

			ОбработатьОбъект(СтрокаНайденныхОбъектов.Объект, Индекс, ПараметрыЗаписиОбъектов);
		КонецЕсли;
	КонецЦикла;

	Если Индекс > 0 Тогда
		//ОповеститьОбИзменении(Тип(ОбъектПоиска.Тип + "Ссылка." + ОбъектПоиска.Имя));
	КонецЕсли;

	Возврат Индекс;
КонецФункции // вВыполнитьОбработку()

// Сохраняет значения реквизитов формы.
//
// Параметры:
//  Нет.
//
&НаКлиенте
Процедура СохранитьНастройку() Экспорт

	Если ПустаяСтрока(ТекущаяНастройкаПредставление) Тогда
		ПоказатьПредупреждение( ,
			"Задайте имя новой настройки для сохранения или выберите существующую настройку для перезаписи.");
	КонецЕсли;

	НоваяНастройка = Новый Структура;
	НоваяНастройка.Вставить("Обработка", ТекущаяНастройкаПредставление);
	НоваяНастройка.Вставить("Прочее", Новый Структура);
	
	//@skip-warning
	РеквизитыДляСохранения = ПолучитьМассивРеквизитов();

	Для Каждого РеквизитНастройки Из мНастройка Цикл
		Выполнить ("НоваяНастройка.Прочее.Вставить(Строка(РеквизитНастройки.Ключ), " + Строка(РеквизитНастройки.Ключ)
			+ ");");
	КонецЦикла;

	ДоступныеОбработки = ЭтаФорма.ВладелецФормы.ДоступныеОбработки;
	ТекущаяДоступнаяНастройка = Неопределено;
	Для Каждого ТекущаяДоступнаяНастройка Из ДоступныеОбработки.ПолучитьЭлементы() Цикл
		Если ТекущаяДоступнаяНастройка.ПолучитьИдентификатор() = Родитель Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Если ТекущаяНастройка = Неопределено Или Не ТекущаяНастройка.Обработка = ТекущаяНастройкаПредставление Тогда
		Если ТекущаяДоступнаяНастройка <> Неопределено Тогда
			НоваяСтрока = ТекущаяДоступнаяНастройка.ПолучитьЭлементы().Добавить();
			НоваяСтрока.Обработка = ТекущаяНастройкаПредставление;
			НоваяСтрока.Настройка.Добавить(НоваяНастройка);

			ЭтаФорма.ВладелецФормы.Элементы.ДоступныеОбработки.ТекущаяСтрока = НоваяСтрока.ПолучитьИдентификатор();
		КонецЕсли;
	КонецЕсли;

	Если ТекущаяДоступнаяНастройка <> Неопределено И ТекущаяСтрока > -1 Тогда
		Для Каждого ТекНастройка Из ТекущаяДоступнаяНастройка.ПолучитьЭлементы() Цикл
			Если ТекНастройка.ПолучитьИдентификатор() = ТекущаяСтрока Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;

		Если ТекНастройка.Настройка.Количество() = 0 Тогда
			ТекНастройка.Настройка.Добавить(НоваяНастройка);
		Иначе
			ТекНастройка.Настройка[0].Значение = НоваяНастройка;
		КонецЕсли;
	КонецЕсли;

	ТекущаяНастройка = НоваяНастройка;
	ЭтаФорма.Модифицированность = Ложь;
КонецПроцедуры // вСохранитьНастройку()

&НаСервере
Функция ПолучитьМассивРеквизитов()
	МассивРеквизитов = Новый Массив;
	Для Каждого Стр Из Реквизиты Цикл
		Если Не Стр.Выбрать Тогда
			Продолжить;
		КонецЕсли;

		СтруктураРеквизита = Новый Структура;
		СтруктураРеквизита.Вставить("Выбрать", Стр.Выбрать);
		СтруктураРеквизита.Вставить("Реквизит", Стр.Реквизит);
		СтруктураРеквизита.Вставить("Идентификатор", Стр.Идентификатор);
		СтруктураРеквизита.Вставить("Тип", Стр.Тип);
		СтруктураРеквизита.Вставить("Значение", Стр.Значение);

		МассивРеквизитов.Добавить(СтруктураРеквизита);
	КонецЦикла;

	Возврат МассивРеквизитов;
КонецФункции

&НаСервере
Процедура ЗагрузитьРеквизитыИзМассива(МассивРеквизитов)
	ТЗ = РеквизитФормыВЗначение("Реквизиты");
	
	//Перед установкой очистим существующие установки
	Для Каждого СтрокаТаблицы Из ТЗ Цикл
		СтрокаТаблицы.Выбрать=Ложь;
		СтрокаТаблицы.Значение=СтрокаТаблицы.Тип.ПривестиЗначение();
	КонецЦикла;

	Для Каждого Стр Из МассивРеквизитов Цикл
		Если Не Стр.Выбрать Тогда
			Продолжить;
		КонецЕсли;

		СтруктураПоиска = Новый Структура;
		СтруктураПоиска.Вставить("Реквизит", Стр.Реквизит);

		МассивСтрок = ТЗ.НайтиСтроки(СтруктураПоиска);
		Если МассивСтрок.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;

		ТекСтр = МассивСтрок[0];
		ЗаполнитьЗначенияСвойств(ТекСтр, Стр);
	КонецЦикла;

	ЗначениеВРеквизитФормы(ТЗ, "Реквизиты");
КонецПроцедуры

// Восстанавливает сохраненные значения реквизитов формы.
//
// Параметры:
//  Нет.
//
&НаКлиенте
Процедура ЗагрузитьНастройку() Экспорт

	Если Элементы.ТекущаяНастройка.СписокВыбора.Количество() = 0 Тогда
		УстановитьИмяНастройки("Новая настройка");
	Иначе
		Если Не ТекущаяНастройка.Прочее = Неопределено Тогда
			мНастройка = ТекущаяНастройка.Прочее;
		КонецЕсли;
	КонецЕсли;

	РеквизитыДляСохранения = Неопределено;

	Для Каждого РеквизитНастройки Из мНастройка Цикл
		//@skip-warning
		Значение = мНастройка[РеквизитНастройки.Ключ];
		Выполнить (Строка(РеквизитНастройки.Ключ) + " = Значение;");
	КонецЦикла;

	Если РеквизитыДляСохранения <> Неопределено И РеквизитыДляСохранения.Количество() Тогда
		ЗагрузитьРеквизитыИзМассива(РеквизитыДляСохранения);
	КонецЕсли;

КонецПроцедуры //вЗагрузитьНастройку()

// Устанавливает значение реквизита "ТекущаяНастройка" по имени настройки или произвольно.
//
// Параметры:
//  ИмяНастройки   - произвольное имя настройки, которое необходимо установить.
//
&НаКлиенте
Процедура УстановитьИмяНастройки(ИмяНастройки = "") Экспорт

	Если ПустаяСтрока(ИмяНастройки) Тогда
		Если ТекущаяНастройка = Неопределено Тогда
			ТекущаяНастройкаПредставление = "";
		Иначе
			ТекущаяНастройкаПредставление = ТекущаяНастройка.Обработка;
		КонецЕсли;
	Иначе
		ТекущаяНастройкаПредставление = ИмяНастройки;
	КонецЕсли;

КонецПроцедуры // вУстановитьИмяНастройки()

// Получает структуру для индикации прогресса цикла.
//
// Параметры:
//  КоличествоПроходов - Число - максимальное значение счетчика;
//  ПредставлениеПроцесса - Строка, "Выполнено" - отображаемое название процесса;
//  ВнутреннийСчетчик - Булево, *Истина - использовать внутренний счетчик с начальным значением 1,
//                    иначе нужно будет передавать значение счетчика при каждом вызове обновления индикатора;
//  КоличествоОбновлений - Число, *100 - всего количество обновлений индикатора;
//  ЛиВыводитьВремя - Булево, *Истина - выводить приблизительное время до окончания процесса;
//  РазрешитьПрерывание - Булево, *Истина - разрешает пользователю прерывать процесс.
//
// Возвращаемое значение:
//  Структура - которую потом нужно будет передавать в метод ЛксОбработатьИндикатор.
//
&НаКлиенте
Функция ПолучитьИндикаторПроцесса(КоличествоПроходов, ПредставлениеПроцесса = "Выполнено", ВнутреннийСчетчик = Истина,
	КоличествоОбновлений = 100, ЛиВыводитьВремя = Истина, РазрешитьПрерывание = Истина) Экспорт

	Индикатор = Новый Структура;
	Индикатор.Вставить("КоличествоПроходов", КоличествоПроходов);
	Индикатор.Вставить("ДатаНачалаПроцесса", ТекущаяДата());
	Индикатор.Вставить("ПредставлениеПроцесса", ПредставлениеПроцесса);
	Индикатор.Вставить("ЛиВыводитьВремя", ЛиВыводитьВремя);
	Индикатор.Вставить("РазрешитьПрерывание", РазрешитьПрерывание);
	Индикатор.Вставить("ВнутреннийСчетчик", ВнутреннийСчетчик);
	Индикатор.Вставить("Шаг", КоличествоПроходов / КоличествоОбновлений);
	Индикатор.Вставить("СледующийСчетчик", 0);
	Индикатор.Вставить("Счетчик", 0);
	Возврат Индикатор;

КонецФункции // ЛксПолучитьИндикаторПроцесса()

// Проверяет и обновляет индикатор. Нужно вызывать на каждом проходе индицируемого цикла.
//
// Параметры:
//  Индикатор   - Структура - индикатора, полученная методом ЛксПолучитьИндикаторПроцесса;
//  Счетчик     - Число - внешний счетчик цикла, используется при ВнутреннийСчетчик = Ложь.
//
&НаКлиенте
Процедура ОбработатьИндикатор(Индикатор, Счетчик = 0) Экспорт

	Если Индикатор.ВнутреннийСчетчик Тогда
		Индикатор.Счетчик = Индикатор.Счетчик + 1;
		Счетчик = Индикатор.Счетчик;
	КонецЕсли;
	Если Индикатор.РазрешитьПрерывание Тогда
		ОбработкаПрерыванияПользователя();
	КонецЕсли;

	Если Счетчик > Индикатор.СледующийСчетчик Тогда
		Индикатор.СледующийСчетчик = Цел(Счетчик + Индикатор.Шаг);
		Если Индикатор.ЛиВыводитьВремя Тогда
			ПрошлоВремени = ТекущаяДата() - Индикатор.ДатаНачалаПроцесса;
			Осталось = ПрошлоВремени * (Индикатор.КоличествоПроходов / Счетчик - 1);
			Часов = Цел(Осталось / 3600);
			Осталось = Осталось - (Часов * 3600);
			Минут = Цел(Осталось / 60);
			Секунд = Цел(Цел(Осталось - (Минут * 60)));
			ОсталосьВремени = Формат(Часов, "ЧЦ=2; ЧН=00; ЧВН=") + ":" + Формат(Минут, "ЧЦ=2; ЧН=00; ЧВН=") + ":"
				+ Формат(Секунд, "ЧЦ=2; ЧН=00; ЧВН=");
			ТекстОсталось = "Осталось: ~" + ОсталосьВремени;
		Иначе
			ТекстОсталось = "";
		КонецЕсли;

		Если Индикатор.КоличествоПроходов > 0 Тогда
			ТекстСостояния = ТекстОсталось;
		Иначе
			ТекстСостояния = "";
		КонецЕсли;

		Состояние(Индикатор.ПредставлениеПроцесса, Счетчик / Индикатор.КоличествоПроходов * 100, ТекстСостояния);
	КонецЕсли;

	Если Счетчик = Индикатор.КоличествоПроходов Тогда
		Состояние(Индикатор.ПредставлениеПроцесса, 100, ТекстСостояния);
	КонецЕсли;

КонецПроцедуры // ЛксОбработатьИндикатор()

// Позволяет создать описание типов на основании строкового представления типа.
//
// Параметры: 
//  ТипСтрокой     - Строковое представление типа.
//
// Возвращаемое значение:
//  Описание типов.
//
&НаСервере
Функция ОписаниеТипа(ТипСтрокой) Экспорт

	МассивТипов = Новый Массив;
	МассивТипов.Добавить(Тип(ТипСтрокой));
	ОписаниеТипов = Новый ОписаниеТипов(МассивТипов);

	Возврат ОписаниеТипов;

КонецФункции // вОписаниеТипа()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если мИспользоватьНастройки Тогда
		УстановитьИмяНастройки();
		ЗагрузитьНастройку();
	Иначе
		Элементы.ТекущаяНастройка.Доступность = Ложь;
		Элементы.СохранитьНастройки.Доступность = Ложь;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("Настройка") Тогда
		ТекущаяНастройка = Параметры.Настройка;
	КонецЕсли;
	Если Параметры.Свойство("НайденныеОбъектыТЧ") Тогда

		ТЗНО=Параметры.НайденныеОбъектыТЧ.Выгрузить();

		НайденныеОбъекты.Загрузить(ТЗНО);
	КонецЕсли;
	ТекущаяСтрока = -1;
	Если Параметры.Свойство("ТекущаяСтрока") Тогда
		Если Параметры.ТекущаяСтрока <> Неопределено Тогда
			ТекущаяСтрока = Параметры.ТекущаяСтрока;
		КонецЕсли;
	КонецЕсли;
	Если Параметры.Свойство("Родитель") Тогда
		Родитель = Параметры.Родитель;
	КонецЕсли;

	Элементы.ТекущаяНастройка.СписокВыбора.Очистить();
	Если Параметры.Свойство("Настройки") Тогда
		Для Каждого Строка Из Параметры.Настройки Цикл
			Элементы.ТекущаяНастройка.СписокВыбора.Добавить(Строка, Строка.Обработка);
		КонецЦикла;
	КонецЕсли;
	Если Параметры.Свойство("ОбрабатыватьТабличныеЧасти") Тогда
		ОбрабатыватьТабличныеЧасти=Параметры.ОбрабатыватьТабличныеЧасти;
	КонецЕсли;
	Если Параметры.Свойство("ТаблицаРеквизитов") Тогда
		ТАбРеквизитов=Параметры.ТаблицаРеквизитов;
		ТАбРеквизитов.Сортировать("ЭтоТЧ");
		Для Каждого Реквизит Из Параметры.ТаблицаРеквизитов Цикл
			НоваяСтрока = Реквизиты.Добавить();
			НоваяСтрока.Реквизит      = Реквизит.Имя;//?(ПустаяСтрока(Реквизит.Синоним), Реквизит.Имя, Реквизит.Синоним);
			НоваяСтрока.Идентификатор = Реквизит.Представление;
			НоваяСтрока.Тип           = Реквизит.Тип;
			НоваяСтрока.Значение      = НоваяСтрока.Тип.ПривестиЗначение();
			НоваяСтрока.РеквизитТЧ	  = Реквизит.ЭтоТЧ;
		КонецЦикла;

	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ, ВЫЗЫВАЕМЫЕ ИЗ ЭЛЕМЕНТОВ ФОРМЫ

&НаКлиенте
Процедура ВыполнитьОбработкуКоманда(Команда)
	ОбработаноОбъектов = ВыполнитьОбработку(УИ_ОбщегоНазначенияКлиентСервер.ПараметрыЗаписиФормы(
		ЭтотОбъект.ВладелецФормы));

	ПоказатьПредупреждение( , "Обработка <" + СокрЛП(ЭтаФорма.Заголовок) + "> завершена!
																		   |Обработано объектов: " + ОбработаноОбъектов
		+ ".");
КонецПроцедуры

&НаКлиенте
Процедура СохранитьНастройкиКоманда(Команда)
	СохранитьНастройку();
КонецПроцедуры

&НаКлиенте
Процедура ТекущаяНастройкаОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;

	Если Не ТекущаяНастройка = ВыбранноеЗначение Тогда

		Если ЭтаФорма.Модифицированность Тогда
			ПоказатьВопрос(Новый ОписаниеОповещения("ТекущаяНастройкаОбработкаВыбораЗавершение", ЭтаФорма,
				Новый Структура("ВыбранноеЗначение", ВыбранноеЗначение)), "Сохранить текущую настройку?",
				РежимДиалогаВопрос.ДаНет, , КодВозвратаДиалога.Да);
			Возврат;
		КонецЕсли;

		ТекущаяНастройкаОбработкаВыбораФрагмент(ВыбранноеЗначение);

	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТекущаяНастройкаОбработкаВыбораЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт

	ВыбранноеЗначение = ДополнительныеПараметры.ВыбранноеЗначение;
	Если РезультатВопроса = КодВозвратаДиалога.Да Тогда
		СохранитьНастройку();
	КонецЕсли;

	ТекущаяНастройкаОбработкаВыбораФрагмент(ВыбранноеЗначение);

КонецПроцедуры

&НаКлиенте
Процедура ТекущаяНастройкаОбработкаВыбораФрагмент(Знач ВыбранноеЗначение)

	ТекущаяНастройка = ВыбранноеЗначение;
	УстановитьИмяНастройки();

	ЗагрузитьНастройку();

КонецПроцедуры

&НаКлиенте
Процедура ТекущаяНастройкаПриИзменении(Элемент)
	ЭтаФорма.Модифицированность = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьВсе(Команда)
	ВыбратьЭлементы(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьВыбор(Команда)
	ВыбратьЭлементы(Ложь);
КонецПроцедуры

&НаСервере
Процедура ВыбратьЭлементы(Выбор)
	Для Каждого Стр Из Реквизиты Цикл
		Стр.Выбрать = Выбор;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыЗначениеОчистка(Элемент, СтандартнаяОбработка)
	Элементы.РеквизитыЗначение.ВыбиратьТип = Истина;
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыЗначениеПриИзменении(Элемент)
	Элементы.Реквизиты.ТекущиеДанные.Выбрать = Истина;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ИНИЦИАЛИЗАЦИЯ МОДУЛЬНЫХ ПЕРЕМЕННЫХ

мИспользоватьНастройки = Истина;

//Реквизиты настройки и значения по умолчанию.
мНастройка = Новый Структура("РеквизитыДляСохранения");

//мНастройка.<Имя реквизита> = <Значение реквизита>;

мТипыОбрабатываемыхОбъектов = "Справочник,Документ";