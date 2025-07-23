# Pro-Gen-Marshallog-Zap

Библиотека для автоматического логирования и маршалинга protobuf сообщений с использованием Zap logger. Предоставляет расширенные возможности для контроля логирования, маскирования чувствительных данных и соответствия стандартам безопасности.

## 🚀 Возможности

- **Автоматическое логирование** protobuf сообщений
- **Маскирование чувствительных данных** с различными стратегиями
- **Контроль уровней логирования** на уровне полей
- **Соответствие стандартам** (GDPR, HIPAA, PCI)
- **Структурированное логирование** в JSON формате
- **Аудит-логирование** для критических операций
- **Производительность** с ленивым вычислением и ограничениями

## 📦 Установка

```bash
go get github.com/daneeqx/pro-gen-marshallog-zap
```

## 🔧 Генерация кода

```bash
make gen
```

## 📚 Документация

### 1. Стратегии маскирования (MaskStrategy)

Определяют **КАК** маскировать чувствительные данные:

```protobuf
enum MaskStrategy {
  MASK_NONE = 0;        // Не маскировать
  MASK_FULL = 1;        // "John" → "***"
  MASK_PARTIAL = 2;     // "John Smith" → "Jo** Sm***"
  MASK_HASH = 3;        // "password123" → "sha256:abc123..."
  MASK_REDACTED = 4;    // "secret" → "[REDACTED]"
  MASK_EMAIL = 5;       // "user@example.com" → "u***@ex***le.com"
  MASK_PHONE = 6;       // "+1-555-123-4567" → "+1-***-***-4567"
  MASK_CREDIT_CARD = 7; // "4111111111111111" → "**** **** **** 1111"
}
```

**Примеры использования:**
```protobuf
message User {
  string name = 1 [(mask_strategy) = MASK_PARTIAL];           // "John Smith" → "Jo** Sm***"
  string email = 2 [(mask_strategy) = MASK_EMAIL];            // "user@example.com" → "u***@ex***le.com"
  string phone = 3 [(mask_strategy) = MASK_PHONE];            // "+1-555-123-4567" → "+1-***-***-4567"
  string credit_card = 4 [(mask_strategy) = MASK_CREDIT_CARD]; // "4111111111111111" → "**** **** **** 1111"
  string password = 5 [(mask_strategy) = MASK_HASH];          // "password123" → "sha256:abc123..."
}
```

### 2. Уровни логирования (LogLevel)

Определяют **ВАЖНОСТЬ** сообщения:

```protobuf
enum LogLevel {
  LOG_TRACE = 0;   // Самый детальный: "Entering function X"
  LOG_DEBUG = 1;   // Отладка: "Processing user request"
  LOG_INFO = 2;    // Информация: "User created"
  LOG_WARN = 3;    // Предупреждения: "Slow database query"
  LOG_ERROR = 4;   // Ошибки: "Database connection failed"
  LOG_FATAL = 5;   // Критические: "Cannot start server"
}
```

**Примеры:**
```protobuf
message Payment {
  string amount = 1 [(min_log_level) = LOG_INFO];     // Логировать только INFO+
  string card_number = 2 [(min_log_level) = LOG_ERROR]; // Логировать только при ошибках
  string user_id = 3 [(min_log_level) = LOG_DEBUG];   // Логировать только в DEBUG
}
```

### 3. Опции для полей (FieldOptions)

#### Базовые опции маскирования:
```protobuf
string password = 1 [(mask) = true];                           // Простое маскирование
string email = 2 [(mask_strategy) = MASK_EMAIL];               // Специальная стратегия
string secret = 3 [(custom_mask_pattern) = "[СКРЫТО]"];       // Свой шаблон
```

#### Контроль логирования:
```protobuf
string order_id = 1 [(log_field_name) = "orderNumber"];        // Свое имя в логах
string user_id = 2 [(min_log_level) = LOG_INFO];               // Минимальный уровень
string internal_note = 3 [(hide_log) = true];                  // Не логировать
```

#### Форматирование:
```protobuf
string name = 1 [(format_template) = "User: {name}"];          // Шаблон форматирования
string price = 2 [(omit_empty) = true];                        // Пропускать пустые
repeated string tags = 3 [(flatten) = true];                   // Разворачивать массивы
```

