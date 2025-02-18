﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Попытка
		Значение = ЗначениеИзСтрокиВнутр(Параметры.ЗначениеВнутр);
	Исключение
		Сообщить(КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		Отказ = Истина;
		Возврат;
	КонецПопытки;

	Если ТипЗнч(Значение) = Тип("Граница") Тогда
		_ТипЗначения = "Граница";
		_ГраницаЗначение = Значение.Значение;
		_ГраницаВидГраницы = Значение.ВидГраницы;

		Элементы.ГруппаМоментВремени.Видимость = Ложь;

	ИначеЕсли ТипЗнч(Значение) = Тип("МоментВремени") Тогда
		_ТипЗначения = "МоментВремени";
		_МоментВремениДата = Значение.Дата;
		_МоментВремениСсылка = Значение.Ссылка;

		Элементы.ГруппаГраница.Видимость = Ложь;

	Иначе
		Отказ = Истина;
		Возврат;
	КонецЕсли;

	Если Не ПустаяСтрока(Параметры.Заголовок) Тогда
		ЭтаФорма.Заголовок = Параметры.Заголовок;
	КонецЕсли;
КонецПроцедуры
&НаКлиенте
Процедура КомандаОК(Команда)
	Результат = Новый Структура;
	Результат.Вставить("ТипЗначения", _ТипЗначения);

	Если _ТипЗначения = "Граница" Тогда
		пСтрук = вСформироватьСпецЗначение(_ТипЗначения, _ГраницаЗначение, _ГраницаВидГраницы);
	ИначеЕсли _ТипЗначения = "МоментВремени" Тогда
		пСтрук = вСформироватьСпецЗначение(_ТипЗначения, _МоментВремениДата, _МоментВремениСсылка);
	Иначе
		Возврат;
	КонецЕсли;

	Если пСтрук.Отказ Тогда
		Возврат;
	КонецЕсли;

	Результат.Вставить("СтрокаВнутр", пСтрук.Значение);
	Результат.Вставить("Представление", пСтрук.Представление);

	Закрыть(Результат);
КонецПроцедуры

&НаСервереБезКонтекста
Функция вСформироватьСпецЗначение(Знач пТип, Знач пЗначение1, Знач пЗначение2)
	пСтрук = Новый Структура("Отказ, Значение, Представление", Ложь);

	Попытка
		Если пТип = "Граница" Тогда
			Если пЗначение2 = "Исключая" Тогда
				пЗначение2 = ВидГраницы.Исключая;
			Иначе
				пЗначение2 = ВидГраницы.Включая;
			КонецЕсли;

			пСтрук.Значение = Новый Граница(пЗначение1, пЗначение2);
			пСтрук.Представление = Строка(пСтрук.Значение.Значение) + ";" + Строка(пСтрук.Значение.ВидГраницы);

		ИначеЕсли пТип = "МоментВремени" Тогда
			пСтрук.Значение = Новый МоментВремени(пЗначение1, пЗначение2);
			пСтрук.Представление = Строка(пСтрук.Значение);

		Иначе
			пСтрук.Отказ = Истина;
			Сообщить("Неизвестный тип данных!");
		КонецЕсли;

	Исключение
		пСтрук.Отказ = Истина;
		Сообщить(КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;

	Если Не пСтрук.Отказ Тогда
		пСтрук.Значение = ЗначениеВСтрокуВнутр(пСтрук.Значение);
	КонецЕсли;

	Возврат пСтрук;
КонецФункции
&НаКлиенте
Процедура КомандаЗакрыть(Команда)
	Закрыть();
КонецПроцедуры