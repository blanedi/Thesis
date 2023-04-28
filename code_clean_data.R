library(tidyverse)
library(haven) 
library(descr) 
library(corrplot) 
library(knitr)
library(kableExtra)
library(readxl)
library(ggplot2)
library(table1)
library(gtsummary)
library(estimatr)
library(dplyr)
library(car)
library(plm)
library(zoo)


setwd("/Users/CINTYAHUAIRE1/Downloads/")

# Define a vector of file names
file_names <- c("Argentina.csv","Barbados.csv", "Brazil.csv", "Chile.csv", "Colombia.csv", "Costa Rica.csv",
                "Cuba.csv", "Dominican Republic.csv","Ecuador.csv","El Salvador.csv", 
                "Peru.csv","Uruguay.csv","Mexico.csv","Panama.csv","Nicaragua.csv",
                "Honduras.csv","Guatemala.csv","Guyana.csv","Jamaica.csv","Paraguay.csv")

for (file in file_names) {
  # Read in the CSV file
  data <- read.csv(file)
  
  # Keep only certain variables in the data frame
  #data <- data[, c("Access.to.justice.for.women", "public_services", "Deliberative.Democracy.Index")] # Replace "var1", "var2", "var3" with the names of the variables you want to keep
  # Add a variable with the name of the dataset to the data frame
  data$dataset_name <- sub("\\.csv", "", file) # Assign the name of the dataset to a variable named "dataset_name"
  
  # Assign the data to a data frame with a unique name (same as file name without .csv extension)
  assign(sub("\\.csv", "", file), data)
}

ls()


# Select the five columns you want to keep
selected_cols <- c('Access.to.justice.for.women','Access.to.public.services.distributed.by.urban.rural.location',
                   'Freedom.of.discussion.for.women','dataset_name','Year')

# Merge the datasets vertically and keep only the selected columns
merged_data <- rbind(Argentina[selected_cols], Barbados[selected_cols], Brazil[selected_cols],Chile[selected_cols],
                     Colombia[selected_cols], `Costa Rica`[selected_cols], Cuba[selected_cols], `Dominican Republic`[selected_cols],
                     Ecuador[selected_cols], `El Salvador`[selected_cols],Nicaragua[selected_cols],
                     Guatemala[selected_cols], Guyana[selected_cols],Honduras[selected_cols],
                     Jamaica[selected_cols], Mexico[selected_cols],Panama[selected_cols],
                     Paraguay[selected_cols], Peru[selected_cols],Uruguay[selected_cols])

# Subset the data frame to keep only the rows with years in the desired period
merged_data <- merged_data[merged_data$Year >= 2005 & merged_data$Year <= 2019,]
names(merged_data)[4] <- "country"
names(merged_data)[5] <- "year"

# Read in specific cells from a sheet in an Excel file
political_stability <- read_excel("/Users/CINTYAHUAIRE1/Documents/HERTIE courses/Thesis/datos_final.xlsx", sheet = "political_stability", range = "A1:P21")

# Reshape the long data into a panel model format
political_stability <- gather(political_stability, year, value, -country)

names(political_stability)[3] <- "political_stability"

# Read in specific cells from a sheet in an Excel file
women_parlam <- read_excel("/Users/CINTYAHUAIRE1/Documents/HERTIE courses/Thesis/datos_final.xlsx", sheet = "women_parlament", range = "A1:P21")

# Reshape the long data into a panel model format
women_parlam <- gather(women_parlam, year, value, -country)

names(women_parlam)[3] <- "Women_politics"

# Read in specific cells from a sheet in an Excel file
female_educ <- read_excel("/Users/CINTYAHUAIRE1/Documents/HERTIE courses/Thesis/datos_final.xlsx", sheet = "tertiary educ_women", range = "A1:P21")

# Reshape the long data into a panel model format
female_educ <- gather(female_educ, year, value, -country)

names(female_educ)[3] <- "Female.enrolled.tertiary.education"

# Read in specific cells from a sheet in an Excel file
female_labor <- read_excel("/Users/CINTYAHUAIRE1/Documents/HERTIE courses/Thesis/datos_final.xlsx", sheet = "Labor_force_fem", range = "A1:P21")

# Reshape the long data into a panel model format
female_labor <- gather(female_labor, year, value, -country)

names(female_labor)[3] <- "women_labor"

# Read in specific cells from a sheet in an Excel file
GDP_growth <- read_excel("/Users/CINTYAHUAIRE1/Documents/HERTIE courses/Thesis/datos_final.xlsx", sheet = "GDP", range = "A1:P21")

# Reshape the long data into a panel model format
GDP_growth <- gather(GDP_growth, year, value, -country)

names(GDP_growth)[3] <- "GDP_growth"

# Read in specific cells from a sheet in an Excel file
maternal_mort <- read_excel("/Users/CINTYAHUAIRE1/Documents/HERTIE courses/Thesis/datos_final.xlsx", sheet = "lifetime mortality maternal", range = "A1:P22")