#### Производительность:
```protobuf
string content = 1 [(max_length) = 100];                       // Обрезать длинные строки
string large_text = 2 [(lazy_eval) = true];                    // Ленивое вычисление
```

#### Безопасность:
```protobuf
string full_name = 1 [(pii_data) = true];                      // Персональные данные
string api_key = 2 [(sensitive) = true];                       // Чувствительные данные
string ssn = 3 [(compliance_tags) = "GDPR", (compliance_tags) = "HIPAA"]; // Соответствие
```

### 4. Опции для сообщений (MessageOptions)

```protobuf
message UserProfile {
  option (enable_audit_log) = true;                              // Аудит-логирование
  option (log_prefix) = "[USER-SERVICE]";                        // Префикс логов
  option (include_metadata) = true;                              // Метаданные (время, ID)
  option (default_log_level) = LOG_INFO;                         // Уровень по умолчанию
  option (enable_structured_logging) = true;                     // JSON-логирование
  option (correlation_id_field) = "request_id";                  // Поле для связывания
  
  string request_id = 1;
  string user_id = 2;
  string name = 3;
}
```

**Результат в логах:**
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "prefix": "[USER-SERVICE]",
  "correlation_id": "req-12345",
  "message": "UserProfile processed",
  "data": {
    "user_id": "user-123",
    "name": "John Doe"
  }
}
```

### 5. Опции для сервисов (ServiceOptions)

```protobuf
service PaymentService {
  option (enable_request_logging) = true;                        // Логировать запросы
  option (enable_response_logging) = true;                       // Логировать ответы
  option (enable_error_logging) = true;                          // Логировать ошибки
  option (slow_request_threshold_ms) = 1000;                     // Порог медленных запросов
  
  rpc ProcessPayment(PaymentRequest) returns (PaymentResponse);
}
```

**Результат:**
```
[INFO] Request received: ProcessPayment
[INFO] Response sent: ProcessPayment (200ms)
[WARN] Slow request: ProcessPayment (1500ms)
[ERROR] Payment failed: invalid card number
```

### 6. Опции для методов (MethodOptions)

```protobuf
service UserService {
  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {
    option (log_request_body) = true;                            // Логировать тело запроса
    option (log_response_body) = true;                           // Логировать тело ответа
    option (exclude_fields) = "password";                        // Исключить поле
    option (exclude_fields) = "secret_key";                      // Исключить поле
  };
  
  rpc GetUser(GetUserRequest) returns (GetUserResponse) {
    option (skip_logging) = true;                                // Не логировать
  };
  
  rpc UpdateUser(UpdateUserRequest) returns (UpdateUserResponse) {
    option (override_log_level) = LOG_DEBUG;                     // Переопределить уровень
  };
}
```

## 💡 Примеры использования

### Пример 1: Сервис пользователей

```protobuf
service UserService {
  option (enable_request_logging) = true;
  option (slow_request_threshold_ms) = 1000;

  rpc CreateUser(CreateUserRequest) returns (CreateUserResponse) {
    option (log_request_body) = true;
    option (exclude_fields) = "password";
  };
}

message CreateUserRequest {
  option (enable_audit_log) = true;
  option (log_prefix) = "[USER-CREATE]";
  
  string username = 1 [(log_field_name) = "userName"];
  string email = 2 [(mask_strategy) = MASK_EMAIL];
  string password = 3 [(hide_log) = true, (sensitive) = true];
  string phone = 4 [(mask_strategy) = MASK_PHONE, (pii_data) = true];
  string full_name = 5 [(pii_data) = true, (compliance_tags) = "GDPR"];
}
```

### Пример 2: Платежный сервис

```protobuf
service PaymentService {
  option (enable_request_logging) = true;
  option (slow_request_threshold_ms) = 2000;

  rpc ProcessPayment(PaymentRequest) returns (PaymentResponse) {
    option (exclude_fields) = "card_pin";
    option (exclude_fields) = "cvv";
  };
}

