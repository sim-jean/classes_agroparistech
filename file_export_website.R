### File copier

library(here)


### Define function

copy_files = function(folder_origin, folder_destination){
  for(file_ in list.files(folder_origin)){
    file.copy(here(folder_origin, file_), paste0(folder_destination, "/", file_), overwrite = T)
  }
}


copy_files(here("classes_compiled", "1e_année"), 
           "C:/Users/jean/OneDrive/Desktop/Projects/Professional website/files/teaching/agro/1A")

copy_files(here("classes_compiled", "UC1_Analyse_Economique"), 
           "C:/Users/jean/OneDrive/Desktop/Projects/Professional website/files/teaching/agro/2A")
copy_files(here("classes_compiled", "EERN"), 
           "C:/Users/jean/OneDrive/Desktop/Projects/Professional website/files/teaching/agro/2A")

copy_files(here("classes_compiled", "ecol_econ_eeet"), 
           "C:/Users/jean/OneDrive/Desktop/Projects/Professional website/files/teaching/EEET")