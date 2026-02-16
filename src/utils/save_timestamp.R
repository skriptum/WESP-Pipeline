# Save and Timestamp Utility

library(writexl)
library(lubridate)


timestamp_save <- function (df, filename, source, frequency, format) {
  log_file <- "../../last_successful_run.csv"
  current_commit <- substr( system("git rev-parse HEAD", intern = TRUE), 0,7)
  
  # Generate timestamped filename
  current_time <- now(tzone = "America/New_York")
  current_time_str <- format(current_time, "%Y-%m-%d_%H-%M-%S")
  
  # IMF ---------
  # (try to) save
  if (source == "IMF"){
    
    tryCatch({ # Try to save the file
      if (format == "xlsx") {
        write_xlsx(
          x = list(filename = df), 
          path = paste0("../../data/imf_processed/",filename,".xlsx"),
          format_headers=F 
        )
      } else if (format == "csv") {
        write_csv(
          x = df, 
          file = paste0("../../data/imf_processed/",filename,".csv")
        )
      } else {
        stop(paste0("Unsupported format: ", format))
      }
        print(paste0("Saved {", filename, "} from ", source, " on: ", current_time_str, " as ", format))
        status <- "Success"
      }, error = function(e) { # Catch any errors during saving
        print(paste0("Error saving file: ", filename))
        print(e)
        status <- "Failure"
      }
    )
  } else if (source == "EUROSTAT") {
  # EUROSTAT ---------
    tryCatch({ # Try to save the file
      write_xlsx(
        x = list(
          Annual = df$Annual,
          Quarterly = df$Quarterly,
          Monthly = df$Monthly
        ), 
        path = paste0("../../data/eurostat_processed/",filename,".xlsx"),
      )
      print(paste0("Saved {", filename, "} from ", source, " on: ", current_time_str, " as ", format))
      status <- "Success"
    }, error = function(e) { # Catch any errors during saving
      print(paste0("Error saving file: ", filename))
      print(e)
      status <- "Failure"
      }
      )
  } 
    
  # new row to add
  entry <- tibble::tibble(
    filename = filename,
    source = source,
    frequency = frequency,
    format = format,
    last_run = current_time_str,
    code_version = current_commit,
    status = status
  )
  # read log file
  df <- read_csv(log_file, show_col_types = FALSE) 
  df <- filter(df, filename != !!filename) # Remove old entry for this file
  df <- bind_rows(df, entry)
  write_csv(df, log_file)
    
  
}


