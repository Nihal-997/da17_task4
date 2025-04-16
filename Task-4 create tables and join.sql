CREATE TABLE patients (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INT CHECK (age > 0),
    contact TEXT
);

select * from patients


DO $$ 
DECLARE 
    i INT;
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO patients (name, age, contact) 
        VALUES ('Patient ' || i, FLOOR(RANDOM() * 80 + 20), '987654' || i);
    END LOOP;
END $$;

select * from patients

select * FROM patients
WHERE age > 30;

CREATE TABLE doctors (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    specialization TEXT NOT NULL
);

select * from doctors

DO $$ 
DECLARE 
    i INT;
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO doctors (name, specialization) 
        VALUES ('Dr. ' || i, 
        CASE WHEN i % 5 = 0 THEN 'Cardiology'
             WHEN i % 5 = 1 THEN 'Dermatology'
             WHEN i % 5 = 2 THEN 'Orthopedics'
             WHEN i % 5 = 3 THEN 'Neurology'
             ELSE 'Pediatrics' END);
    END LOOP;
END $$;

select * from doctors

SELECT * FROM doctors
WHERE specialization = 'Cardiology';

CREATE TABLE appointments (
    id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(id),
    doctor_id INT REFERENCES doctors(id),
    appointment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select * from appointments

DO $$ 
DECLARE 
    i INT;
    patient_id INT;
    doctor_id INT;
BEGIN
    FOR i IN 1..500 LOOP
        patient_id := FLOOR(RANDOM() * 500 + 1); -- Assuming 500 patients exist
        doctor_id := FLOOR(RANDOM() * 100 + 1); -- Assuming 100 doctors exist
        
        INSERT INTO appointments (patient_id, doctor_id, appointment_date) 
        VALUES (patient_id, doctor_id, CURRENT_TIMESTAMP - INTERVAL '1 day' * (i % 30));
    END LOOP;
END $$;

select * from appointments

SELECT * FROM appointments
WHERE appointment_date < CURRENT_TIMESTAMP;

CREATE TABLE prescriptions (
    id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(id),
    doctor_id INT REFERENCES doctors(id),
    medication TEXT NOT NULL,
    dosage TEXT NOT NULL
);

select * from prescriptions 

DO $$
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO prescriptions (patient_id, doctor_id, medication, dosage)
        VALUES (
            (SELECT id FROM patients ORDER BY RANDOM() LIMIT 1), -- random patient_id
            (SELECT id FROM doctors ORDER BY RANDOM() LIMIT 1),  -- random doctor_id
            'Medication ' || i,                                  -- dynamic medication name
            'Dosage ' || i                                       -- dynamic dosage
        );
    END LOOP;
END $$;

select * from prescriptions

SELECT * FROM prescriptions
WHERE patient_id > 200 ;

CREATE TABLE medical_records (
    id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(id),
    diagnosis TEXT,
    treatment TEXT,
    record_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

select * from medical_records

DO $$
BEGIN
    FOR i IN 1..500 LOOP
        INSERT INTO medical_records (patient_id, diagnosis, treatment, record_date)
        VALUES (
            (SELECT id FROM patients ORDER BY RANDOM() LIMIT 1), -- random patient_id
            'Diagnosis ' || i,                                   -- dynamic diagnosis
            'Treatment ' || i,                                   -- dynamic treatment
            CURRENT_TIMESTAMP + (i || ' days')::INTERVAL         -- varied record_date
        );
    END LOOP;
END $$;

select * from medical_records 

SELECT * FROM medical_records
WHERE treatment > 'Treatment 50' ;

--inner join
SELECT p.name AS patient_name, d.name AS doctor_name, a.appointment_date
FROM appointments a
INNER JOIN patients p ON a.patient_id = p.id
INNER JOIN doctors d ON a.doctor_id = d.id;

--left join

SELECT p.name AS patient_name, mr.diagnosis, mr.treatment
FROM patients p
LEFT JOIN medical_records mr ON p.id = mr.patient_id;

--right join

SELECT d.name AS doctor_name, p.medication, p.dosage
FROM prescriptions p
RIGHT JOIN doctors d ON p.doctor_id = d.id;

--full join

SELECT p.name AS patient_name, a.appointment_date
FROM patients p
FULL JOIN appointments a ON p.id = a.patient_id;

--4 examples of multi joins

--1. Example: Patients, Appointments, and Doctors
SELECT 
    patients.name AS patient_name, 
    doctors.name AS doctor_name, 
    appointments.appointment_date
FROM patients
JOIN appointments ON patients.id = appointments.patient_id
JOIN doctors ON appointments.doctor_id = doctors.id;

--2. Example: Patients, Prescriptions, and Doctors
SELECT 
    patients.name AS patient_name, 
    prescriptions.medication, 
    prescriptions.dosage, 
    doctors.name AS doctor_name
FROM patients
JOIN prescriptions ON patients.id = prescriptions.patient_id
JOIN doctors ON prescriptions.doctor_id = doctors.id;

--3. Example: Patients, Medical Records, and Prescriptions
SELECT 
    patients.name AS patient_name, 
    medical_records.diagnosis, 
    medical_records.treatment, 
    prescriptions.medication
FROM patients
JOIN medical_records ON patients.id = medical_records.patient_id
JOIN prescriptions ON patients.id = prescriptions.patient_id;

--4. Example: Doctors, Appointments, and Medical Records
SELECT 
    doctors.name AS doctor_name, 
    appointments.appointment_date, 
    medical_records.diagnosis
FROM doctors
JOIN appointments ON doctors.id = appointments.doctor_id
JOIN medical_records ON appointments.patient_id = medical_records.patient_id;

