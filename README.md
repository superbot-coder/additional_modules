﻿# Additional Modules
Дополнительные модули к моим проектам, если в репозитории проекта нехватает модуля для компиляции, то его стоит поискать здесь. 
Данный репозиторий является как общая библиотека с модулями. 

## Краткое описание:
- **AntiReversing.pas** - Модуль, для борьбы против отладчиков, детектирование отладчиков и виртуальных машин, модуль содержит около 8 различных методов, на выбор и разные ситуации. Был найден на просторах интернета и немного переделан для удобства.
- **AntiReversMod.pas** - То же самое, что и AntiReversing.pas только более сильнее передалан.
- **BrutsPwd.pas** - Математический модуль для расчета брутфорса паролей. Зависимость: UMathServices.pas
- **Compress.pas** - Модуль для извлечения и распаковки сжатых ресурсов типа RT_RCDATA внутри программы  
- **CopyDateTime.pas** - Модуль для копирования свойства файла DateTime из одного в другой
- **CryptPWD.pas** - Модуль для надежного шифрования пароля, используя в качестве ключа шифрования аппаратные характеристики компьютера такие как серийный номер жесткого диска и другие такие как имя пользователя и имя компьютера. Зависимости: библиотека модулей DCPCrypt2 XE  
- **DigitalStyle.pas** - Модуль для форматированного вывода чисел типа как, например, 1 = 01 или 001, 23 = 0023; 100000 = 100 000 или 100.000, 25450 = 25 450 или 25.450 
- **Error.pas** - Модуль который позволяет обрабатывать исключительные ситуации в "тихом" режиме без вызова всплывающего сообщения об ошибке.
**Пример:** 
```
 for i:=0 to ListView1.Items.Count -1 do
 begin
     try
       //... какой-то код ... 
       // , например, пытаетесь открыть файл из списка 
       // на открытие которого  у вас нет прав.
     except
       StrValue := SystemErrorMessage(GetLastError) 
       // Функция выведет интерпретированную ошибку (код ошибки 5). 
       // "Отказано в доступе" в строковую переменную, 
       // которую можно залогировать 
       // тем самым не прерывая цикл выполнения. 
     end;   
 end;
 ``` 
  
- **ExportToExel.pas** - Модуль для экспорта из DBGrid в Exel файл.
- **Files.pas** - Модуль тоже что и модуль FormatFileSizeMod.pas с какими то незначительными изменениями 
- **Fletcher.pas** - Модуль определения контрольной суммы Флетчера 
- **GUID.pas** - Модуль для получения Globally Unique Identifier (GUID)
- **GetVer.pas** - Модуль получения версии программы  
- **JPEGResizer.pas** - Моуль изменения картинки в формате JPG с соблюдением пропорций и без. Пример: https://github.com/superbot-coder/JPEGResizer 
- **Luhn.pas** - Алгоритм Лу́на (англ. Luhn algorithm) — алгоритм вычисления контрольной цифры номера пластиковой карты в соответствии со стандартом ISO/IEC 7812. Не является криптографическим средством, а предназначен в первую очередь для выявления ошибок, вызванных непреднамеренным искажением данных (например, при ручном вводе номера карты, при приёме данных о номере социального страхования по телефону). Позволяет лишь с некоторой степенью достоверности судить об отсутствии ошибок в блоке цифр, но не даёт возможности нахождения и исправления обнаруженной неточности.
- **MD5.pas** - Простой модуль для получения MD5 хеша, без зависимости кучи других модулей
- **MiniReg.pas** - Для работы с реестром windows без использования классов, что позволяет сделать очень компактный *.exe, был найден на просторах интернета. Совместимость: D6, D7, D2007 на старших версиях не проверял.
- **FormatFileSizeMod.pas** - Модуль для получения форматированного размера файла, например, размер файла = 12,6 MB вместо размера в байтах.
- **OS.pas** = Модуль позволяющий выводить версию операционной системы не в цифрах, а глобально, например: WinNT, Win2K, WinXP, Win95, Win98, Win98SE, WinME, Vista, Win7.
Модуль не тестировался на Win8, Win8.1, Win10 и не поддерживает эти версии и требует адаптации. 
- **Resources.pas** - Модуль для чтения, записи, удаления, замены внутренних ресурсов программы т.е. "*.exe" файла как для выполняемой программы так и незапущеной программы.   
- **SID.pas** - Модуль для получения SID - идентификатор безопасности, используемый в Windows на основе технологии NT. 
- **SelectDirMod.pas** - Модуль для вызова диалога WinApi выбора директории, 
- **TimeFormat.pas** - Модуль для отображения форматированого времени из миллесекунд в часы, минуты, секунды, например: 1d 10h 25m 30s или 01:10:25:30
- **UMathServices.pas** - Математический модуль для чисел большой длины, которые выходят за все известные типы, например, int64, Extended. Максимальное десатичное число может достигать до 32 регистров. 
- **cpu_info_xe.pas** - Модуль, который проверяет подерживает ли процессор определеные инструкции, например: SSE, SSE2, SSE4 или AVX, AVX2. Используется технология получения информации о процессоре черех функцию процессора CPUID. Данный модуль поддерживает вывод только самых основных расширеных инструкций процессора. В принципе модуль позволяет дописать проверку и других инструкций.  
- **scrb_xe.pas** - Простейший модуль для шифрования строк и коротких файлов, методом спутывания битов в байтах между собой. Адаптирован для версий Delphi XE2 и выше т.е там где в string двухбайтовые символы char. 
- **ProcessMod.pas** - Модуль для работы с процессами, такие возможности как найти процесс, завершить процесс, получить PID процесса и т.д.
- **EnumerateResource.pas** - модуль для получения списка ресурсов внешнего модуля (*.exe), (*.dll) в формате JSON