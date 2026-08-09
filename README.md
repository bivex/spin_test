# SPIN & Promela Model Checker Test Suite

Этот репозиторий содержит коллекцию моделей на языке **Promela** для модел-чекера **SPIN** (Simple Promela INterpreter), демонстрирующую принцип работы SPIN с компиляцией в C-код, а также архитектуру ИТ-услуг.

---

## 🚀 Архитектура работы SPIN

SPIN работает по схеме трансляции спецификаций систем в высокопроизводительный машинный код:

```text
Promela-модель (.pml)
      ↓
   SPIN Compiler (spin -a)
      ↓
C-код верификатора (pan.c & pan.h)
      ↓
GCC / Clang (gcc -O2 -DSAFETY)
      ↓
Исполняемый верификатор (./pan)
```

---

## 📂 Модели и документы в репозитории

### 📊 Бизнес-план и архитектура ИТ-услуг:
* [`it_services_business_plan.md`](./it_services_business_plan.md) — Бизнес-схема ИТ-услуг с высокой маржинальностью (65–85%), юнит-экономикой и воронкой продаж.

### Системные и сетевые алгоритмы:
| Файл | Описание | Тип проверки |
|---|---|---|
| [`mutex_peterson.pml`](./mutex_peterson.pml) | Алгоритм взаимного исключения Питерсона | Mutual Exclusion, LTL |
| [`dining_philosophers.pml`](./dining_philosophers.pml) | Задача об обедающих философах (несимметричные вилки) | Deadlock-free, Starvation-free |
| [`dekker_mutex.pml`](./dekker_mutex.pml) | Алгоритм Деккера для 2 процессов | Safety Assertion, LTL |
| [`alternating_bit_protocol.pml`](./alternating_bit_protocol.pml) | Протокол передачи с чередованием бит (ABP) | Progress, Reliable delivery |
| [`mutex_buggy.pml`](./mutex_buggy.pml) | Тестовая модель с ошибкой (Race condition / Deadlock) | Assertion Failure, `.trail` trace |

### Экономические и финансовые модели:
| Файл | Описание | Инвариант / LTL |
|---|---|---|
| [`bank_transfer.pml`](./bank_transfer.pml) | Параллельные денежные переводы между банковскими счетами | Закон сохранения денег (`sum == INITIAL_TOTAL`) |
| [`auction_system.pml`](./auction_system.pml) | Аукцион с закрытыми/открытыми ставками и возвратом средств | Корректность расчетов и передачи товара победителю |

---

## 🛠 Запуск и проверка

```bash
make all                 # Верификация всех моделей
make verify-bank         # Банковские переводы
make verify-auction      # Аукцион
make trace-buggy         # Воспроизведение ошибки по трассе (.trail)
```

---

## 📌 Требования
* **SPIN**: `spin` >= 6.5.0 (`brew install spin`)
* **C-компилятор**: `gcc` или `clang`
* **Make**: `make`
