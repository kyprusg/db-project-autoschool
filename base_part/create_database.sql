CREATE DATABASE autoschool;

-- 1. КУРСАНТЫ
CREATE TABLE students (
    student_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    last_name    VARCHAR(50) NOT NULL,
    first_name   VARCHAR(50) NOT NULL,
    middle_name  VARCHAR(50),
    birth_date   DATE        NOT NULL,
    passport_num VARCHAR(10) NOT NULL UNIQUE,
    phone        VARCHAR(20) NOT NULL
);

-- 2. ПРОГРАММЫ И ТАРИФЫ
CREATE TABLE training_programs (
    program_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    program_name   VARCHAR(100)   NOT NULL UNIQUE,
    category       VARCHAR(5)     NOT NULL,
    transmission   VARCHAR(10)    NOT NULL CHECK (transmission IN ('МКПП', 'АКПП')),
    theory_hours   INT            NOT NULL CHECK (theory_hours > 0),
    practice_hours INT            NOT NULL CHECK (practice_hours > 0),
    base_price     NUMERIC(10, 2) NOT NULL CHECK (base_price > 0)
);

-- 3. ИНСТРУКТОРЫ И ПРЕПОДАВАТЕЛИ
CREATE TABLE instructors (
    instructor_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    last_name     VARCHAR(50) NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    middle_name   VARCHAR(50),
    role_type     VARCHAR(30) NOT NULL CHECK (role_type IN ('теория', 'практика', 'универсал')),
    license_num   VARCHAR(20) NOT NULL UNIQUE
);

-- 4. ЛОКАЦИИ И МАРШРУТЫ
CREATE TABLE training_routes (
    route_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    route_name    VARCHAR(100)  NOT NULL UNIQUE,
    location_type VARCHAR(30)   NOT NULL CHECK (location_type IN ('закрытый автодром', 'городской маршрут')),
    start_address VARCHAR(150)  NOT NULL,
    length_km     NUMERIC(5, 2) NOT NULL CHECK (length_km > 0)
);

-- 5. УЧЕБНЫЕ ГРУППЫ
CREATE TABLE study_groups (
    group_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    program_id    INT         NOT NULL REFERENCES training_programs (program_id) ON DELETE RESTRICT,
    instructor_id INT         NOT NULL REFERENCES instructors (instructor_id) ON DELETE RESTRICT,
    group_code    VARCHAR(20) NOT NULL UNIQUE,
    start_date    DATE        NOT NULL,
    end_date      DATE        NOT NULL,
    schedule_type VARCHAR(30) NOT NULL,
    CHECK (end_date >= start_date)
);

-- 6. МЕДИЦИНСКИЕ СПРАВКИ
CREATE TABLE medical_certificates (
    cert_id            INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id         INT          NOT NULL REFERENCES students (student_id) ON DELETE CASCADE,
    cert_number        VARCHAR(20)  NOT NULL UNIQUE,
    clinic_name        VARCHAR(150) NOT NULL,
    issue_date         DATE         NOT NULL,
    valid_until        DATE         NOT NULL,
    allowed_categories VARCHAR(20)  NOT NULL,
    CHECK (valid_until > issue_date)
);

-- 7. УЧЕБНЫЕ АВТОМОБИЛИ
CREATE TABLE vehicles (
    vehicle_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    instructor_id INT         REFERENCES instructors (instructor_id) ON DELETE SET NULL,
    plate_number  VARCHAR(15) NOT NULL UNIQUE,
    brand_model   VARCHAR(80) NOT NULL,
    transmission  VARCHAR(10) NOT NULL CHECK (transmission IN ('МКПП', 'АКПП')),
    prod_year     INT         NOT NULL CHECK (prod_year >= 1990),
    is_active     BOOLEAN     NOT NULL DEFAULT TRUE
);

-- 8. ДОГОВОРЫ
CREATE TABLE contracts (
    contract_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id   INT            NOT NULL REFERENCES students (student_id) ON DELETE RESTRICT,
    program_id   INT            NOT NULL REFERENCES training_programs (program_id) ON DELETE RESTRICT,
    group_id     INT            NOT NULL REFERENCES study_groups (group_id) ON DELETE RESTRICT,
    contract_num VARCHAR(30)    NOT NULL UNIQUE,
    sign_date    DATE           NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    status       VARCHAR(20)    NOT NULL DEFAULT 'активен' CHECK (status IN ('активен', 'завершён', 'расторгнут'))
);

-- 9. ТЕХОБСЛУЖИВАНИЕ И РЕМОНТ
CREATE TABLE vehicle_maintenance (
    maint_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vehicle_id   INT            NOT NULL REFERENCES vehicles (vehicle_id) ON DELETE CASCADE,
    service_date DATE           NOT NULL,
    work_type    VARCHAR(100)   NOT NULL,
    mileage_km   INT            NOT NULL CHECK (mileage_km >= 0),
    cost         NUMERIC(10, 2) NOT NULL CHECK (cost >= 0)
);

-- 10. ПЛАТЕЖИ
CREATE TABLE payments (
    payment_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    contract_id    INT            NOT NULL REFERENCES contracts (contract_id) ON DELETE RESTRICT,
    payment_date   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount         NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(20)    NOT NULL CHECK (payment_method IN ('карта', 'СБП', 'наличные')),
    receipt_num    VARCHAR(40)    NOT NULL UNIQUE
);

-- 11. ПРАКТИЧЕСКИЕ ЗАНЯТИЯ
CREATE TABLE driving_lessons (
    lesson_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    contract_id     INT         NOT NULL REFERENCES contracts (contract_id) ON DELETE RESTRICT,
    instructor_id   INT         NOT NULL REFERENCES instructors (instructor_id) ON DELETE RESTRICT,
    vehicle_id      INT         NOT NULL REFERENCES vehicles (vehicle_id) ON DELETE RESTRICT,
    route_id        INT         NOT NULL REFERENCES training_routes (route_id) ON DELETE RESTRICT,
    lesson_datetime TIMESTAMP   NOT NULL,
    duration_min    INT         NOT NULL CHECK (duration_min > 0),
    status          VARCHAR(20) NOT NULL DEFAULT 'назначено' CHECK (status IN ('назначено', 'проведено', 'отменено'))
);

-- 12. ЭКЗАМЕНЫ И ПОПЫТКИ СДАЧИ
CREATE TABLE exam_attempts (
    attempt_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    contract_id    INT         NOT NULL REFERENCES contracts (contract_id) ON DELETE RESTRICT,
    route_id       INT         NOT NULL REFERENCES training_routes (route_id) ON DELETE RESTRICT,
    exam_stage     VARCHAR(30) NOT NULL CHECK (exam_stage IN ('внутренний', 'теория ГИБДД', 'автодром', 'город')),
    exam_date      DATE        NOT NULL,
    attempt_num    INT         NOT NULL CHECK (attempt_num >= 1),
    penalty_points INT         NOT NULL DEFAULT 0 CHECK (penalty_points >= 0),
    is_passed      BOOLEAN     NOT NULL
);