# Reshape the long data into a panel model format
maternal_mort <- gather(maternal_mort, year, value, -country)

names(maternal_mort)[3] <- "Lifetime.risk.maternal.death"

# Read in specific cells from a sheet in an Excel file
social_protection <- read_excel("/Users/CINTYAHUAIRE1/Documents/HERTIE courses/Thesis/datos_final.xlsx", sheet = "GDP_social_protection", range = "A1:P21")

# Reshape the long data into a panel model format
social_protection <- gather(social_protection, year, value, -country)

names(social_protection)[3] <- "social_protection"

# Read in specific cells from a sheet in an Excel file
Care_index <- read_excel("/Users/CINTYAHUAIRE1/Documents/HERTIE courses/Thesis/datos_final.xlsx", sheet = "care_index_representation", range = "A1:E21")

merged_data_2 <- political_stability %>% 
  left_join(women_parlam, by = c("country", "year")) %>% 
  left_join(female_educ, by = c("country", "year")) %>% 
  left_join(female_labor, by = c("country", "year")) %>% 
  left_join(GDP_growth, by = c("country", "year")) %>% 
  left_join(maternal_mort, by = c("country", "year"))%>% 
  left_join(social_protection, by = c("country", "year"))

data_final <- merge(merged_data_2, merged_data, by = c("country", "year"))

data_final <- left_join(data_final, Care_index, by = "country")


# Repeat the unique data values for each year, filling in missing values for string variable
data_final <- data_final %>% 
  group_by(country) %>% 
  mutate_at(vars(`Region`, `Care index`, `Compromise to eliminate discrimination against women`, `Organizations that advocate for feminism rights (%)`), list(~ifelse(all(is.na(.)), NA, na.locf(.))))

#data_final <- data_final %>%
 # mutate_at(setdiff(names(data_final), "Region","country"), as.numeric)

####correlogram

names(data_final)[5] <- "women_education"
names(data_final)[8] <- "women_health"
names(data_final)[9] <- "social_protection"
names(data_final)[10] <- "women_justice"
names(data_final)[11] <- "public_services"
names(data_final)[14] <- "Care_index"
names(data_final)[12] <- "freedom_exp_w"


# Calculate the correlation matrix
cor_matrix <- cor(data_final[, c("Care_index","Women_politics","GDP_growth","social_protection",
                                 "public_services","political_stability", "women_justice",
                                 "freedom_exp_w","women_education", "women_labor",
                                 "women_health")])

# matrix of the p-value of the correlation
p.mat <- cor.mtest(cor_matrix)
p.mat
# Create a correlation plot
corrplot(cor_matrix, method = "number", tl.cex=0.8)
corrplot(cor_matrix, method = "circle", tl.cex=0.8)

#######Descriptive statistics

#Summary tables - IVs
data_final$region2<- if_else(data_final$Region=="North America","South America",
                             if_else(data_final$Region=="Central America","Caribe & Central America",
                                     if_else(data_final$Region=="Caribbean","Caribe & Central America","South America")) )
table1::label(data_final$political_stability) <-"Political stability"
table1::label(data_final$Women_politics) <-"% Women in parliament"
table1::label(data_final$women_education) <-"% Women in tertiary education"
table1::label(data_final$women_labor) <-"% Women in labor force"
table1::label(data_final$GDP_growth) <-"GDP growth percapita"
table1::label(data_final$social_protection) <-" % GDP Social protection"
table1::label(data_final$women_justice) <-"Access to justice for women"
table1::label(data_final$women_health) <-"Maternal mortality(lifetime risk) "
table1::label(data_final$Care_index) <-"Progressive care policies index"
table1::label(data_final$political_stability) <-"Political stability"
table1::label(data_final$freedom_exp_w) <-"Freedom of expression for women"
table1::label(data_final$public_services) <-"Acces to public services in urban-rural areas"
table1::table1(~Care_index+Women_politics+
                 GDP_growth + social_protection+ public_services +
                 women_education+women_labor+women_health  + freedom_exp_w + 
                 women_justice +political_stability|region2, data = data_final,
               footnote ="For this analysis Mexico is included in South America")

#### Test multicollinearity######


model_5 <-lm(Care_index  ~ Women_politics +
               GDP_growth + social_protection  + public_services + 
               political_stability  + women_justice + 
               women_education + women_labor + freedom_exp_w + women_health , data=data_final)

vif_values<-vif(model_5)
print(vif_values)
###### HAUSMAN test to choosed model#######
# Run fixed effects model
model_fixed <- plm(Care_index ~ Women_politics   
                  , data = data_final, model = "within")

# Run random effects model
model_random <- plm(Care_index ~ Women_politics , 
                data = data_final, index = c("country", "year"), model = "random", effect="individual")


# Conduct Hausman test
ha_test <- phtest(model_fixed, model_random)

# Print results
print(ha_test)


##### time or individual effects####

model_fix <- plm(Care_index ~ Women_politics , 
                 data = data_final, index = c("country", "year"), model = "within")