message PaymentRequest {
  option (enable_audit_log) = true;
  option (log_prefix) = "[PAYMENT-PROCESS]";
  
  string card_number = 1 [(mask_strategy) = MASK_CREDIT_CARD];
  string card_holder = 2 [(pii_data) = true, (compliance_tags) = "PCI"];
  string cvv = 3 [(hide_log) = true, (sensitive) = true];
  double amount = 4 [(min_log_level) = LOG_INFO];
  string customer_email = 5 [(mask_strategy) = MASK_EMAIL];
}
```

### Пример 3: Health Check сервис

```protobuf
service HealthService {
  option (enable_request_logging) = false;  // Не логируем health checks
  option (enable_error_logging) = true;     // Но логируем ошибки

  rpc CheckHealth(HealthRequest) returns (HealthResponse) {
    option (skip_logging) = true;  // Полностью отключаем
  };
}
```

## 🔒 Безопасность и соответствие

### GDPR (General Data Protection Regulation)
```protobuf
string full_name = 1 [(pii_data) = true, (compliance_tags) = "GDPR"];
string email = 2 [(pii_data) = true, (compliance_tags) = "GDPR"];
string phone = 3 [(pii_data) = true, (compliance_tags) = "GDPR"];
```

### HIPAA (Health Insurance Portability and Accountability Act)
```protobuf
string patient_id = 1 [(pii_data) = true, (compliance_tags) = "HIPAA"];
string diagnosis = 2 [(sensitive) = true, (compliance_tags) = "HIPAA"];
string ssn = 3 [(pii_data) = true, (compliance_tags) = "HIPAA"];
```

### PCI DSS (Payment Card Industry Data Security Standard)
```protobuf
string card_number = 1 [(mask_strategy) = MASK_CREDIT_CARD, (compliance_tags) = "PCI"];
string cvv = 2 [(hide_log) = true, (sensitive) = true, (compliance_tags) = "PCI"];
string card_pin = 3 [(hide_log) = true, (sensitive) = true, (compliance_tags) = "PCI"];
```

## ⚡ Производительность

### Ленивое вычисление
```protobuf
string expensive_field = 1 [(lazy_eval) = true];  // Вычислять только при необходимости
```

### Ограничения размера
```protobuf
string long_text = 1 [(max_length) = 100];        // Обрезать до 100 символов
repeated string tags = 2 [(max_length) = 5];       // Максимум 5 тегов
map<string, string> metadata = 3 [(max_length) = 10]; // Максимум 10 ключей
```

### Пропуск пустых значений
```protobuf
string optional_field = 1 [(omit_empty) = true];   // Не логировать если пустое
```

## 🛠️ Разработка

### Генерация кода
```bash
make gen        # Генерировать protobuf код
make lint       # Проверить proto файлы
make fmt        # Форматировать proto файлы
```

### Структура проекта
```
.
├── api/
│   └── marshal-zap.proto      # Основные определения
├── examples/
│   ├── user-service.proto     # Пример сервиса пользователей
│   ├── payment-service.proto  # Пример платежного сервиса
│   └── health-check.proto     # Пример health check
├── gen/                       # Сгенерированный Go код
├── scripts/
│   ├── gen-grpc.sh           # Скрипт генерации
│   └── buf.sh                # Обертка для buf
└── Makefile
```

## 📝 Логирование

### Структурированные логи
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "prefix": "[USER-SERVICE]",
  "correlation_id": "req-12345",
  "message": "User created successfully",
  "data": {
    "user_id": "user-123",
    "email": "u***@ex***le.com",
    "phone": "+1-***-***-4567"
  },
  "metadata": {
    "request_id": "req-12345",
    "duration_ms": 150,
    "ip_address": "192.***.1.***"
  }
}
```

### Аудит-логи
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "audit": true,
  "action": "USER_CREATE",
  "user_id": "admin-123",
  "target_user_id": "user-456",
  "changes": {
    "email": "u***@ex***le.com",
    "phone": "+1-***-***-4567"
  },
  "compliance": ["GDPR"]
}
```

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте feature branch (`git checkout -b feature/amazing-feature`)
3. Commit изменения (`git commit -m 'Add amazing feature'`)
4. Push в branch (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 🆘 Поддержка

Если у вас есть вопросы или проблемы:

1. Проверьте [Issues](https://github.com/daneeqx/pro-gen-marshallog-zap/issues)
2. Создайте новое Issue с подробным описанием проблемы
3. Приложите примеры proto файлов и логов

## 🔄 Версии

- **v1.0.0** - Базовая функциональность маскирования и логирования
- **v1.1.0** - Добавлены стратегии маскирования и уровни логирования
- **v1.2.0** - Добавлена поддержка соответствия стандартам (GDPR, HIPAA, PCI)
- **v1.3.0** - Добавлены опции производительности и структурированное логирование 