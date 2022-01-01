// Databricks notebook source
val mydataframe = spark.read
.option("header", "true")
.option("inferSchema", "true")
.csv("dbfs:/FileStore/tables/createdviadatabricksdb/*csv")

val selectexprssion = mydataframe.select("DEST_COUNTRY_NAME", "ORIGIN_COUNTRY_NAME","count")

val renameddata = selectexprssion.withColumnRenamed("DEST_COUNTRY_NAME", "Destination_Country")
// display(renameddata.describe("Destination_Country","ORIGIN_COUNTRY_NAME","count" ))
// val filter = renameddata.where("count > 100")
// display(filter)

display(renameddata)

renameddata.createOrReplaceTempView("usertraveldata")

val aggregatedata = spark.sql(""" SELECT ORIGIN_COUNTRY_NAME , Destination_Country , sum(count) FROM usertraveldata
group by ORIGIN_COUNTRY_NAME, Destination_Country 
ORDER BY sum(count) """)

aggregatedata.write.option("header", "true")
.format("com.databricks.spark.csv")
.save("/mnt/custommount/traveloutputJob.csv")

// COMMAND ----------


