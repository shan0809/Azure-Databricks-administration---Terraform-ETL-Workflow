containername = "azuredbcontainer"
storagename = "azuredbob1289"
mountpoint = "/mnt/custommount"
sas = "=="
try:
  
  dbutils.fs.mount( source = "wasbs://" + containername + "@" + storagename + ".blob.core.windows.net",
                mount_point = mountpoint,
                 extra_configs = {"fs.azure.account.key." + storagename + '.blob.core.windows.net': sas}
  )
except Exception as e:
  print("already mounted, please unmount using dbutils.fs.unmount")
