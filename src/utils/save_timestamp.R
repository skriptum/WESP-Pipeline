# Save and Timestamp Utility

library(writexl)
library(lubridate)


timestamp_save <- function (df, filename, source, frequency) {
  log_file <- "../../last_successful_run.csv"
  current_commit <- substr( system("git rev-parse HEAD", intern = TRUE), 0,7)
  
  # Generate timestamped filename
  current_time <- now(tzone = "America/New_York")
  current_time_str <- format(current_time, "%Y-%m-%d_%H-%M-%S")
  
  # (try to) save
  tryCatch({ # Try to save the file
      write_xlsx(
        x = list("Indicators" = df), 
        path = paste0("../../data/imf_processed/",filename),
        format_headers=F 
      )
      print(paste0("Saved {", filename, "} from ", source, " on: ", current_time_str))
      status <- "Success"
    }, error = function(e) { # Catch any errors during saving
      print(paste0("Error saving file: ", filename))
      print(e)
      status <- "Failure"
    }, finally = { # Finally, log the attempt
      
      # new row to add
      entry <- tibble::tibble(
        filename = filename,
        source = source,
        frequency = frequency,
        last_run = current_time_str,
        code_version = current_commit,
        status = status,
      )
      # read log file
      df <- read_csv(log_file, show_col_types = FALSE) 
      df <- filter(df, filename != !!filename) # Remove old entry for this file
      df <- bind_rows(df, entry)
      write_csv(df, log_file)
    }
  )
}


