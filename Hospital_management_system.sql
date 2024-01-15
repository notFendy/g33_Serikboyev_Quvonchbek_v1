
/*
 Quvonchbek Serikboyev v1
 https://drawsql.app/teams/g33-team/diagrams/hospital
 */
create table address(
                        address_id bigserial primary key ,
                        city varchar not null
);
create table doctor(
                       doctor_id bigserial primary key ,
                       first_name varchar not null ,
                       last_name varchar not null ,
                       specialization varchar not null ,
                       phone_number varchar ,
                       address bigint references address(address_id) not null
);

create table patient(
                        id bigserial primary key ,
                        first_name varchar not null ,
                        last_name varchar not null ,
                        phone_number varchar ,
                        date_of_birth date not null ,
                        gender varchar not null ,
                        address bigint references address(address_id) not null
);

create table appointments(
                             id bigserial primary key ,
                             patient_id bigint references patient(id) not null ,
                             doctor_id bigint references doctor(doctor_id) not null ,
                             appointment_date date not null ,
                             diagnosis varchar not null
);

drop table address;
drop table doctor;
drop table patient;
drop table appointments;

insert into address(city) values ('Toshkent viloyati'),
                                 ('Toshkent shahri'),
                                 ('Jizzax viloyati'),
                                 ('Samarqand viloyati'),
                                 ('Buxoro viloyati');

insert into doctor(first_name, last_name, specialization, phone_number, address)
values ('doctor1', 'lastname1', 'Stomatolog', '+998990999999', 1),
       ('doctor2', 'lastname2', 'Bolalar doktori', '+998999999998', 2),
       ('doctor3', 'lastname3', 'Bosh shifokor', '+998939999996', 3),
       ('doctor3', 'lastname3', 'Yurak doktori', '+998959999997', 2);


insert into patient(first_name, last_name, phone_number, date_of_birth, gender, address)
values ('patient1', 'lastname01','+998931111111', '2002-12-01', 'male', 5),
       ('patient2', 'lastname02','+998901111112', '1999-02-11', 'female', 4),
       ('patient3', 'lastname03','+998951111113', '2006-04-12', 'female', 1);

insert into appointments(patient_id, doctor_id, appointment_date, diagnosis)
values (1, 3, '2024-01-12', 'Yurak o`rig`i'),
       (2, 2, '2024-01-14', 'Tish o`rig`i'),
       (3, 3, '2024-01-15', 'Yuragi kasal');



create or replace function fn_search_patient_by_name(patient_name varchar)
returns table(
    patient_id bigint,
patient_first_name varchar,
patient_last_name varchar,
patient_phone_number varchar,
patient_date_of_birth date,
patient_gender varchar,
patient_address varchar,
patient_diagnosis varchar
             )
language plpgsql
as
    $$
begin
return query
select p.id, p.first_name, p.last_name, p.phone_number, p.date_of_birth, p.gender, a2.city, a.diagnosis
from patient p
         inner join appointments a on p.id = a.patient_id
         inner join address a2 on a2.address_id = p.address
where p.first_name ilike '%' || patient_name || '%' ;
end;
    $$;

drop function fn_search_patient_by_name;
select * from fn_search_patient_by_name('3');


create or replace procedure pr_appointment_scheduling(
p_patient_id bigint,
p_doctor_id bigint,
p_appointment_date date,
p_appointment_diagnosis varchar
)
language plpgsql
as
    $$
begin
insert into appointments(patient_id, doctor_id, appointment_date, diagnosis)
values (p_patient_id, p_doctor_id, p_appointment_date, p_appointment_diagnosis);
end;
    $$;
call pr_appointment_scheduling(3, 4, '2023-12-15', 'yurak o`rig`i' );

create view appointments_scheduled_today as
select a.id, a.patient_id, a.doctor_id, a.appointment_date, a.diagnosis from appointments a
where a.appointment_date = current_date;

select * from appointments_scheduled_today;


create materialized view patient_appointment_count as
select  p.first_name || ' ' || p.last_name as full_name,
        count(a.id) as appointment_count,
        extract(month from a.appointment_date) as month,
           extract(year from a.appointment_date) as year
from patient p
    inner join appointments a on p.id = a.patient_id
where appointment_date >= now() - interval '1 month' and appointment_date < now()
group by full_name, month, year with no data;

refresh materialized view patient_appointment_count;
select * from patient_appointment_count;