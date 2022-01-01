// Databricks notebook source
import org.apache.spark.sql.types.{StructType,StructField, IntegerType , StringType,BooleanType , FloatType}

var fireschema = StructType(Array(StructField("CallNumber", IntegerType, true),
                                  StructField("UnitID", StringType, true),
                                  StructField("IncidentNumber", IntegerType, true),
                                  StructField("CallType", StringType, true),
                                  StructField("CallDate", StringType, true),
                                  StructField("WatchDate", StringType, true),
                                  StructField("CallFinalDisposition", StringType, true),
                                  StructField("AvailableDtTm", StringType, true),
                                  StructField("Address", StringType, true),
                                  StructField("City", StringType, true),
                                  StructField("Zipcode", IntegerType, true),
                                  StructField("Battalion", StringType, true),
                                  StructField("StationArea", StringType, true),
                                  StructField("Box", StringType, true),
                                  StructField("OriginalPriority", StringType, true),
                                  StructField("Priority", StringType, true),
                                  StructField("FinalPriority", IntegerType, true),
                                  StructField("ALSUnit", BooleanType, true),
                                  StructField("CallTypeGroup", StringType, true),
                                  StructField("NumAlarms", IntegerType, true),
                                  StructField("UnitType", StringType, true),
                                  StructField("UnitSequenceInCallDispatch", IntegerType, true),
                                  StructField("FirePreventionDistrict", StringType, true),
                                  StructField("SupervisorDistrict", StringType, true),
                                  StructField("Neighborhood", StringType, true),
                                  StructField("Location", StringType, true),
                                  StructField("RowID", StringType, true),
                                  StructField("Delay", FloatType, true)))

val FireFile= "/FileStore/tables/firecsv/Fire_Incidents.csv"
val fireDF = spark.read.schema(fireschema).option("header","true").csv(FireFile)
display(fireDF)

                             

// COMMAND ----------

val fewFireDF = fireDF.select("IncidentNumber", "AvailableDtTm", "CallType").where($"CallType" =!= "Mecial Incident")
fewFireDF.show(10)

// COMMAND ----------

import org.apache.spark.sql.functions._

fireDF.select("CallType").where(col("CallType").isNotNull).agg(countDistinct('CallType) as 'DistincCallTypes).show()

// COMMAND ----------

fireDF.select("CallType").where(col("CallType").isNotNull).groupBy("CallType").count().orderBy(desc("count")).show(5)

// COMMAND ----------

val newFireDF = fireDF.withColumnRenamed("Delay", "ResponseDelayedinMins")
newFireDF.select("ResponseDelayedinMins").where($"ResponseDelayedinMins" < 5).show(10)

// COMMAND ----------

import org.apache.spark.sql.{functions => F}
newFireDF.select(F.sum("NumAlarms"), F.avg("ResponseDelayedinMins"),
                F.min("ResponseDelayedinMins"), F.max("ResponseDelayedinMins")).show()

// COMMAND ----------


