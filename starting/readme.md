# TimeSeriesGenerator Исполняемый файл

## 1. Требования для развертывания

Убедитесь, что MATLAB Runtime (R2024a) установлен.  
Если нет, вы можете запустить установщик MATLAB Runtime.  
Чтобы найти его местоположение, введите:

```
>>mcrinstaller
```

в командной строке MATLAB.  
**Примечание:** Для запуска установщика MATLAB Runtime вам потребуются права администратора.

В качестве альтернативы, загрузите и установите версию MATLAB Runtime для Windows (R2024a)  
по следующей ссылке на сайте MathWorks:

[MATLAB Runtime](https://www.mathworks.com/products/compiler/mcr/index.html)

Для получения дополнительной информации о MATLAB Runtime и установщике MATLAB Runtime  
см. раздел **"Distribute Applications"** в документации MATLAB Compiler  
на сайте MathWorks.

---

## 2. Файлы для развертывания и упаковки

Файлы для упаковки автономного приложения:
================================
- **TimeSeriesGenerator.exe**  
- **MCRInstaller.exe**  
  *Примечание: если конечные пользователи не могут загрузить MATLAB Runtime  
  по инструкциям из предыдущего раздела, включите его в пакет при сборке  
  компонента, выбрав опцию "Runtime included in package" в инструменте  
  развертывания.*
- Данный файл README

---

## 3. Определения

Для получения информации о терминологии развертывания  
перейдите на [MathWorks Help](https://www.mathworks.com/help)  
и выберите **MATLAB Compiler > Getting Started > About Application Deployment > Deployment Product Terms**  
в Центре документации MathWorks.