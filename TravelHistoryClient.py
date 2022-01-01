# Databricks notebook source
# MAGIC %fs head /mnt/custommount/SmallDatasetTravel.csv

# COMMAND ----------

# MAGIC %scala
# MAGIC val mydataframe = spark.read.option("header", "true").option("inferSchema", "true").csv("/mnt/custommount")
# MAGIC display(mydataframe)
# MAGIC print("dataframe created")

# COMMAND ----------

# MAGIC %scala 
# MAGIC val selectexprssion = mydataframe.select("DEST_COUNTRY_NAME", "ORIGIN_COUNTRY_NAME","count")
# MAGIC display(selectexprssion)

# COMMAND ----------

# MAGIC %scala
# MAGIC val renameddata = selectexprssion.withColumnRenamed("DEST_COUNTRY_NAME", "Destination_Country")
# MAGIC display(renameddata)

# COMMAND ----------

# MAGIC %scala
# MAGIC val mydataframe = spark.read.option("header", "true").option("inferSchema", "true").csv("/mnt/custommount")
# MAGIC val selectexprssion = mydataframe.select("DEST_COUNTRY_NAME", "ORIGIN_COUNTRY_NAME","count")
# MAGIC val renameddata = selectexprssion.withColumnRenamed("DEST_COUNTRY_NAME", "Destination_Country")
# MAGIC // display(renameddata.describe("Destination_Country","ORIGIN_COUNTRY_NAME","count" ))
# MAGIC // val filter = renameddata.where("count > 100")
# MAGIC // display(filter)
# MAGIC display(renameddata)
# MAGIC renameddata.createOrReplaceTempView("usertraveldata")

# COMMAND ----------

# MAGIC %sql 
# MAGIC SELECT * FROM usertraveldata

# COMMAND ----------

# MAGIC %sql 
# MAGIC SELECT ORIGIN_COUNTRY_NAME , Destination_Country , sum(count) FROM usertraveldata
# MAGIC group by ORIGIN_COUNTRY_NAME, Destination_Country 
# MAGIC ORDER BY sum(count)

# COMMAND ----------

# MAGIC %scala
# MAGIC val aggregatedata = spark.sql(""" SELECT ORIGIN_COUNTRY_NAME , Destination_Country , sum(count) FROM usertraveldata
# MAGIC group by ORIGIN_COUNTRY_NAME, Destination_Country 
# MAGIC ORDER BY sum(count) """)
# MAGIC 
# MAGIC aggregatedata.write.option("header", "true").format("com.databricks.spark.csv").save("/mnt/custommount/traveloutput.csv")

# COMMAND ----------



# COMMAND ----------

# MAGIC %scala
# MAGIC val mydataframe = spark.read
# MAGIC .option("header", "true")
# MAGIC .option("inferSchema", "true")
# MAGIC .csv("dbfs:/FileStore/tables/createdviadatabricksdb/*csv")
# MAGIC 
# MAGIC val selectexprssion = mydataframe.select("DEST_COUNTRY_NAME", "ORIGIN_COUNTRY_NAME","count")
# MAGIC 
# MAGIC val renameddata = selectexprssion.withColumnRenamed("DEST_COUNTRY_NAME", "Destination_Country")
# MAGIC // display(renameddata.describe("Destination_Country","ORIGIN_COUNTRY_NAME","count" ))
# MAGIC // val filter = renameddata.where("count > 100")
# MAGIC // display(filter)
# MAGIC 
# MAGIC display(renameddata)
# MAGIC 
# MAGIC renameddata.createOrReplaceTempView("usertraveldata")
# MAGIC 
# MAGIC val aggregatedata = spark.sql(""" SELECT ORIGIN_COUNTRY_NAME , Destination_Country , sum(count) FROM usertraveldata
# MAGIC group by ORIGIN_COUNTRY_NAME, Destination_Country 
# MAGIC ORDER BY sum(count) """)
# MAGIC 
# MAGIC aggregatedata.write.option("header", "true")
# MAGIC .format("com.databricks.spark.csv")
# MAGIC .saveAsTable("databrickstables.savedsatastore")

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE DATABASE if NOT EXISTS databrickstables

# COMMAND ----------


