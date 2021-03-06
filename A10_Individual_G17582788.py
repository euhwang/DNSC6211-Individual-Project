# -*- coding: utf-8 -*-
"""
Created on Sat Nov 28 09:57:25 2015

@author: Eugene Hwang

Grabs data from World Bank and puts the information into a MySQL database.
"""

import wbdata
import datetime
import MySQLdb as myDB
import warnings

def getWBData():
    #Manually grabbed all links from the pdf
    Male_HIV = ["http://data.worldbank.org/indicator/SH.HIV.1524.MA.ZS"]
    Female_HIV = ["http://data.worldbank.org/indicator/SH.HIV.1524.FE.ZS"]
    Total_HIV = ["http://data.worldbank.org/indicator/SH.DYN.AIDS.ZS"]
    
    #Used loop to get indicators from each link
    inds_Male = [x.split("/")[4] for x in Male_HIV]
    inds_Female = [x.split("/")[4] for x in Female_HIV]
    inds_Total = [x.split("/")[4] for x in Total_HIV]
    
    #indicators = dict(zip(inds,vals))
    inds_Male_2 = dict(zip(inds_Male,inds_Male))
    inds_Female_2 = dict(zip(inds_Female,inds_Female))
    inds_Total_2 = dict(zip(inds_Total,inds_Total))
    
    #Set the date range
    data_date = (datetime.datetime(1990,1,1),datetime.datetime(2014,1,1))
    
    #Download data for all indicators --- each indicator is a variable/column
    #Reset Index so that Year and Country are columns 
    #Add additional column and rename column names
    #Remove non-countries and troublesome countries from data
    MaleAll = wbdata.get_dataframe(indicators = inds_Male_2, data_date = data_date ).fillna(0).ix[340:,:]
    MaleAll = MaleAll.reset_index()
    MaleAll = MaleAll.drop(MaleAll.index[0:510])
    MaleAll['Gender'] = 'Male'
    MaleAll.columns = ['Country','Year','Prevalence','Gender']
    MaleAll = MaleAll[MaleAll.Country != "Cote d'Ivoire"]
    
    FemaleAll = wbdata.get_dataframe(indicators = inds_Female_2, data_date = data_date ).fillna(0).ix[340:,:]
    FemaleAll = FemaleAll.reset_index()
    FemaleAll = FemaleAll.drop(FemaleAll.index[0:510])
    FemaleAll['Gender'] = 'Female'
    FemaleAll.columns = ['Country','Year','Prevalence','Gender']
    FemaleAll = FemaleAll[FemaleAll.Country != "Cote d'Ivoire"]
    
    
    TotalAll = wbdata.get_dataframe(indicators = inds_Total_2, data_date = data_date ).fillna(0).ix[340:,:]
    TotalAll = TotalAll.reset_index()
    TotalAll = TotalAll.drop(TotalAll.index[0:510])
    TotalAll['Gender'] = 'Total'
    TotalAll.columns = ['Country','Year','Prevalence','Gender']
    TotalAll = TotalAll[TotalAll.Country != "Cote d'Ivoire"]
    
    #Combining all the data together
    Final_Table = MaleAll.append([FemaleAll,TotalAll])
    
    #Reading the LGBT HIV csv file and changing the index to Countries.
    #LGBT_csv = pd.read_csv('LGBT_HIV_FINAL_v1.csv') 
    #LGBTAll = LGBT_csv.set_index('Countries')
    #LGBTAll = LGBTAll.drop(LGBTAll.index[[20]])
    #LGBTAll['Gender'] = 'LGBT' 
    
    return Final_Table


def write2Mysql(Final_Table):
    #Inserts dataframe into MySQL
    con = myDB.connect(host='localhost', user='root', passwd='root')
    cursor = con.cursor()
    warnings.simplefilter("ignore")
    cursor.execute("Create Database if not exists HIV;")
    con.select_db("HIV")
    myTable = 'PrevHIV'
    
    #check if table exist
    sql =  "Select count(*) from information_schema.tables where table_name = '" + myTable + "'"
    cursor.execute(sql)
    if cursor.fetchone()[0] == 0:
        sql =  "Create table " + myTable + "(Country char(20), Year int, Prevalence decimal(5,1), Gender char(20));"  
        cursor.execute(sql)
    else:
        sql =  "Drop table " + myTable + ";"  
        cursor.execute(sql)
        sql =  "Create table " + myTable + "(Country char(20), Year int, Prevalence decimal(5,1), Gender char(20));"  
        cursor.execute(sql)
    
    for index, row in Final_Table.iterrows(): #Must change to the final dataframe name
        Country = "'{0}'".format(row['Country'])
        Year = "'{0}'".format(row['Year'])
        Prevalence = "{:5.1f}".format(row['Prevalence'])
        Gender = "'{0}'".format(row['Gender'])
        sql = "Insert into " + myTable + " values(" + Country +","+ Year +","+ Prevalence +","+ Gender+");"
        cursor.execute(sql)
    
    con.commit()

def main():
    
    Final_Table = getWBData()
    write2Mysql(Final_Table)

if __name__ == "__main__":
    main()   
