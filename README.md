# SPIN & Promela Model Checker Test Suite

Этот репозиторий содержит коллекцию моделей на языке **Promela** для модел-чекера **SPIN** (Simple Promela INterpreter), демонстрирующую принцип работы SPIN с компиляцией в C-код.

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

1. **Promela-модель** описывает параллельные процессы, каналы связи и свойства безопасности/живучести (LTL).
2. **SPIN** транслирует Promela-код в заголовочный и исходный C-код (`pan.c`, `pan.h`).
3. **C-компилятор (GCC/Clang)** собирает `pan.c` в оптимизированный бинарник `./pan`.
4. **Верификатор `./pan`** выполняет полный поиск по пространству состояний (DFS/BFS) на высокой скорости.

---

## 📂 Модели в репозитории

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

### 1. Выполнение полной цепочки верификации
```bash
make all
```

### 2. Верификация экономических моделей
```bash
make verify-bank      # Банковские переводы (сохранение баланса)
make verify-auction   # Торги на аукционе
```

### 3. Верификация алгоритмов конкурентности
```bash
make verify-peterson       # Алгоритм Питерсона
make verify-philosophers   # Обедающие философы
make verify-dekker         # Алгоритм Деккера
make verify-abp            # Протокол ABP
```

### 4. Запуск пошаговой трассировки ошибки (Counterexample Trace)
Для модели с ошибочным состоянием (`mutex_buggy.pml`):
```bash
make trace-buggy
```

---

## 📌 Требования
* **SPIN**: `spin` >= 6.5.0 (`brew install spin`)
* **C-компилятор**: `gcc` или `clang`
* **Make**: `make`
