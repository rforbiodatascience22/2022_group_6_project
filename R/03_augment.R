# Load in clean data ------------------------------------------------------
data <- read_csv(file = "data/02_dat_clean.csv",
                 show_col_types = FALSE)


# Make artificial split. Split into patient- and medical info --------------
patient_info <- data %>% 
  select(sample, age, dfi, smoking, cancer_hist, bmi)
  
medical_info <- data %>% 
  select(!c(age, dfi, smoking, cancer_hist, bmi))


# Add in and factorize a BMI class ----------------------------------------
patient_info <- patient_info %>% 
  mutate(bmi_class = case_when(bmi < 18.5 ~ "underweight",
                               18.5 <= bmi & bmi < 25 ~ "normal weight",
                               25 <= bmi & bmi < 30 ~ "overweight",
                               30 <= bmi ~ "obese"))

# Add in a DFI class ------------------------------------------------------
patient_info <- patient_info %>% 
  mutate(dfi_class = case_when(dfi < 20 ~ "low fat",
                                   20 <= dfi & dfi < 30 ~ "medium fat",
                                   30 <= dfi ~ "high fat"))


# Split TNM notation into separate variables ------------------------------
# Add variables derived from TNM 
# Standard naming convention taken from www.cancerresearchuk.org
medical_info <- medical_info %>% 
  extract(col = tnm,
          into = c("tumor","lymph_nodes","metastasis"),
          regex = "[Tt](\\d).?[Nn](\\d)[Mm](\\d)")
# Sample CM4082 has an "l" which maybe should have been a "1", but we cannot 
# be sure, and as such we do not accept it for TNM

# Add group names ------------------------------------------------
medical_info <- medical_info %>% 
  mutate(group_names = case_when(group == 1 ~ "prostate cancer",
                                 group == 0 ~ "control"))

# Join patient info and medical info based on Sample ----------------------
data_augmented <- patient_info %>% 
  full_join(medical_info,
            by = "sample")

# Write the augmented data file -----------------------------------------------------
data_augmented %>% 
  write_csv(path = "data/03_dat_aug.csv")
