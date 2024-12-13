create procedure PayrollReport(in department_name varchar(45)) begin create temporary table TempHoursWorked(
    FullName varchar(100),
    HoursWorked int
);

insert into
    TempHoursWorked
values
    ('Dixie Herda', 2095),
    ('Stephen West', 2091),
    ('Philip Wilson', 2160),
    ('Robin Walker', 2083),
    ('Antoinette Matava', 2115),
    ('Courtney Walker', 2206),
    ('Gladys Bosch', 900);

create temporary table TempData
select
    concat(e.first_name, " ", e.last_name) as full_names,
    e.department_id as test,
    e.job_id
from
    employees as e
    left join departments as d on e.department_id = d.id
where
    name = department_name;

create temporary table income
select
    T.full_names,
    2080 * hourly_rate as base_pay,
    GREATEST(
        0,
        LEAST((TH.HoursWorked -2080) * j.hourly_rate * 1.5, 6000)
    ) as overtime_pay,
    GREATEST(
        0,
        LEAST((TH.HoursWorked -2080) * j.hourly_rate * 1.5, 6000)
    ) + 2080 * hourly_rate as total_pay,
    j.hourly_rate,
    TH.HoursWorked
from
    TempData as T
    left join jobs as j on T.job_id = j.id
    left join TempHoursWorked as TH on T.full_names = TH.FullName;

drop table TempData;

drop table TempHoursWorked;

create temporary table taxowed
select
    full_names,
    base_pay,
    overtime_pay,
    total_pay,
    case
        when total_pay <= 11000 then total_pay * 0.1
        when total_pay <= 95375.0 then 5147 + (total_pay - 44725) * 0.22
        when total_pay <= 182100.0 then 16290 + (total_pay - 95375) * 0.24
        when total_pay <= 231250 then 37104 + (total_pay - 182100) * 0.32
        when total_pay <= 578125 then 52832 + (total_pay - 231250) * 0.35
        when total_pay >= 578126 then 174238.25 + (total_pay - 578125) * 0.37
        else 0
    end as tax_owed,
    hourly_rate,
    HoursWorked
from
    income;

select
    full_names,
    base_pay,
    overtime_pay,
    total_pay,
    tax_owed,
    total_pay - tax_owed as net_income
from
    taxowed
order by
    net_income desc;

drop table taxowed;

drop table income;

end;

call PayrollReport('City Ethics Commission');