model_fix2 <- plm(Care_index ~ Women_politics +factor(year) , 
                  data = data_final, index = c("country", "year"), model = "within")

pFtest(model_fix2, model_fix)
plmtest(model_fix,c("time"),type=("bp"))

###* disclaimer: the map of care index had been done using excel
####plotting women in politics####

library(ggplot2)

ggplot(data=data_final, aes(y=Women_politics, x=as.numeric(year))) +
  geom_line() +
  facet_wrap(~country) +
  labs(title = "Percentage of women in parliament by year and country",
       x = "Women in parliament (%)",
       y = "Year") 



#Simple models

##### fixed
library(modelsummary)
library(gt)

model_1 <-lm(Care_index  ~ Women_politics + factor(year)-1, data=data_final)

model_1_sum <- 
  modelsummary(model_1,
               stars = TRUE, 
               output = "gt",gof_omit = 'IC|Log|Adj',
               title = "LSDV Regression Model Results",
               dep.var.caption = "Dependent variable: Parental Policy Index",
               add_rows = data.frame(label = "Notes", value = "Standard errors in parentheses.")
               )
model_1_sum


# model 2: including socioeconomic indicators

model_2 <-lm(Care_index  ~ Women_politics +
               GDP_growth + social_protection  + public_services + 
                factor(year) - 1, data=data_final)

# model 3: including political dimension

model_3 <-lm(Care_index  ~ Women_politics +
               political_stability +  freedom_exp_w +
               factor(year) - 1, data=data_final)

# model 4: including gender equality

model_4 <-lm(Care_index  ~ Women_politics +
               women_education + women_labor + women_health + 
               factor(year) - 1, data=data_final)

# model 5: all

model_5 <-lm_robust(Care_index  ~ Women_politics +
               GDP_growth + social_protection  + public_services + 
               political_stability + 
               women_education + women_labor + freedom_exp_w + women_health + 
               factor(year) - 1, data=data_final, fixed_effects = ~ year , se_type = "HC3")

modelsummary(model_5, coef_omit = "factor(year)*", stars=TRUE)

######Plotting models

models<- list("Model 1"=model_1, "Model 2"= model_2, "Model 3"=model_3, "Model 4"=model_4, "Model 5"=model_5)
model_final<-modelsummary(models,fmt=3, stars= TRUE, coef_omit = "factor(year)*", gof_omit = 'IC|Log|Adj',
              title = "LSDV regression models results per category of controls ",
             dep.var.caption = "Dependent variable: Care_index Policies Index",
             coef_rename = c("Women_politics"= "Proportion of women in parliament", 
                             "GDP_growth"="GDP growth percapita",
                             "social_protection" = "% GDP Social protection",
                             "public_services"="Acces to public services in urban-rural areas",
                             "political_stability"="Political stability index",
                             "freedom_exp_w"="Women´s freedom of expression index",
                             "women_education"="%Female enrolled tertiary education",
                             "women_labor"="% Female labor force",
                             "women_health"="Maternal mortality(lifetime risk)"), 
             notes="Standard errors in parentheses")
model_final
modelplot(model_5,color = 'darkgreen', linetype = 'dotted', coef_omit = "factor(year)*") +
  theme_gray()


#model 6 and 7: all per region

#generating databases per subgroup ****
data_la<- subset(data_final, region2=="South America")
data_cc<-subset(data_final, region2=="Caribe & Central America")

###South America including Mexico######
model_6 <-lm(Care_index  ~ Women_politics +
               GDP_growth + social_protection  + public_services + 
               political_stability   + women_justice + 
               women_education + women_labor + freedom_exp_w + women_health + 
               factor(year) - 1, data=data_la)

##### Caribe and central america########

model_7 <-lm(Care_index  ~ Women_politics +
               GDP_growth + social_protection  + public_services + 
               political_stability   + women_justice + 
               women_education + women_labor + freedom_exp_w + women_health + 
               factor(year) - 1, data=data_cc)

####plotting model #####

models_2<- list("South America"=model_6, "Caribe & Central America"= model_7)
model_region<-modelsummary(models_2,fmt=3,stars= TRUE, coef_omit = "factor(year)*", gof_omit = 'IC|Log|Adj',
                          statistic = "({std.error})", title = "LSDV regression models results per country group ",
                          dep.var.caption = "Dependent variable: Care_index Policies Index",
                          coef_rename = c("Women_politics"= "% Women in parliament", 
                                          "GDP_growth"="GDP growth percapita",
                                          "social_protection" = "% GDP Social protection",
                                          "women_justice"="Access to justice for women",
                                          "public_services"="Acces to public services in urban-rural areas",
                                          "political_stability"="Political stability index",
                                          "freedom_exp_w"="Women´s freedom of expression index",
                                          "women_education"="%Female enrolled tertiary education",
                                          "women_labor"="% Female labor force",
                                          "women_health"="Maternal mortality(lifetime risk)"), 
                          notes="For this analysis South America includes Mexico. Standard errors in parentheses")
model_region




