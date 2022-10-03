--1
select [CustomerName] = mc.CustomerName, [CustomerGender] = mc.CustomerGender, [CustomerEmail] = mc.CustomerEmail
from MsCustomer mc
where mc.CustomerName like 'm%'

--2
select [StaffName] = ms.StaffName, [TransactionDate] = th.TransactionDate
from MsStaff ms join TransactionHeader th on ms.StaffID = th.StaffID 
where DATENAME(quarter,th.transactiondate)=1

--3 
select [First Name] = left(mc.CustomerName,Charindex(' ',mc.customerName)-1), [Total Transaction] = count(th.customerID)
from MsCustomer mc join TransactionHeader th on mc.CustomerID = th.CustomerID
where mc.CustomerGender like 'Male'
group by mc.CustomerName

--4
select [ToppingName] = mt.ToppingName, [Total Transaction] = count(td.CroffleID), [Average Croffle Price] = AVG(mcr.CrofflePrice)
from MsTopping mt, TransactionDetail td, MsCroffle mcr
where mt.ToppingID = mcr.ToppingID and td.CroffleID = mcr.CroffleID and mcr.CroffleName like '%berry%'
group by mt.ToppingName
having avg(mcr.crofflePrice) > 200
UNION
select [ToppingName] = mt.ToppingName, [Total Transaction] = count(td.CroffleID), [Average Croffle Price] = AVG(mcr.CrofflePrice)
from MsTopping mt, TransactionDetail td, MsCroffle mcr
where mt.ToppingID = mcr.ToppingID and td.CroffleID = mcr.CroffleID and mcr.CroffleName like '%pinky%'
group by mt.ToppingName
having avg(mcr.crofflePrice) > 200

--5
select [Customer ID] = replace(mc.customerID,'CU','Customer '), [CustomerName] = mc.CustomerName, [CustomerGender] = mc.CustomerGender, [CustomerEmail] = mc.CustomerEmail
from MsCustomer mc, MsCroffle mcr, TransactionHeader th, TransactionDetail td
where mc.CustomerID = th.CustomerID and th.TransactionID = td.TransactionID and td.CroffleID = mcr.CroffleID and mcr.CroffleName like '% % %' and mcr.CroffleStock in (select mcr.CroffleStock from MsCroffle mcr where mcr.CroffleStock > 100)

--6
select [CustomerName] = mc.CustomerName, [Phone Number] = stuff(mc.CustomerPhoneNumber, CHARINDEX('0',mc.CustomerPhoneNumber),3,'+62')
from MsCustomer mc, MsStaff ms, TransactionHeader th, (select [avgsal] = AVG(ms.StaffSalary) from MsStaff ms) as sq
where mc.CustomerID = th.CustomerID and ms.StaffID = th.StaffID and ms.StaffSalary > sq.avgsal and DAY(th.transactiondate) = 25

--7
create view [View Strawberry Croffle] as
select [CroffleName] = mcr.CroffleName, [CrofflePrice] = mcr.CrofflePrice, [Stock] = CAST(mcr.CroffleStock as varchar(100)) + ' croffle(s)', [ToppingName] = mt.ToppingName
from MsCroffle mcr, Mstopping mt
where mcr.ToppingID = mt.ToppingID and mt.ToppingName like 'Strawberry%'
select * from [View Strawberry Croffle]

--8
create view [Total Purchase Croffle] as
select [ToppingName] = mt.ToppingName, [Total Purchase] = concat(SUM(td.quantity),' croffle(s)')
from MsTopping mt, MsCroffle mcr, TransactionDetail td
where mt.ToppingID = mcr.ToppingID and mcr.CroffleID = td.CroffleID and mt.ToppingName like '%c%' and mcr.CrofflePrice > 225
group by mt.ToppingName
select * from [Total Purchase Croffle]

--9
begin tran
alter table MsStaff
	add [StaffEmail] varchar(50)
alter table MsStaff
	add constraint checkstaffemail check(MsStaff.STaffEmail like '%krofflez.com')
	
rollback
commit
select * from MsStaff

--10
begin tran
delete from MsCustomer
where MsCustomer.CustomerID in
(select MsCustomer.CustomerID from MsCustomer, TransactionHeader, MsStaff where TransactionHeader.CustomerID = MsCustomer.CustomerID and TransactionHeader.StaffID = MsStaff.StaffID and MsStaff.StaffSalary > 1000 and Cast(right(MsStaff.StaffID,3) as int) % 2 = 0)

rollback
commit
select * from mscustomer