# Базовый образ для сборки
FROM dart:stable AS build

# Установка рабочей директории
WORKDIR /app

# Копируем pubspec.yaml и pubspec.lock
COPY pubspec.* ./

# Устанавливаем зависимости
RUN dart pub get

# Копируем весь проект
COPY . .

# Создаем директорию bin
RUN mkdir -p bin

# Компилируем сервер в исполняемый файл
RUN dart compile exe lib/server.dart -o bin/server

# Финальный образ
FROM dart:stable AS final 
 # Используем dart:stable для финальной стадии
COPY --from=build /app/bin/server /server
CMD ["/server"]
